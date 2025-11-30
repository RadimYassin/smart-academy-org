from fastapi import FastAPI, HTTPException
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
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
    return {"message": "Welcome to RecoBuilder Service"}

@app.get("/recommend/{student_id}")
def recommend_resources(student_id: str):
    # Placeholder logic
    # 1. Fetch student profile from StudentProfiler
    # 2. Fetch student gaps from PrepaData
    # 3. Use BERT/Faiss to find relevant content
    return {
        "student_id": student_id,
        "recommendations": [
            {"type": "video", "title": "Statistics 101", "url": "http://..."},
            {"type": "exercise", "title": "Probability Quiz", "url": "http://..."}
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
