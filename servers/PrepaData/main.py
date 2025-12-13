from fastapi import FastAPI, HTTPException, Depends
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
import os
from auth.jwt_utils import verify_token, get_current_user_id

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
    """Health check endpoint - publicly accessible"""
    return {"message": "Welcome to PrepaData Service", "status": "UP"}

@app.post("/process-data")
def process_data(token_payload: dict = Depends(verify_token)):
    """
    Process data - Protected endpoint requiring JWT authentication
    Triggers Airflow or data processing logic
    """
    user_id = token_payload.get("sub")
    # Placeholder for Airflow trigger or data processing logic
    return {
        "status": "Data processing started",
        "job_id": "12345",
        "initiated_by": user_id
    }

@app.get("/engagement-stats/{student_id}")
def get_engagement_stats(student_id: str, token_payload: dict = Depends(verify_token)):
    """
    Get engagement statistics for a student - Protected endpoint
    Requires valid JWT token from User-Management service
    """
    # Validate user has permission to view this student's data
    requesting_user = token_payload.get("sub")
    
    # Placeholder logic
    # In real app, query PostgreSQL
    mock_data = {
        "student_id": student_id,
        "engagement_score": 75.5,
        "modules_visited": 12,
        "quizzes_completed": 5,
        "requested_by": requesting_user
    }
    return mock_data

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
