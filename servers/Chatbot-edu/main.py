"""
EduBot - Application FastAPI principale
Assistant Pédagogique Intelligent avec RAG
"""

import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from core.config import settings
from app.models import HealthResponse
from routers import chat, admin
from auth.eureka_reg import register_with_eureka  # NEW
# from api import multimedia_routes  # Commented out - requires optional dependencies

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('edubot.log')
    ]
)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Gestionnaire du cycle de vie de l'application
    Exécuté au démarrage et à l'arrêt
    """
    # Startup
    logger.info("=" * 70)
    logger.info("🚀 DÉMARRAGE D'EDUBOT - ASSISTANT PÉDAGOGIQUE INTELLIGENT")
    logger.info("=" * 70)
    logger.info(f"📌 Version: {settings.app_version}")
    logger.info(f"🤖 LLM Provider: {settings.llm_provider}")
    logger.info(f"🧠 Modèle: {settings.openai_model if settings.llm_provider == 'openai' else settings.ollama_model}")
    logger.info(f"📊 Index FAISS: {settings.faiss_index_path}")
    
    # Vérifier si l'index FAISS existe
    if os.path.exists(settings.faiss_index_path):
        logger.info("✅ Index FAISS trouvé - Prêt à répondre aux questions")
    else:
        logger.warning("⚠️  Index FAISS non trouvé - Veuillez lancer l'ingestion (POST /admin/ingest)")
    
    # NEW: Register with Eureka
    eureka_server = os.getenv("EUREKA_SERVER_URL", "http://localhost:8761/eureka")
    service_port = int(os.getenv("SERVICE_PORT", "8005"))
    register_with_eureka(
        app_name="chatbot-edu-service",
        port=service_port,
        eureka_server=eureka_server
    )
    
    logger.info("=" * 70)
    
    yield  # L'application s'exécute ici
    
    # Shutdown
    logger.info("🛑 Arrêt d'EduBot...")


# Création de l'application FastAPI
app = FastAPI(
    title=settings.app_title,
    version=settings.app_version,
    description="""
    ## EduBot - Assistant Pédagogique Intelligent
    
    Microservice basé sur RAG (Retrieval Augmented Generation) pour répondre aux questions 
    des étudiants en utilisant une approche socratique.
    
    ### Fonctionnalités:
    
    * **Chat** - Poser des questions sur les cours (approche socratique)
    * **Administration** - Indexer les documents PDF (MinIO ou local)
    
    ### Workflow:
    
    1. **Indexation**: `POST /admin/ingest` pour créer l'index FAISS
    2. **Questions**: `POST /chat/ask` pour poser des questions
    
    ### Stack Technique:
    
    - Framework: FastAPI
    - Orchestration IA: LangChain
    - Vector Store: FAISS
    - Embeddings: HuggingFace (all-MiniLM-L6-v2)
    - LLM: OpenAI GPT-4o-mini (ou Ollama)
    - Storage: MinIO
    """,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À restreindre en production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Inclusion des routers
app.include_router(chat.router)
app.include_router(admin.router)
# app.include_router(multimedia_routes.router)  # Commented out - requires additional dependencies


@app.get(
    "/",
    summary="Page d'accueil",
    description="Retourne les informations de base sur l'API"
)
async def root():
    """
    Endpoint racine
    """
    return {
        "name": settings.app_title,
        "version": settings.app_version,
        "status": "running",
        "docs": "/docs",
        "endpoints": {
            "health": "/health",
            "ask_question": "/chat/ask",
            "ingest_documents": "/admin/ingest"
        }
    }


@app.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Health check",
    description="Vérifie l'état de santé de l'application"
)
async def health_check() -> HealthResponse:
    """
    Endpoint de health check
    Vérifie que l'application fonctionne et que l'index FAISS existe
    """
    faiss_exists = os.path.exists(settings.faiss_index_path)
    
    model = (
        settings.openai_model 
        if settings.llm_provider == "openai" 
        else settings.ollama_model
    )
    
    return HealthResponse(
        status="healthy" if faiss_exists else "degraded",
        faiss_index_exists=faiss_exists,
        llm_provider=settings.llm_provider,
        model=model
    )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """
    Gestionnaire global des exceptions non gérées
    """
    logger.error(f"❌ Exception non gérée: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": "Une erreur interne s'est produite",
            "error": str(exc)
        }
    )


if __name__ == "__main__":
    import uvicorn
    
    # Lancement du serveur
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
