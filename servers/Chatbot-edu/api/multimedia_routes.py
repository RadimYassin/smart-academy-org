"""
Extended API Endpoints for Audio and Image
"""

from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
import base64
from pathlib import Path

# Import services
from services.rag import ask_question
import speech_recognition as sr
from gtts import gTTS
import google.generativeai as genai

router = APIRouter(prefix="/chat", tags=["chat"])

# Models
class ImageAnalysisResponse(BaseModel):
    analysis: str
    question: str
    model_used: str = "gpt-4o"

class AudioResponse(BaseModel):
    transcription: str
    answer: str
    audio_url: str
    sources: list
    model_used: str

# ==================== IMAGE ENDPOINT ====================

@router.post("/image", response_model=ImageAnalysisResponse)
async def analyze_image(
    image: UploadFile = File(...),
    question: str = Form(...)
):
    """
    Analyse une image avec GPT-4o Vision
    
    - **image**: Fichier image (JPG, PNG, GIF, WebP)
    - **question**: Question sur l'image
    """
    
    # Vérifier le type de fichier
    allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    if image.content_type not in allowed_types:
        raise HTTPException(400, "Type de fichier non supporté")
    
    try:
        # Sauvegarder temporairement l'image
        temp_path = f"temp_{image.filename}"
        with open(temp_path, "wb") as f:
            f.write(await image.read())
        
        # Analyser avec Gemini ou OpenAI Vision
        from core.config import settings
        
        if settings.llm_provider == "openai":
            # OpenAI Vision
            from openai import OpenAI
            client = OpenAI(api_key=settings.openai_api_key)
            
            # Encoder l'image en base64
            with open(temp_path, "rb") as img_file:
                img_base64 = base64.b64encode(img_file.read()).decode()
            
            response = client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": question},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{img_base64}"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=1000
            )
            
            analysis = response.choices[0].message.content
            model_used = "gpt-4o"
        
        else:
            # Gemini Vision
            import PIL.Image
            genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
            
            img = PIL.Image.open(temp_path)
            model = genai.GenerativeModel('gemini-1.5-flash')
            
            response = model.generate_content([question, img])
            analysis = response.text
            model_used = "gemini-1.5-flash"
        
        # Nettoyer
        os.remove(temp_path)
        
        return ImageAnalysisResponse(
            analysis=analysis,
            question=question,
            model_used=model_used
        )
        
    except Exception as e:
        # Nettoyer en cas d'erreur
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise HTTPException(500, f"Erreur: {str(e)}")


# ==================== AUDIO ENDPOINT ====================

@router.post("/audio", response_model=AudioResponse)
async def process_audio(
    audio: UploadFile = File(...),
    question: Optional[str] = Form(None)
):
    """
    Traite un fichier audio:
    1. Transcrit l'audio (si question non fournie)
    2. Obtient une réponse du chatbot
    3. Génère une réponse audio
    
    - **audio**: Fichier audio (WAV, MP3, etc.)
    - **question**: Question texte optionnelle (si fournie, skip transcription)
    """
    
    temp_audio = f"temp_{audio.filename}"
    response_audio = "response_audio.mp3"
    
    try:
        # Sauvegarder l'audio
        with open(temp_audio, "wb") as f:
            f.write(await audio.read())
        
        # Étape 1: Transcription (si pas de question fournie)
        if not question:
            recognizer = sr.Recognizer()
            
            with sr.AudioFile(temp_audio) as source:
                audio_data = recognizer.record(source)
                question = recognizer.recognize_google(audio_data, language='fr-FR')
        
        # Étape 2: Obtenir la réponse
        result = ask_question(question)
        
        # Étape 3: Générer audio de réponse
        answer_text = result['answer'][:500]  # Limiter pour TTS
        
        tts = gTTS(answer_text, lang='fr')
        tts.save(response_audio)
        
        # Encoder l'audio en base64
        with open(response_audio, "rb") as f:
            audio_base64 = base64.b64encode(f.read()).decode()
        
        # Nettoyer les fichiers temporaires
        os.remove(temp_audio)
        os.remove(response_audio)
        
        return AudioResponse(
            transcription=question,
            answer=result['answer'],
            audio_url=f"data:audio/mp3;base64,{audio_base64}",
            sources=result['sources'],
            model_used=result['model_used']
        )
        
    except Exception as e:
        # Nettoyer
        for f in [temp_audio, response_audio]:
            if os.path.exists(f):
                os.remove(f)
        raise HTTPException(500, f"Erreur: {str(e)}")
