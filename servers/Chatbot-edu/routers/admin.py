"""
Router pour les opérations administratives
Endpoint POST /ingest pour l'indexation des documents
"""

from fastapi import APIRouter, HTTPException, status, Body
from app.models import IngestRequest, IngestResponse
from services.ingest import ingest_documents
from services.rag import reset_vectorstore_cache
import logging

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/admin",
    tags=["Administration"],
    responses={404: {"description": "Not found"}}
)


@router.post(
    "/ingest",
    response_model=IngestResponse,
    status_code=status.HTTP_200_OK,
    summary="Indexer les documents PDF",
    description="""
    Lance le processus d'ingestion complet:
    1. Télécharge les PDFs depuis MinIO (ou utilise les PDFs locaux du dossier 'Cours')
    2. Extrait le texte avec PyPDFLoader
    3. Découpe en chunks avec RecursiveCharacterTextSplitter
    4. Génère les embeddings avec HuggingFace
    5. Crée et sauvegarde l'index FAISS
    
    **Par défaut**, utilise les PDFs du dossier 'Cours' local
    (plus rapide pour le développement).
    
    **Note:** Cette opération peut prendre plusieurs minutes selon le nombre de PDFs.
    """
)
async def ingest(
    request: IngestRequest = Body(
        default=IngestRequest(use_local_pdfs=True),
        description="Paramètres d'ingestion"
    )
) -> IngestResponse:
    """
    Endpoint pour lancer l'ingestion des documents
    
    Args:
        request: IngestRequest avec paramètres optionnels
        
    Returns:
        IngestResponse: Statistiques de l'ingestion
        
    Raises:
        HTTPException: Si erreur MinIO, parsing PDF, ou autre
    """
    try:
        logger.info(f"🚀 Ingestion lancée")
        logger.info(f"   Mode: {'PDFs locaux' if request.use_local_pdfs else 'MinIO'}")
        
        # Lancer l'ingestion
        stats = ingest_documents(
            use_local_pdfs=request.use_local_pdfs,
            local_pdf_dir=request.local_pdf_dir
        )
        
        # Réinitialiser le cache du vectorstore
        reset_vectorstore_cache()
        
        response = IngestResponse(
            status=stats["status"],
            files_processed=stats["files_processed"],
            total_pages=stats["total_pages"],
            total_chunks=stats["total_chunks"],
            message=f"Ingestion réussie: {stats['files_processed']} fichiers PDF indexés",
            index_path=stats["index_path"]
        )
        
        logger.info("✅ Ingestion terminée avec succès")
        return response
        
    except FileNotFoundError as e:
        logger.error(f"❌ Fichier/Dossier non trouvé: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dossier ou fichier non trouvé: {str(e)}"
        )
    
    except ValueError as e:
        logger.error(f"❌ Erreur de validation: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
    except Exception as e:
        logger.error(f"❌ Erreur lors de l'ingestion: {str(e)}", exc_info=True)
        
        # Déterminer le type d'erreur pour un message plus précis
        error_msg = str(e)
        if "minio" in error_msg.lower() or "s3" in error_msg.lower():
            detail = f"Erreur de connexion MinIO: {error_msg}"
            status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        elif "pdf" in error_msg.lower():
            detail = f"Erreur lors du parsing PDF: {error_msg}"
            status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
        else:
            detail = f"Erreur interne lors de l'ingestion: {error_msg}"
            status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        
        raise HTTPException(status_code=status_code, detail=detail)


@router.delete(
    "/cache",
    status_code=status.HTTP_200_OK,
    summary="Réinitialiser le cache du vectorstore",
    description="Force le rechargement de l'index FAISS au prochain appel"
)
async def clear_cache():
    """
    Endpoint pour vider le cache du vectorstore
    Utile après une réingestion
    """
    try:
        reset_vectorstore_cache()
        logger.info("🔄 Cache réinitialisé")
        return {"status": "success", "message": "Cache du vectorstore réinitialisé"}
    
    except Exception as e:
        logger.error(f"❌ Erreur lors de la réinitialisation du cache: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
