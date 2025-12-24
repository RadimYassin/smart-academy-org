"""
StudentProfiler Microservice - FastAPI Application
Student Clustering and Profiling Service
Port: 8002
"""

import sys
import os
import logging
from contextlib import asynccontextmanager
from typing import Dict, Any, Optional
import pandas as pd

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from shared.eureka_client import register_with_eureka
from src.pipeline import StudentProfiler

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

SERVICE_PORT = int(os.getenv('SERVICE_PORT', 8002))
EUREKA_SERVER = os.getenv('EUREKA_SERVER_URL', 'http://localhost:8761/eureka')


# Pydantic models
class ProfileStudentsRequest(BaseModel):
    data: list[dict]
    n_clusters: int = 4


class ProfileStudentsResponse(BaseModel):
    status: str
    message: str
    student_profiles: list[dict]
    cluster_statistics: Dict[str, Any]


class StudentClusterResponse(BaseModel):
    student_id: int
    cluster: int
    cluster_interpretation: str
    average_grade: float
    failure_rate: float


class HealthResponse(BaseModel):
    status: str
    service: str
    port: int


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    logger.info("=" * 70)
    logger.info("🚀 StudentProfiler Service Starting")
    logger.info("=" * 70)
    logger.info(f"Port: {SERVICE_PORT}")
    
    register_with_eureka(
        app_name="studentprofiler-service",
        port=SERVICE_PORT,
        eureka_server=EUREKA_SERVER
    )
    
    # Start heartbeat task
    import asyncio
    from shared.eureka_client import send_heartbeat
    import socket
    
    hostname = socket.gethostname()
    instance_id = f"{hostname}:studentprofiler-service:{SERVICE_PORT}"
    heartbeat_task = None
    
    async def send_heartbeats():
        """Send periodic heartbeats to Eureka"""
        while True:
            try:
                await asyncio.sleep(30)
                send_heartbeat("studentprofiler-service", instance_id, EUREKA_SERVER)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Heartbeat error: {e}")
    
    heartbeat_task = asyncio.create_task(send_heartbeats())
    
    yield
    
    # Shutdown
    if heartbeat_task:
        heartbeat_task.cancel()
        try:
            await heartbeat_task
        except asyncio.CancelledError:
            pass
    logger.info("🛑 StudentProfiler Service Shutting Down")


app = FastAPI(
    title="StudentProfiler Service",
    description="Student Clustering and Profiling Microservice",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "StudentProfiler",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "profile_students": "/api/v1/profile-students",
            "get_cluster": "/api/v1/clusters/{student_id}"
        }
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        service="studentprofiler-service",
        port=SERVICE_PORT
    )


@app.post("/api/v1/profile-students", response_model=ProfileStudentsResponse)
async def profile_students(request: ProfileStudentsRequest):
    """
    Profile students using K-Means clustering
    
    - Aggregates student data
    - Performs clustering
    - Returns student profiles with cluster assignments
    """
    try:
        logger.info(f"Received profiling request with {len(request.data)} records")
        
        df = pd.DataFrame(request.data)
        
        profiler = StudentProfiler(df)
        student_profiles = profiler.run_all(n_clusters=request.n_clusters)
        
        # Calculate cluster statistics
        cluster_stats = {}
        for cluster_id in sorted(student_profiles['Cluster'].unique()):
            cluster_data = student_profiles[student_profiles['Cluster'] == cluster_id]
            cluster_stats[f"cluster_{cluster_id}"] = {
                "count": len(cluster_data),
                "avg_grade": float(cluster_data['Average_Grade'].mean()),
                "avg_failure_rate": float(cluster_data['Failure_Rate'].mean()),
                "avg_absences": float(cluster_data['Absence_Count'].mean())
            }
        
        profiles_dict = student_profiles.to_dict('records')
        
        logger.info(f"✅ Profiled {len(profiles_dict)} students into {request.n_clusters} clusters")
        
        return ProfileStudentsResponse(
            status="success",
            message=f"Successfully profiled {len(profiles_dict)} students",
            student_profiles=profiles_dict,
            cluster_statistics=cluster_stats
        )
        
    except Exception as e:
        logger.error(f"❌ Error profiling students: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Student profiling failed: {str(e)}"
        )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    logger.error(f"❌ Unhandled exception: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": f"Internal server error: {str(exc)}"}
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main_profiler:app",
        host="0.0.0.0",
        port=SERVICE_PORT,
        reload=True
    )
