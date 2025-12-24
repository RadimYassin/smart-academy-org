"""
RecoBuilder Microservice - FastAPI Application
Personalized Recommendations Service using OpenAI + FAISS
Port: 8004
"""

import sys
import os
import logging
from contextlib import asynccontextmanager
from typing import Dict, Any, List, Optional
import pandas as pd

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from shared.eureka_client import register_with_eureka
from src.recobuilder import RecoBuilder

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

SERVICE_PORT = int(os.getenv('SERVICE_PORT', 8004))
EUREKA_SERVER = os.getenv('EUREKA_SERVER_URL', 'http://localhost:8761/eureka')
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')

# Global RecoBuilder instance
recommender = None


# Pydantic models
class BuildIndexRequest(BaseModel):
    resources_path: str


class RecommendRequest(BaseModel):
    student_id: int
    profile_data: dict
    cleaned_data: list[dict]


class SearchResourcesRequest(BaseModel):
    query: str
    k: int = 5
    subject_filter: Optional[str] = None


class HealthResponse(BaseModel):
    status: str
    service: str
    port: int
    index_built: bool
    openai_configured: bool


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    logger.info("=" * 70)
    logger.info("🚀 RecoBuilder Service Starting")
    logger.info("=" * 70)
    logger.info(f"Port: {SERVICE_PORT}")
    
    if not OPENAI_API_KEY:
        logger.warning("⚠️  OPENAI_API_KEY not configured. Service will have limited functionality.")
    
    register_with_eureka(
        app_name="recobuilder-service",
        port=SERVICE_PORT,
        eureka_server=EUREKA_SERVER
    )
    
    # Start heartbeat task
    import asyncio
    from shared.eureka_client import send_heartbeat
    import socket
    
    hostname = socket.gethostname()
    instance_id = f"{hostname}:recobuilder-service:{SERVICE_PORT}"
    heartbeat_task = None
    
    async def send_heartbeats():
        """Send periodic heartbeats to Eureka"""
        while True:
            try:
                await asyncio.sleep(30)
                send_heartbeat("recobuilder-service", instance_id, EUREKA_SERVER)
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
    logger.info("🛑 RecoBuilder Service Shutting Down")


app = FastAPI(
    title="RecoBuilder Service",
    description="Personalized Recommendations Microservice using OpenAI + FAISS",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "RecoBuilder",
        "version": "1.0.0",
        "status": "running",
        "index_built": recommender is not None and recommender.faiss_index is not None,
        "openai_configured": OPENAI_API_KEY is not None,
        "endpoints": {
            "health": "/health",
            "build_index": "/api/v1/build-index",
            "recommend": "/api/v1/recommend",
            "search_resources": "/api/v1/search-resources"
        }
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy" if OPENAI_API_KEY else "degraded",
        service="recobuilder-service",
        port=SERVICE_PORT,
        index_built=recommender is not None and recommender.faiss_index is not None,
        openai_configured=OPENAI_API_KEY is not None
    )


@app.post("/api/v1/build-index")
async def build_index(request: BuildIndexRequest):
    """
    Build FAISS index from educational resources
    """
    global recommender
    
    if not OPENAI_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="OPENAI_API_KEY not configured"
        )
    
    try:
        logger.info(f"Building FAISS index from {request.resources_path}")
        
        recommender = RecoBuilder(api_key=OPENAI_API_KEY)
        recommender.load_resources(request.resources_path)
        recommender.build_faiss_index()
        
        return {
            "status": "success",
            "message": f"FAISS index built with {len(recommender.resources)} resources",
            "resource_count": len(recommender.resources)
        }
        
    except Exception as e:
        logger.error(f"❌ Error building index: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to build index: {str(e)}"
        )


@app.post("/api/v1/recommend")
async def recommend(request: RecommendRequest):
    """
    Generate personalized recommendations for a student
    """
    if recommender is None or recommender.faiss_index is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="FAISS index not built. Call /api/v1/build-index first."
        )
    
    try:
        logger.info(f"Generating recommendations for student {request.student_id}")
        
        # Convert to DataFrame
        df_clean = pd.DataFrame(request.cleaned_data)
        df_profiles = pd.DataFrame([request.profile_data]) if request.profile_data else None
        
        # Analyze student profile
        profile = recommender.analyze_student_profile(
            request.student_id,
            df_clean,
            df_profiles
        )
        
        if profile is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student {request.student_id} not found"
            )
        
        # Generate recommendations
        recommendations = recommender.generate_recommendations(profile)
        
        return {
            "status": "success",
            "student_id": request.student_id,
            "recommendations": recommendations
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error generating recommendations: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate recommendations: {str(e)}"
        )


@app.post("/api/v1/search-resources")
async def search_resources(request: SearchResourcesRequest):
    """
    Search for educational resources using semantic similarity
    """
    if recommender is None or recommender.faiss_index is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="FAISS index not built. Call /api/v1/build-index first."
        )
    
    try:
        results = recommender.search_similar_resources(
            query=request.query,
            k=request.k,
            subject_filter=request.subject_filter
        )
        
        return {
            "status": "success",
            "query": request.query,
            "results": results
        }
        
    except Exception as e:
        logger.error(f"❌ Error searching resources: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Resource search failed: {str(e)}"
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
        "main_recobuilder:app",
        host="0.0.0.0",
        port=SERVICE_PORT,
        reload=True
    )
