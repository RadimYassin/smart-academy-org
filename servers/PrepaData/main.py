from fastapi import FastAPI, HTTPException
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
import os

# Configuration
EUREKA_SERVER = "http://localhost:8761/eureka/"
APP_NAME = "PREPADATA-SERVICE"
INSTANCE_PORT = 8001

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Register with Eureka
    await eureka_client.init_async(
        eureka_server=EUREKA_SERVER,
        app_name=APP_NAME,
        instance_port=INSTANCE_PORT
    )
    print(f"{APP_NAME} registered with Eureka")
    yield
    # Shutdown: De-register (handled automatically by py-eureka-client usually, but good to know)
    print(f"{APP_NAME} stopping")

app = FastAPI(title="PrepaData Service", lifespan=lifespan)

@app.get("/")
def read_root():
    return {"message": "Welcome to PrepaData Service"}

@app.post("/process-data")
def process_data():
    # Placeholder for Airflow trigger or data processing logic
    return {"status": "Data processing started", "job_id": "12345"}

@app.get("/engagement-stats/{student_id}")
def get_engagement_stats(student_id: str):
    # Placeholder logic
    # In real app, query PostgreSQL
    mock_data = {
        "student_id": student_id,
        "engagement_score": 75.5,
        "modules_visited": 12,
        "quizzes_completed": 5
    }
    return mock_data

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
