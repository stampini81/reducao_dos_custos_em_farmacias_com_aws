variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefixo para nomeação dos recursos"
  type        = string
  default     = "farmacorp"
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos"
  type        = bool
  default     = false
}

variable "glacier_transition_days" {
  description = "Dias para transição dos objetos para Glacier Deep Archive"
  type        = number
  default     = 30
}

variable "nightly_cron" {
  description = "Expressão CRON do EventBridge para executar a Lambda"
  type        = string
  default     = "cron(0 2 * * ? *)" # 02:00 UTC diariamente
}

variable "offline_mode" {
  description = "Quando true, evita validar credenciais AWS para permitir plano offline"
  type        = bool
  default     = true
}
