import os
from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2
from google.cloud import bigquery

app = FastAPI()

DB_HOST = os.getenv("DB_HOST")
DB_USER = "postgres"
DB_PASS = "postgres"
DB_NAME = "postgres"

class Item(BaseModel):
    name: str

@app.get("/")
def root():
    return {"message": "Backend running 🚀"}

@app.post("/submit")
def submit(item: Item):
    # PostgreSQL write
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME
        )
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS items (name TEXT);")
        cur.execute("INSERT INTO items (name) VALUES (%s);", (item.name,))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        return {"db_error": str(e)}

    # BigQuery write
    try:
        client = bigquery.Client()
        table_id = "app_analytics.events"

        rows = [{
            "event_type": "submit",
            "value": item.name
        }]
        client.insert_rows_json(table_id, rows)
    except Exception as e:
        return {"bq_error": str(e)}

    return {"status": "stored"}