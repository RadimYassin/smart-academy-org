"""
PrepaData Microservice - FastAPI Application
Data Preprocessing and Cleaning Service
Port: 8001
"""

import sys
import os
import logging
from contextlib import asynccontextmanager
from typing import Dict, Any
import pandas as pd

# Add parent directories to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from shared.eureka_client import register_with_eureka
from src.pipeline import PrepaData

# Logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Environment variables
SERVICE_PORT = int(os.getenv('SERVICE_PORT', 8001))
EUREKA_SERVER = os.getenv('EUREKA_SERVER_URL', 'http://localhost:8761/eureka')


# Pydantic models
class CleanDataRequest(BaseModel):
    data: list[dict]
    threshold: int = 10


class CleanDataResponse(BaseModel):
    status: str
    message: str
    cleaned_data: list[dict]
    statistics: Dict[str, Any]


class HealthResponse(BaseModel):
    status: str
    service: str
    port: int


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup
    logger.info("=" * 70)
    logger.info("🚀 PrepaData Service Starting")
    logger.info("=" * 70)
    logger.info(f"Port: {SERVICE_PORT}")
    logger.info(f"Eureka: {EUREKA_SERVER}")
    
    # Register with Eureka
    register_with_eureka(
        app_name="prepadata-service",
        port=SERVICE_PORT,
        eureka_server=EUREKA_SERVER
    )
    
    # Start heartbeat task
    import asyncio
    from shared.eureka_client import send_heartbeat
    import socket
    
    hostname = socket.gethostname()
    instance_id = f"{hostname}:prepadata-service:{SERVICE_PORT}"
    heartbeat_task = None
    
    async def send_heartbeats():
        """Send periodic heartbeats to Eureka"""
        while True:
            try:
                await asyncio.sleep(30)  # Send heartbeat every 30 seconds
                send_heartbeat("prepadata-service", instance_id, EUREKA_SERVER)
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
    logger.info("🛑 PrepaData Service Shutting Down")


# FastAPI application
app = FastAPI(
    title="PrepaData Service",
    description="Data Preprocessing and Cleaning Microservice",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "PrepaData",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "clean_data": "/api/v1/clean-data"
        }
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        service="prepadata-service",
        port=SERVICE_PORT
    )


@app.post("/api/v1/clean-data", response_model=CleanDataResponse)
async def clean_data(request: CleanDataRequest):
    """
    Clean and prepare student data
    
    - Recalculates Total column
    - Encodes Subject column
    - Creates is_fail target variable
    """
    try:
        logger.info(f"Received data cleaning request with {len(request.data)} records")
        
        # Convert to DataFrame
        df = pd.DataFrame(request.data)
        
        # Initialize PrepaData
        preparer = PrepaData(df)
        
        # Run all preprocessing steps
        df_clean = preparer.run_all(threshold=request.threshold)
        
        # Calculate statistics
        statistics = {
            "total_records": len(df_clean),
            "total_failures": int(df_clean['is_fail'].sum()),
            "failure_rate": float((df_clean['is_fail'].sum() / len(df_clean)) * 100),
            "unique_subjects": int(df_clean['Subject'].nunique()),
            "unique_students": int(df_clean['ID'].nunique()) if 'ID' in df_clean.columns else 0
        }
        
        # Convert back to dict
        cleaned_data = df_clean.to_dict('records')
        
        logger.info(f"✅ Data cleaned successfully. Failure rate: {statistics['failure_rate']:.2f}%")
        
        return CleanDataResponse(
            status="success",
            message=f"Successfully cleaned {len(cleaned_data)} records",
            cleaned_data=cleaned_data,
            statistics=statistics
        )
        
    except Exception as e:
        logger.error(f"❌ Error cleaning data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Data cleaning failed: {str(e)}"
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
        "main_prepadata:app",
        host="0.0.0.0",
        port=SERVICE_PORT,
        reload=True
    )
