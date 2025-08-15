terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

provider "aws" {
  region                       = var.aws_region
  access_key                   = var.offline_mode ? "dummy" : null
  secret_key                   = var.offline_mode ? "dummy" : null
  skip_credentials_validation  = var.offline_mode
  skip_requesting_account_id   = var.offline_mode
  s3_use_path_style            = var.offline_mode
}

############################################
# S3 com Lifecycle para Glacier Deep Archive
############################################
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "archive" {
  bucket        = "${var.project_prefix}-archive-${random_id.suffix.hex}-${var.aws_region}"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "archive" {
  bucket = aws_s3_bucket.archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id

  rule {
    id     = "to-glacier-deep-archive"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = var.glacier_transition_days
      storage_class   = "DEEP_ARCHIVE"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

############################################
# Lambda de rotina noturna com EventBridge
############################################
# Empacotamento do código da Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project_prefix}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "nightly_job" {
  function_name = "${var.project_prefix}-nightly-job"
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 60
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.archive.bucket
    }
  }
}

# Agendamento diário às 02:00 UTC
resource "aws_cloudwatch_event_rule" "nightly" {
  name                = "${var.project_prefix}-nightly-rule"
  schedule_expression = var.nightly_cron
}

resource "aws_cloudwatch_event_target" "nightly_lambda" {
  rule      = aws_cloudwatch_event_rule.nightly.name
  target_id = "lambda"
  arn       = aws_lambda_function.nightly_job.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nightly_job.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nightly.arn
}

#################
# AWS Backup
#################
resource "aws_backup_vault" "main" {
  name        = "${var.project_prefix}-backup-vault"
  kms_key_arn = null
}

resource "aws_backup_plan" "daily" {
  name = "${var.project_prefix}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 * * ? *)" # diário às 03:00 UTC
    lifecycle {
      cold_storage_after = 30
      delete_after       = 365
    }
  }
}

# Seleção baseada em TAG. Aplique a tag Backup=Daily nos recursos que deseja incluir.
resource "aws_backup_selection" "tagged" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.project_prefix}-backup-selection"
  plan_id      = aws_backup_plan.daily.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "Daily"
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.project_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "backup_service" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

#################
# Dados auxiliares (somente locais)
#################

#################
# Saídas
#################
output "s3_bucket_name" {
  value = aws_s3_bucket.archive.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.nightly_job.function_name
}

output "backup_vault_name" {
  value = aws_backup_vault.main.name
}
