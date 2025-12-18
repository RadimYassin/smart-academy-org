"""
Router pour les interactions chat avec les étudiants
Endpoint POST /ask pour poser des questions
"""

from fastapi import APIRouter, HTTPException, status, Depends
from app.models import QuestionRequest, AnswerResponse
from services.rag import ask_question
from auth.jwt_utils import get_current_user, require_role  # NEW
import logging

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
    responses={404: {"description": "Not found"}}
)


@router.post(
    "/ask",
    response_model=AnswerResponse,
    status_code=status.HTTP_200_OK,
    summary="Poser une question à l'assistant pédagogique",
    description="""
    Permet à un étudiant de poser une question sur les cours.
    L'assistant utilise RAG pour chercher dans les documents vectorisés
    et répond selon une approche socratique (pédagogique).
    
    **Authentification requise** - Token JWT nécessaire
    
    **Exemple de question:**
    - "Qu'est-ce qu'une classe en Python ?"
    - "Comment fonctionne l'héritage en Java ?"
    - "Explique-moi les boucles for"
    """
)
async def ask(
    request: QuestionRequest,
    current_user: dict = Depends(get_current_user)  # NEW: JWT Authentication
) -> AnswerResponse:
    """
    Endpoint pour poser une question
    
    Args:
        request: QuestionRequest contenant la question
        current_user: User info from JWT token
        
    Returns:
        AnswerResponse: Réponse avec answer et sources
        
    Raises:
        HTTPException: Si l'index FAISS n'est pas trouvé ou erreur interne
    """
    try:
        # Valider que la question n'est pas vide
        if not request.question.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La question ne peut pas être vide"
            )
        
        # NEW: Log with user context
        logger.info(f"📨 Question from user {current_user['userId']} ({current_user['email']}): {request.question[:80]}...")
        
        # Appeler le moteur RAG
        result = ask_question(request.question)
        
        # Convertir en modèle Pydantic
        response = AnswerResponse(**result)
        
        logger.info(f"✅ Réponse envoyée ({response.num_sources} sources)")
        return response
        
    except FileNotFoundError as e:
        logger.error(f"❌ Index FAISS non trouvé: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="L'index de recherche n'est pas disponible. Veuillez lancer l'ingestion d'abord (POST /admin/ingest)"
        )
    
    except ValueError as e:
        logger.error(f"❌ Erreur de validation: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
    except Exception as e:
        logger.error(f"❌ Erreur interne: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement de la question: {str(e)}"
        )
