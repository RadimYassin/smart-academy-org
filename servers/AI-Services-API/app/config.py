"""
Configuration module for AI Services API
"""
import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Application settings"""
    
    # App Configuration
    APP_NAME: str = os.getenv("APP_NAME", "AI-SERVICES-API")
    APP_PORT: int = int(os.getenv("APP_PORT", "8083"))
    APP_HOST: str = os.getenv("APP_HOST", "localhost")
    
    # Eureka Configuration
    EUREKA_SERVER: str = os.getenv("EUREKA_SERVER", "http://localhost:8761/eureka")
    
    # Database Configuration
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://edupath_user:edupath_password@localhost:5432/edupath_db"
    )
    
    # OpenAI Configuration
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # JWT Configuration
    JWT_SECRET: str = os.getenv(
        "JWT_SECRET",
        "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970"
    )
    JWT_ALGORITHM: str = "HS256"
    
    # Data Paths
    DATA_PATH_RAW: str = "../data/raw"
    DATA_PATH_PROCESSED: str = "../data/processed"
    DATA_PATH_CLEANED: str = os.getenv(
        "DATA_PATH_CLEANED",
        "../data/processed/data_cleaned.csv"
    )
    DATA_PATH_PROFILES: str = os.getenv(
        "DATA_PATH_PROFILES",
        "../data/processed/student_profiles.csv"
    )
    
    # Model Paths
    MODEL_PATH: str = os.getenv(
        "MODEL_PATH",
        "../outputs/models/xgboost_model.pkl"
    )
    OUTPUTS_PATH: str = "../outputs"
    
    # Default Parameters
    DEFAULT_FAIL_THRESHOLD: float = 50.0
    DEFAULT_N_CLUSTERS: int = 4


settings = Settings()
