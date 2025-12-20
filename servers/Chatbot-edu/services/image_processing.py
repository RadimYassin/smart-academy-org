"""
Service de traitement d'images utilisant OpenAI Vision API
"""

import logging
import base64
import os
from openai import OpenAI
from core.config import settings
from services.rag import ask_question

logger = logging.getLogger(__name__)

def process_image_with_vision(image_file_path: str, question: str = None) -> dict:
    """
    Traite une image avec OpenAI Vision API et RAG
    
    Args:
        image_file_path: Chemin vers le fichier image
        question: Question optionnelle de l'utilisateur
        
    Returns:
        dict: Réponse avec description de l'image, answer, sources, etc.
    """
    try:
        if not settings.openai_api_key:
            raise Exception("OpenAI API key not configured")
        
        client = OpenAI(api_key=settings.openai_api_key)
        
        logger.info(f"🖼️  Traitement de l'image: {image_file_path}")
        
        # Lire et encoder l'image en base64
        with open(image_file_path, "rb") as image_file:
            image_data = base64.b64encode(image_file.read()).decode('utf-8')
        
        # Déterminer le type MIME de l'image
        ext = os.path.splitext(image_file_path)[1].lower()
        mime_types = {
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.png': 'image/png',
            '.gif': 'image/gif',
            '.webp': 'image/webp'
        }
        mime_type = mime_types.get(ext, 'image/jpeg')
        
        # Construire la question pour Vision API
        vision_prompt = question if question and question.strip() else "Décris cette image en détail. Qu'est-ce que tu vois ?"
        
        # Appeler Vision API
        response = client.chat.completions.create(
            model="gpt-4o",  # gpt-4o supporte les images
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": vision_prompt
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:{mime_type};base64,{image_data}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=1000,
            temperature=0.7
        )
        
        image_description = response.choices[0].message.content
        logger.info(f"✅ Description de l'image générée: {image_description[:100]}...")
        
        # Si une question spécifique est posée, utiliser RAG pour répondre
        if question and question.strip():
            # Combiner la description de l'image avec la question pour le RAG
            enhanced_question = f"Question sur l'image: {question}\n\nDescription de l'image: {image_description}"
            rag_result = ask_question(enhanced_question)
            
            return {
                "image_description": image_description,
                "answer": rag_result.get('answer', ''),
                "sources": rag_result.get('sources', []),
                "model_used": rag_result.get('model_used', 'unknown'),
                "num_sources": rag_result.get('num_sources', 0)
            }
        else:
            # Juste retourner la description
            return {
                "image_description": image_description,
                "answer": image_description,
                "sources": [],
                "model_used": "gpt-4o",
                "num_sources": 0
            }
        
    except Exception as e:
        logger.error(f"❌ Erreur lors du traitement de l'image: {str(e)}", exc_info=True)
        raise Exception(f"Erreur de traitement d'image: {str(e)}")
