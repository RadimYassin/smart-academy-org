"""
Script d'ingestion standalone optimisé
Télécharge les PDFs depuis MinIO et crée l'index FAISS
Une fois exécuté, le chatbot sera fonctionnel en permanence
"""

import os
import sys
from pathlib import Path

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from services.ingest import ingest_documents
import logging

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    """
    Fonction principale d'ingestion
    Utilise MinIO comme source par défaut
    """
    logger.info("=" * 70)
    logger.info("🚀 DÉMARRAGE DE L'INGESTION DES PDFs DEPUIS MinIO")
    logger.info("=" * 70)
    
    try:
        # Ingestion depuis MinIO (use_local_pdfs=False par défaut)
        stats = ingest_documents(use_local_pdfs=False)
        
        # Afficher le résumé
        logger.info("")
        logger.info("🎉 Le chatbot EduBot est maintenant FONCTIONNEL !")
        logger.info("   Vous pouvez poser des questions via l'API:")
        logger.info("   POST http://127.0.0.1:8000/chat/text")
        logger.info("   ou accéder à la documentation: http://127.0.0.1:8000/docs")
        logger.info("=" * 70)
        
    except Exception as e:
        logger.error(f"\n❌ ERREUR: {str(e)}")
        logger.info("\n💡 Vérifiez que:")
        logger.info("   1. MinIO est démarré: docker ps | findstr minio")
        logger.info("   2. Les PDFs sont dans MinIO: docker exec edubot-minio mc ls local/course-materials/")
        logger.info("   3. Les variables d'environnement sont configurées dans .env")
        raise


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logger.info("\n⚠️  Ingestion interrompue par l'utilisateur")
        sys.exit(1)
    except Exception as e:
        logger.error(f"\n❌ ERREUR FATALE: {str(e)}", exc_info=True)
        sys.exit(1)
