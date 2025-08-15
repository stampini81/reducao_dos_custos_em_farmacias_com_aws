import os
import json
from datetime import datetime, timezone

def lambda_handler(event, context):
    # Exemplo de rotina: escreve um log simples (substitua pela sua regra de negócio)
    bucket = os.getenv("BUCKET_NAME", "")
    now = datetime.now(timezone.utc).isoformat()
    message = {
        "status": "ok",
        "timestamp": now,
        "bucket": bucket,
        "note": "Rotina noturna executada com sucesso"
    }
    print(json.dumps(message))
    return message
