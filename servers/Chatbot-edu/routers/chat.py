"""
Router pour les interactions chat avec les étudiants
Endpoint POST /ask pour poser des questions
"""

from fastapi import APIRouter, HTTPException, status, File, UploadFile, Form
from typing import Optional
from app.models import QuestionRequest, AnswerResponse
from services.rag import ask_question
from services.audio_transcription import transcribe_audio
from services.image_processing import process_image_with_vision
import logging
import os
import base64

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
    
    **Exemple de question:**
    - "Qu'est-ce qu'une classe en Python ?"
    - "Comment fonctionne l'héritage en Java ?"
    - "Explique-moi les boucles for"
    """
)
async def ask(
    request: QuestionRequest
) -> AnswerResponse:
    """
    Endpoint pour poser une question
    
    Args:
        request: QuestionRequest contenant la question
        
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
        
        # Log question
        logger.info(f"📨 Question received: {request.question[:80]}...")
        
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


@router.post(
    "/audio",
    status_code=status.HTTP_200_OK,
    summary="Traiter un fichier audio",
    description="""
    Traite un fichier audio envoyé par l'utilisateur.
    Si une question est fournie, elle est utilisée directement.
    Sinon, une question par défaut est utilisée (l'utilisateur peut transcrire l'audio côté client).
    
    **Note**: La transcription audio côté serveur nécessite des dépendances optionnelles.
    Pour l'instant, utilisez le paramètre 'question' pour envoyer la transcription.
    """
)
async def process_audio(
    audio: UploadFile = File(...),
    question: Optional[str] = Form(None)
) -> dict:
    """
    Endpoint pour traiter un fichier audio
    
    Args:
        audio: Fichier audio (WAV, MP3, M4A, etc.)
        question: Question texte optionnelle (si fournie, utilisée directement)
        
    Returns:
        dict: Réponse avec transcription, answer, sources, et model_used
    """
    try:
        # Valider le fichier audio
        if not audio.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Fichier audio requis"
            )
        
        # Sauvegarder temporairement l'audio
        temp_audio_path = f"temp_audio_{os.urandom(8).hex()}_{audio.filename}"
        try:
            with open(temp_audio_path, "wb") as f:
                content = await audio.read()
                f.write(content)
            
            logger.info(f"📁 Audio reçu: {audio.filename} ({len(content)} bytes)")
            
            # Transcrire l'audio avec Whisper
            transcription = None
            try:
                logger.info("🎤 Début de la transcription avec Whisper...")
                transcription = transcribe_audio(temp_audio_path, language="fr")
                logger.info(f"✅ Transcription réussie: {transcription[:100]}...")
            except Exception as e:
                logger.error(f"❌ Erreur de transcription: {str(e)}")
                # Si la transcription échoue, utiliser la question fournie ou une question par défaut
                if question and question.strip():
                    transcription = question.strip()
                    logger.info("⚠️  Utilisation de la question fournie comme transcription")
                else:
                    transcription = "Audio message (transcription not available)"
                    logger.warning("⚠️  Transcription échouée et aucune question fournie")
            
            # Utiliser la transcription comme question
            user_question = transcription if transcription and transcription.strip() else "Please analyze this audio message"
            
            # Obtenir la réponse du chatbot
            result = ask_question(user_question)
            
            # Construire la réponse (format compatible avec AudioProcessingResponse)
            response_data = {
                "transcription": transcription if transcription else "Audio message (transcription not available)",
                "answer": result.get('answer', ''),
                "audio_url": "",  # Pas de génération audio pour l'instant (nécessite gTTS)
                "sources": result.get('sources', []),
                "model_used": result.get('model_used', 'unknown'),
                "num_sources": result.get('num_sources', 0)
            }
            
            logger.info(f"✅ Audio traité avec succès: {len(response_data['answer'])} caractères")
            
            return response_data
            
        finally:
            # Nettoyer le fichier temporaire
            if os.path.exists(temp_audio_path):
                try:
                    os.remove(temp_audio_path)
                    logger.info(f"🗑️  Fichier temporaire supprimé: {temp_audio_path}")
                except Exception as e:
                    logger.warning(f"⚠️  Impossible de supprimer le fichier temporaire: {e}")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erreur lors du traitement audio: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement audio: {str(e)}"
        )


@router.post(
    "/image",
    status_code=status.HTTP_200_OK,
    summary="Traiter une image",
    description="""
    Traite une image envoyée par l'utilisateur avec OpenAI Vision API.
    L'image est analysée et une description est générée.
    Si une question est fournie, le système utilise RAG pour répondre en se basant sur les cours.
    """
)
async def process_image(
    image: UploadFile = File(...),
    question: Optional[str] = Form(None)
) -> dict:
    """
    Endpoint pour traiter une image
    
    Args:
        image: Fichier image (JPG, PNG, GIF, WEBP)
        question: Question optionnelle de l'utilisateur
        
    Returns:
        dict: Réponse avec description, answer, sources, et model_used
    """
    try:
        # Valider le fichier image
        if not image.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Fichier image requis"
            )
        
        # Vérifier le type de fichier
        allowed_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
        file_ext = os.path.splitext(image.filename)[1].lower()
        if file_ext not in allowed_extensions:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Format d'image non supporté. Formats acceptés: {', '.join(allowed_extensions)}"
            )
        
        # Sauvegarder temporairement l'image
        temp_image_path = f"temp_image_{os.urandom(8).hex()}{file_ext}"
        try:
            with open(temp_image_path, "wb") as f:
                content = await image.read()
                f.write(content)
            
            logger.info(f"🖼️  Image reçue: {image.filename} ({len(content)} bytes)")
            
            # Traiter l'image avec Vision API
            result = process_image_with_vision(temp_image_path, question)
            
            # Construire la réponse
            response_data = {
                "image_description": result.get('image_description', ''),
                "answer": result.get('answer', ''),
                "sources": result.get('sources', []),
                "model_used": result.get('model_used', 'unknown'),
                "num_sources": result.get('num_sources', 0)
            }
            
            logger.info(f"✅ Image traitée avec succès: {len(response_data['answer'])} caractères")
            
            return response_data
            
        finally:
            # Nettoyer le fichier temporaire
            if os.path.exists(temp_image_path):
                try:
                    os.remove(temp_image_path)
                    logger.info(f"🗑️  Fichier temporaire supprimé: {temp_image_path}")
                except Exception as e:
                    logger.warning(f"⚠️  Impossible de supprimer le fichier temporaire: {e}")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erreur lors du traitement d'image: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement d'image: {str(e)}"
        )
