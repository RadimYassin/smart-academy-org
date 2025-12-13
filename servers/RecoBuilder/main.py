from fastapi import FastAPI, HTTPException, Depends
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
from auth.jwt_utils import verify_token, get_current_user_id
# import torch # Placeholder
# from transformers import BertModel, BertTokenizer # Placeholder
# import faiss # Placeholder

# Configuration
EUREKA_SERVER = "http://localhost:8761/eureka/"
APP_NAME = "RECOBUILDER-SERVICE"
INSTANCE_PORT = 8004

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

app = FastAPI(title="RecoBuilder Service", lifespan=lifespan)

@app.get("/")
def read_root():
    """Health check endpoint - publicly accessible"""
    return {"message": "Welcome to RecoBuilder Service", "status": "UP"}

@app.get("/recommend/{student_id}")
def recommend_resources(student_id: str, token_payload: dict = Depends(verify_token)):
    """
    Generate personalized learning recommendations - Protected endpoint
    Uses BERT/Faiss for content similarity matching
    """
    requesting_user = token_payload.get("sub")
    
    # Placeholder logic
    # 1. Fetch student profile from StudentProfiler
    # 2. Fetch student gaps from PrepaData
    # 3. Use BERT/Faiss to find relevant content
    return {
        "student_id": student_id,
        "recommendations": [
            {"type": "video", "title": "Statistics 101", "url": "http://..."},
            {"type": "exercise", "title": "Probability Quiz", "url": "http://..."}
        ],
        "generated_by": requesting_user
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
