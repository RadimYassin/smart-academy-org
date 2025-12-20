"""
Configuration centralisée pour EduBot
Utilise Pydantic Settings pour la validation des variables d'environnement
"""

from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field
from typing import Literal


class Settings(BaseSettings):
    """
    Configuration de l'application chargée depuis les variables d'environnement
    """
    
    # === MinIO Configuration ===
    minio_endpoint: str = Field(default="localhost:9000", description="Endpoint MinIO")
    minio_access_key: str = Field(default="minioadmin", description="MinIO Access Key")
    minio_secret_key: str = Field(default="minioadmin", description="MinIO Secret Key")
    minio_bucket_name: str = Field(default="course-materials", description="Nom du bucket")
    minio_secure: bool = Field(default=False, description="Utiliser HTTPS pour MinIO")
    
    # === OpenAI Configuration ===
    openai_api_key: str = Field(default="", description="Clé API OpenAI")
    openai_model: str = Field(default="gpt-4o-mini", description="Modèle OpenAI")
    openai_temperature: float = Field(default=0.7, description="Temperature pour la génération")
    
    # === LLM Provider ===
    llm_provider: Literal["openai", "ollama", "gemini"] = Field(default="openai", description="Provider LLM")
    
    # === Ollama Configuration (optionnel) ===
    ollama_base_url: str = Field(default="http://localhost:11434", description="URL Ollama")
    ollama_model: str = Field(default="llama2", description="Modèle Ollama")
    
    # === Gemini Configuration (optionnel) ===
    gemini_api_key: str = Field(default="", description="Clé API Gemini")
    gemini_model: str = Field(default="gemini-1.5-flash", description="Modèle Gemini")
    
    # === Embeddings Configuration ===
    embedding_model: str = Field(
        default="sentence-transformers/all-MiniLM-L6-v2",
        description="Modèle d'embeddings HuggingFace"
    )
    
    # === FAISS Configuration ===
    faiss_index_path: str = Field(default="./faiss_index", description="Chemin de l'index FAISS")
    chunk_size: int = Field(default=1000, description="Taille des chunks de texte")
    chunk_overlap: int = Field(default=200, description="Overlap entre chunks")
    retrieval_top_k: int = Field(default=4, description="Nombre de documents à récupérer")
    
    # === Application Settings ===
    app_title: str = Field(default="EduBot - Assistant Pédagogique", description="Titre de l'app")
    app_version: str = Field(default="1.0.0", description="Version de l'app")
    temp_pdf_dir: str = Field(default="./temp_pdfs", description="Dossier temporaire pour PDFs")
    
    # === Service Configuration ===
    service_port: int = Field(default=8005, description="Port du service")
    service_host: str = Field(default="0.0.0.0", description="Host du service")
    
    # === Eureka Configuration ===
    eureka_server_url: str = Field(default="http://localhost:8761/eureka", description="URL du serveur Eureka")
    eureka_instance_hostname: str = Field(default="localhost", description="Hostname pour l'instance Eureka")
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",  # Ignore extra fields instead of raising validation error
    )


# Instance globale des settings
settings = Settings()
