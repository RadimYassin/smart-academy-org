"""
Modèles de données Pydantic pour les requêtes et réponses API
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional


class QuestionRequest(BaseModel):
    """
    Modèle pour la requête de question
    """
    question: str = Field(
        ...,
        min_length=3,
        max_length=1000,
        description="Question de l'étudiant",
        examples=["Qu'est-ce qu'une classe en Python ?"]
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "question": "Comment fonctionne l'héritage en Java ?"
            }
        }


class SourceDocument(BaseModel):
    """
    Modèle pour un document source
    """
    content: str = Field(..., description="Extrait du contenu du document")
    metadata: Dict[str, Any] = Field(default={}, description="Métadonnées du document")
    page: Any = Field(..., description="Numéro de page")
    source_file: str = Field(..., description="Nom du fichier source")
    
    class Config:
        json_schema_extra = {
            "example": {
                "content": "En Python, une classe est définie avec le mot-clé 'class'...",
                "metadata": {"page": 45, "source_file": "Python-1.pdf"},
                "page": 45,
                "source_file": "Python-1.pdf"
            }
        }


class AnswerResponse(BaseModel):
    """
    Modèle pour la réponse à une question
    """
    answer: str = Field(..., description="Réponse de l'assistant pédagogique")
    sources: List[SourceDocument] = Field(
        default=[],
        description="Documents sources utilisés pour la réponse"
    )
    model_used: str = Field(..., description="Modèle LLM utilisé")
    num_sources: int = Field(..., description="Nombre de sources consultées")
    
    class Config:
        json_schema_extra = {
            "example": {
                "answer": "Excellente question sur les classes en Python ! ...",
                "sources": [
                    {
                        "content": "Une classe en Python...",
                        "metadata": {"page": 45},
                        "page": 45,
                        "source_file": "Python-1.pdf"
                    }
                ],
                "model_used": "gpt-4o-mini",
                "num_sources": 3
            }
        }


class IngestRequest(BaseModel):
    """
    Modèle pour la requête d'ingestion (optionnel)
    """
    use_local_pdfs: bool = Field(
        default=True,
        description="Utiliser les PDFs du dossier 'Cours' local au lieu de MinIO"
    )
    local_pdf_dir: Optional[str] = Field(
        default=None,
        description="Chemin personnalisé vers le dossier de PDFs locaux"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "use_local_pdfs": True,
                "local_pdf_dir": "./Cours"
            }
        }


class IngestResponse(BaseModel):
    """
    Modèle pour la réponse d'ingestion
    """
    status: str = Field(..., description="Statut de l'ingestion")
    files_processed: int = Field(..., description="Nombre de fichiers traités")
    total_pages: int = Field(default=0, description="Nombre total de pages extraites")
    total_chunks: int = Field(default=0, description="Nombre total de chunks créés")
    message: str = Field(..., description="Message descriptif")
    index_path: str = Field(default="", description="Chemin de l'index FAISS")
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "success",
                "files_processed": 45,
                "total_pages": 1250,
                "total_chunks": 3400,
                "message": "Ingestion réussie: 45 fichiers PDF indexés",
                "index_path": "./faiss_index"
            }
        }


class HealthResponse(BaseModel):
    """
    Modèle pour le health check
    """
    status: str = Field(..., description="Statut de l'application")
    faiss_index_exists: bool = Field(..., description="L'index FAISS existe-t-il ?")
    llm_provider: str = Field(..., description="Provider LLM configuré")
    model: str = Field(..., description="Modèle utilisé")
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "healthy",
                "faiss_index_exists": True,
                "llm_provider": "openai",
                "model": "gpt-4o-mini"
            }
        }
