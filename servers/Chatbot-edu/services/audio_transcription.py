"""
Service de transcription audio utilisant OpenAI Whisper
"""

import logging
import os
from openai import OpenAI
from core.config import settings

logger = logging.getLogger(__name__)

def transcribe_audio(audio_file_path: str, language: str = "fr") -> str:
    """
    Transcrit un fichier audio en texte en utilisant OpenAI Whisper
    
    Args:
        audio_file_path: Chemin vers le fichier audio
        language: Code de langue (fr, en, etc.)
        
    Returns:
        str: Texte transcrit
        
    Raises:
        Exception: Si la transcription échoue
    """
    try:
        if not settings.openai_api_key:
            raise Exception("OpenAI API key not configured")
        
        client = OpenAI(api_key=settings.openai_api_key)
        
        logger.info(f"🎤 Transcription de l'audio: {audio_file_path}")
        
        with open(audio_file_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                language=language,
                response_format="text"
            )
        
        # Si response_format="text", transcript est directement une string
        transcription_text = transcript if isinstance(transcript, str) else getattr(transcript, 'text', str(transcript))
        logger.info(f"✅ Transcription réussie: {transcription_text[:100]}...")
        
        return transcription_text
        
    except Exception as e:
        logger.error(f"❌ Erreur lors de la transcription: {str(e)}")
        raise Exception(f"Erreur de transcription: {str(e)}")

