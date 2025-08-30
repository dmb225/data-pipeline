import os
import json
import base64
import psycopg2
from psycopg2.extras import RealDictCursor

# Environment variables (set by Terraform)
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_DB = os.getenv("POSTGRES_DB", "data_pipeline")
POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")


def get_conn():
    return psycopg2.connect(
        host=POSTGRES_HOST,
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        cursor_factory=RealDictCursor
    )


def pubsub_handler(event, context):
    data_str = event.get("data", "")

    # Base64 decode if string
    if isinstance(data_str, str):
        try:
            data_str = base64.b64decode(data_str).decode("utf-8")
        except Exception as e:
            print(f"⚠️ Could not base64 decode: {data_str}, error: {e}")
            return

    if not data_str:
        print("⚠️ Empty message received, skipping")
        return

    try:
        data = json.loads(data_str)
    except json.JSONDecodeError:
        print(f"❌ Failed to parse JSON after decode: {data_str}")
        return

    print(f"✅ Received: {data}")

    processed = {"id": data["id"], "value": data["value"].upper()}

    conn = get_conn()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS processed_data (
            id INT,
            value TEXT
        );
    """)

    cursor.execute(
        "INSERT INTO processed_data (id, value) VALUES (%s, %s);",
        (processed["id"], processed["value"])
    )

    conn.commit()
    cursor.close()
    conn.close()

    print(f"✅ Processed and inserted: {processed}")
