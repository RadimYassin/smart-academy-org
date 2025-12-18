"""
Wrapper pour Google Gemini (Version simplifiée et compatible)
Interface propre compatible avec le système RAG existant
"""

import google.generativeai as genai
import os
import logging

logger = logging.getLogger(__name__)

class GeminiChat:
    """
    Wrapper simplifié pour Gemini compatible avec l'interface existante
    """
    
    def __init__(self, model="gemini-1.5-flash", temperature=0.7):
        """
        Initialise le client Gemini de manière simple
        
        Args:
            model: Nom du modèle
            temperature: Température de génération
        """
        self.model_name = model
        self.temperature = temperature
        
        # Configurer l'API Gemini
        from core.config import settings
        
        api_key = settings.gemini_api_key or os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY non trouvée. Ajoutez GEMINI_API_KEY=votre-clé dans .env")
        
        genai.configure(api_key=api_key)
        
        # Créer le modèle de manière simple
        self.model = genai.GenerativeModel(model)
        
        logger.info(f"🌟 Client Gemini initialisé: {model}")
    
    def invoke(self, input_data, config=None, **kwargs):
        """
        Invoque le modèle Gemini - version simplifiée
        
        Args:
            input_data: String avec le prompt
            
        Returns:
            Objet réponse avec attribut 'content'
        """
        # Extraire le prompt (simple)
        if isinstance(input_data, str):
            prompt = input_data
        elif isinstance(input_data, dict):
            prompt = input_data.get('input', str(input_data))
        else:
            prompt = str(input_data)
        
        logger.debug(f"📤 Envoi à Gemini ({len(prompt)} chars)")
        
        try:
            # Générer la réponse (API simple)
            response = self.model.generate_content(prompt)
            
            # Créer un objet réponse compatible
            class ChatResponse:
                def __init__(self, content: str):
                    self.content = content
            
            logger.debug(f"📥 Réponse Gemini reçue")
            return ChatResponse(response.text)
            
        except Exception as e:
            logger.error(f"❌ Erreur Gemini: {str(e)}")
            raise
    
    def bind(self, **kwargs):
        """Compatibilité LangChain"""
        return self
    
    def with_config(self, config):
        """Compatibilité LangChain"""
        return self

