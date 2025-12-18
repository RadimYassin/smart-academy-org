"""
Wrapper élégant pour Ollama
Interface propre avec l'API Ollama sans dépendances conflictuelles
"""

import requests
import logging
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)


class OllamaChat:
    """
    Wrapper élégant pour Ollama compatible avec l'interface LangChain
    """
    
    def __init__(self, model: str, base_url: str = "http://localhost:11434", temperature: float = 0.7):
        """
        Initialise le client Ollama
        
        Args:
            model: Nom du modèle (ex: llama3)
            base_url: URL de base d'Ollama
            temperature: Température de génération (0.0 à 1.0)
        """
        self.model = model
        self.base_url = base_url.rstrip('/')
        self.temperature = temperature
        logger.info(f"🤖 Client Ollama initialisé: {model} @ {base_url}")
    
    def invoke(self, input_data: Any, config: Optional[Dict] = None, **kwargs) -> Any:
        """
        Invoque le modèle Ollama avec un prompt
        Compatible avec l'interface LangChain
        
        Args:
            input_data: Peut être une string, un dict, ou un objet avec messages
            config: Configuration optionnelle (ignorée pour compatibilité)
            **kwargs: Arguments supplémentaires (ignorés pour compatibilité)
            
        Returns:
            Objet réponse avec attribut 'content'
        """
        # Extraire le prompt depuis l'input
        if isinstance(input_data, str):
            prompt = input_data
        elif isinstance(input_data, dict):
            # Format dict avec input ou messages
            if 'input' in input_data:
                prompt = input_data['input']
            elif 'messages' in input_data:
                prompt = self._format_messages(input_data['messages'])
            else:
                prompt = str(input_data)
        elif hasattr(input_data, 'messages'):
            # Format LangChain messages
            prompt = self._format_messages(input_data.messages)
        elif hasattr(input_data, 'to_messages'):
            # Format LangChain ChatPromptValue
            messages = input_data.to_messages()
            prompt = self._format_langchain_messages(messages)
        else:
            prompt = str(input_data)
        
        logger.debug(f"Envoi prompt à Ollama ({len(prompt)} chars)")
        
        # Appeler l'API Ollama
        try:
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.model,
                    "prompt": prompt,
                    "stream": False,
                    "options": {
                        "temperature": self.temperature,
                        "num_predict": 2000  # Limite de tokens pour la réponse
                    }
                },
                timeout=300
            )
            response.raise_for_status()
            result = response.json()
            
            # Créer un objet réponse compatible LangChain
            class ChatResponse:
                def __init__(self, content: str):
                    self.content = content
                    # Attributs additionnels pour compatibilité LangChain
                    self.response_metadata = {}
                    self.type = "ai"
            
            return ChatResponse(result["response"])
            
        except requests.exceptions.ConnectionError:
            logger.error("❌ Impossible de se connecter à Ollama. Assurez-vous qu'Ollama est démarré.")
            raise ConnectionError(
                "Impossible de se connecter à Ollama. "
                "Assurez-vous qu'Ollama est démarré (il devrait tourner en arrière-plan après l'installation)."
            )
        except requests.exceptions.Timeout:
            logger.error("❌ Timeout lors de l'appel à Ollama")
            raise TimeoutError("Le modèle Ollama met trop de temps à répondre")
        except Exception as e:
            logger.error(f"❌ Erreur Ollama: {str(e)}")
            raise
    
    def _format_messages(self, messages: List[Dict]) -> str:
        """
        Formate une liste de messages dict en prompt texte
        
        Args:
            messages: Liste de messages avec 'role' et 'content'
            
        Returns:
            Prompt formaté
        """
        formatted = []
        for msg in messages:
            role = msg.get('role', 'user')
            content = msg.get('content', '')
            if role == 'system':
                formatted.append(f"System: {content}")
            elif role == 'assistant':
                formatted.append(f"Assistant: {content}")
            else:
                formatted.append(f"User: {content}")
        
        return "\n\n".join(formatted)
    
    def _format_langchain_messages(self, messages: List) -> str:
        """
        Formate des messages LangChain (objets BaseMessage) en prompt texte
        
        Args:
            messages: Liste d'objets BaseMessage de LangChain
            
        Returns:
            Prompt formaté
        """
        formatted = []
        for msg in messages:
            # Les messages LangChain ont un attribut 'content' et 'type'
            content = getattr(msg, 'content', str(msg))
            msg_type = getattr(msg, 'type', 'human')
            
            if msg_type == 'system':
                formatted.append(f"System: {content}")
            elif msg_type in ['ai', 'assistant']:
                formatted.append(f"Assistant: {content}")
            else:
                formatted.append(f"User: {content}")
        
        return "\n\n".join(formatted)
    
    def bind(self, **kwargs):
        """
        Méthode bind pour compatibilité LangChain
        Retourne self car notre wrapper ne supporte pas le binding avancé
        """
        return self
    
    def with_config(self, config: Dict) -> "OllamaChat":
        """
        Méthode with_config pour compatibilité LangChain
        Retourne self car la config est gérée différemment
        """
        return self

