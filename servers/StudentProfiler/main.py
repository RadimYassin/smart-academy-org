from fastapi import FastAPI, HTTPException
import uvicorn
import py_eureka_client.eureka_client as eureka_client
from contextlib import asynccontextmanager
import pandas as pd
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
    return {"message": "Welcome to StudentProfiler Service"}

@app.get("/profile-student/{student_id}")
def get_student_profile(student_id: str):
    # Placeholder logic
    # 1. Fetch data from PrepaData (via Gateway or direct)
    # 2. Apply ML model
    return {
        "student_id": student_id,
        "profile_type": "Procrastinator",
        "confidence": 0.85
    }

@app.post("/cluster-students")
def cluster_students():
    # Placeholder for KMeans clustering
    return {"status": "Clustering completed", "clusters_found": 3}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=INSTANCE_PORT)
