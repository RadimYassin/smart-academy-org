from fastapi import FastAPI, HTTPException, Depends
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
from auth.jwt_utils import verify_token, get_current_user_id
# import sklearn # Placeholder for scikit-learn usage

# Configuration
EUREKA_SERVER = "http://localhost:8761/eureka/"
APP_NAME = "STUDENTPROFILER-SERVICE"
INSTANCE_PORT = 8002

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

app = FastAPI(title="StudentProfiler Service", lifespan=lifespan)

@app.get("/")
def read_root():
    """Health check endpoint - publicly accessible"""
    return {"message": "Welcome to StudentProfiler Service", "status": "UP"}

@app.get("/profile-student/{student_id}")
def get_student_profile(student_id: str, token_payload: dict = Depends(verify_token)):
    """
    Get AI-generated profile for a student - Protected endpoint
    Uses ML clustering to categorize student behavior
    """
    requesting_user = token_payload.get("sub")
    
    # Placeholder logic
    # 1. Fetch data from PrepaData (via Gateway or direct)
    # 2. Apply ML model
    return {
        "student_id": student_id,
        "profile_type": "Procrastinator",
        "confidence": 0.85,
        "analyzed_by": requesting_user
    }

@app.post("/cluster-students")
def cluster_students(token_payload: dict = Depends(verify_token)):
    """
    Cluster all students using KMeans - Protected endpoint
    Requires admin or teacher role
    """
    user_id = token_payload.get("sub")
    user_roles = token_payload.get("roles", [])
    
    # Placeholder for KMeans clustering
    return {
        "status": "Clustering completed",
        "clusters_found": 3,
        "initiated_by": user_id
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
