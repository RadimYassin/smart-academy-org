"""
Main FastAPI application with Eureka registration
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import py_eureka_client.eureka_client as eureka_client

from app.config import settings
from app.routers import prepadata, profiler, predictor, recommender


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Startup and shutdown events for the application
    """
    # Startup: Register with Eureka
    print(f"🚀 Registering {settings.APP_NAME} with Eureka at {settings.EUREKA_SERVER}")
    
    try:
        await eureka_client.init_async(
            eureka_server=settings.EUREKA_SERVER,
            app_name=settings.APP_NAME,
            instance_port=settings.APP_PORT,
            instance_host=settings.APP_HOST,
            # Health check endpoint
            health_check_url=f"http://{settings.APP_HOST}:{settings.APP_PORT}/health",
            # Status page
            status_page_url=f"http://{settings.APP_HOST}:{settings.APP_PORT}/info",
            # Home page
            home_page_url=f"http://{settings.APP_HOST}:{settings.APP_PORT}/",
        )
        print(f"✅ {settings.APP_NAME} registered with Eureka successfully!")
    except Exception as e:
        print(f"⚠️ Failed to register with Eureka: {e}")
        print("   Continuing without Eureka registration...")
    
    yield
    
    # Shutdown: Deregister from Eureka
    print(f"👋 Deregistering {settings.APP_NAME} from Eureka...")
    try:
        await eureka_client.stop_async()
        print("✅ Deregistered from Eureka")
    except Exception as e:
        print(f"⚠️ Error during Eureka deregistration: {e}")


# Create FastAPI app
app = FastAPI(
    title="EduPath AI Services API",
    description="REST API wrapper for Python AI/ML services (PrepaData, StudentProfiler, PathPredictor, RecoBuilder)",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration - DISABLED: Gateway handles CORS
# Uncomment only if accessing AI Services directly (bypassing Gateway)
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# Include routers
app.include_router(prepadata.router, prefix="/api/prepadata", tags=["PrepaData"])
app.include_router(profiler.router, prefix="/api/profiler", tags=["StudentProfiler"])
app.include_router(predictor.router, prefix="/api/predictor", tags=["PathPredictor"])
app.include_router(recommender.router, prefix="/api/recommender", tags=["RecoBuilder"])


# Health check endpoint (required by Eureka)
@app.get("/health")
async def health_check():
    """Health check endpoint for Eureka"""
    return {
        "status": "UP",
        "service": settings.APP_NAME,
        "port": settings.APP_PORT
    }


@app.get("/info")
async def info():
    """Service information endpoint"""
    return {
        "app": "EduPath AI Services",
        "version": "1.0.0",
        "description": "AI/ML microservices for learning analytics",
        "services": [
            "PrepaData - Data cleaning and normalization",
            "StudentProfiler - Student clustering (K-Means)",
            "PathPredictor - Failure prediction (XGBoost 99% accuracy)",
            "RecoBuilder - AI recommendations (GPT-4 + FAISS)"
        ]
    }


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "EduPath AI Services API",
        "docs": "/docs",
        "health": "/health",
        "info": "/info",
        "swagger_ui": "/docs",
        "redoc": "/redoc"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.APP_PORT,
        reload=True
    )
