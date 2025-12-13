from fastapi import FastAPI, HTTPException, Depends
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
from auth.jwt_utils import verify_token, get_current_user_id
# import xgboost as xgb # Placeholder
# import mlflow # Placeholder

# Configuration
EUREKA_SERVER = "http://localhost:8761/eureka/"
APP_NAME = "PATHPREDICTOR-SERVICE"
INSTANCE_PORT = 8003

@asynccontextmanager
async def lifespan(app: FastAPI):
    await eureka_client.init_async(
        eureka_server=EUREKA_SERVER,
        app_name=APP_NAME,
        instance_port=INSTANCE_PORT
    )
    print(f"{APP_NAME} registered with Eureka")
    yield
    print(f"{APP_NAME} stopping")

app = FastAPI(title="PathPredictor Service", lifespan=lifespan)

@app.get("/")
def read_root():
    """Health check endpoint - publicly accessible"""
    return {"message": "Welcome to PathPredictor Service", "status": "UP"}

@app.get("/predict-risk/{student_id}")
def predict_risk(student_id: str, token_payload: dict = Depends(verify_token)):
    """
    Predict student failure risk using XGBoost - Protected endpoint
    Returns risk level and success probability
    """
    requesting_user = token_payload.get("sub")
    
    # Placeholder logic
    # 1. Fetch features from PrepaData
    # 2. Load XGBoost model
    # 3. Predict
    return {
        "student_id": student_id,
        "risk_level": "High",
        "success_probability": 0.35,
        "alert_sent": True,
        "analyzed_by": requesting_user
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
