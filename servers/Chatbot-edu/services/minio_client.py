"""
Client MinIO pour le téléchargement des fichiers PDF
"""

import os
from typing import List
from minio import Minio
from minio.error import S3Error
from core.config import settings
import logging

logger = logging.getLogger(__name__)


def get_minio_client() -> Minio:
    """
    Crée et retourne un client MinIO configuré
    
    Returns:
        Minio: Client MinIO configuré
    """
    try:
        client = Minio(
            endpoint=settings.minio_endpoint,
            access_key=settings.minio_access_key,
            secret_key=settings.minio_secret_key,
            secure=settings.minio_secure
        )
        logger.info(f"✅ Client MinIO créé avec succès (endpoint: {settings.minio_endpoint})")
        return client
    except Exception as e:
        logger.error(f"❌ Erreur lors de la création du client MinIO: {str(e)}")
        raise


def download_pdf_files(output_dir: str = None) -> List[str]:
    """
    Télécharge tous les fichiers PDF depuis le bucket MinIO
    
    Args:
        output_dir: Dossier de destination (par défaut: settings.temp_pdf_dir)
        
    Returns:
        List[str]: Liste des chemins des fichiers téléchargés
    """
    if output_dir is None:
        output_dir = settings.temp_pdf_dir
    
    # Créer le dossier de destination s'il n'existe pas
    os.makedirs(output_dir, exist_ok=True)
    
    client = get_minio_client()
    downloaded_files = []
    
    try:
        # Vérifier si le bucket existe
        if not client.bucket_exists(settings.minio_bucket_name):
            logger.error(f"❌ Le bucket '{settings.minio_bucket_name}' n'existe pas")
            raise ValueError(f"Bucket '{settings.minio_bucket_name}' non trouvé")
        
        logger.info(f"📦 Téléchargement des fichiers depuis le bucket '{settings.minio_bucket_name}'...")
        
        # Lister tous les objets du bucket
        objects = client.list_objects(settings.minio_bucket_name, recursive=True)
        
        pdf_count = 0
        for obj in objects:
            # Filtrer uniquement les fichiers PDF
            if obj.object_name.lower().endswith('.pdf'):
                pdf_count += 1
                local_path = os.path.join(output_dir, os.path.basename(obj.object_name))
                
                # Télécharger le fichier
                client.fget_object(
                    bucket_name=settings.minio_bucket_name,
                    object_name=obj.object_name,
                    file_path=local_path
                )
                
                downloaded_files.append(local_path)
                logger.info(f"  ✓ Téléchargé: {os.path.basename(obj.object_name)} ({obj.size} octets)")
        
        logger.info(f"✅ {pdf_count} fichiers PDF téléchargés avec succès")
        return downloaded_files
        
    except S3Error as e:
        logger.error(f"❌ Erreur S3/MinIO: {str(e)}")
        raise
    except Exception as e:
        logger.error(f"❌ Erreur lors du téléchargement: {str(e)}")
        raise


def upload_pdf_to_minio(local_file_path: str, object_name: str = None) -> bool:
    """
    Upload un fichier PDF local vers MinIO (utilitaire)
    
    Args:
        local_file_path: Chemin du fichier local
        object_name: Nom de l'objet dans MinIO (par défaut: nom du fichier)
        
    Returns:
        bool: True si succès
    """
    if object_name is None:
        object_name = os.path.basename(local_file_path)
    
    client = get_minio_client()
    
    try:
        # Créer le bucket s'il n'existe pas
        if not client.bucket_exists(settings.minio_bucket_name):
            client.make_bucket(settings.minio_bucket_name)
            logger.info(f"📦 Bucket '{settings.minio_bucket_name}' créé")
        
        # Upload le fichier
        client.fput_object(
            bucket_name=settings.minio_bucket_name,
            object_name=object_name,
            file_path=local_file_path
        )
        
        logger.info(f"✅ Fichier '{object_name}' uploadé avec succès")
        return True
        
    except S3Error as e:
        logger.error(f"❌ Erreur lors de l'upload: {str(e)}")
        return False
