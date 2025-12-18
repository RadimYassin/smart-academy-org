"""
Service d'ingestion et de vectorisation des documents PDF
Extrait le texte, le découpe en chunks, et crée l'index FAISS
"""

import os
import shutil
from typing import List
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from core.config import settings
from services.minio_client import download_pdf_files
import logging


logger = logging.getLogger(__name__)


def load_pdfs_from_directory(pdf_dir: str) -> List:
    """
    Charge tous les PDFs d'un répertoire avec PyPDFLoader
    
    Args:
        pdf_dir: Chemin du répertoire contenant les PDFs
        
    Returns:
        List: Liste de documents LangChain
    """
    all_documents = []
    pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith('.pdf')]
    
    logger.info(f"📄 Chargement de {len(pdf_files)} fichiers PDF...")
    
    for pdf_file in pdf_files:
        pdf_path = os.path.join(pdf_dir, pdf_file)
        try:
            loader = PyPDFLoader(pdf_path)
            documents = loader.load()
            
            # Enrichir les métadonnées
            for doc in documents:
                doc.metadata['source_file'] = pdf_file
            
            all_documents.extend(documents)
            logger.info(f"  ✓ {pdf_file}: {len(documents)} pages chargées")
            
        except Exception as e:
            logger.error(f"  ✗ Erreur lors du chargement de {pdf_file}: {str(e)}")
    
    logger.info(f"✅ Total: {len(all_documents)} pages chargées")
    return all_documents


def split_documents(documents: List) -> List:
    """
    Découpe les documents en chunks avec RecursiveCharacterTextSplitter
    
    Args:
        documents: Liste de documents LangChain
        
    Returns:
        List: Liste de chunks
    """
    logger.info(f"✂️  Découpage des documents en chunks (size={settings.chunk_size}, overlap={settings.chunk_overlap})...")
    
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=settings.chunk_size,
        chunk_overlap=settings.chunk_overlap,
        length_function=len,
        separators=["\n\n", "\n", " ", ""]
    )
    
    chunks = text_splitter.split_documents(documents)
    logger.info(f"✅ {len(chunks)} chunks créés")
    
    return chunks


def create_embeddings():
    """
    Crée le modèle d'embeddings HuggingFace
    
    Returns:
        HuggingFaceEmbeddings: Modèle d'embeddings configuré
    """
    logger.info(f"🧠 Chargement du modèle d'embeddings: {settings.embedding_model}")
    
    embeddings = HuggingFaceEmbeddings(
        model_name=settings.embedding_model,
        model_kwargs={'device': 'cpu'},
        encode_kwargs={'normalize_embeddings': True}
    )
    
    logger.info("✅ Modèle d'embeddings chargé")
    return embeddings


def create_faiss_index(chunks: List, embeddings) -> FAISS:
    """
    Crée l'index FAISS à partir des chunks et embeddings
    
    Args:
        chunks: Liste de chunks de documents
        embeddings: Modèle d'embeddings
        
    Returns:
        FAISS: Index vectoriel FAISS
    """
    logger.info("🔧 Création de l'index FAISS...")
    
    vectorstore = FAISS.from_documents(
        documents=chunks,
        embedding=embeddings
    )
    
    logger.info("✅ Index FAISS créé")
    return vectorstore


def save_faiss_index(vectorstore: FAISS, index_path: str = None):
    """
    Sauvegarde l'index FAISS localement
    
    Args:
        vectorstore: Index FAISS à sauvegarder
        index_path: Chemin de sauvegarde (par défaut: settings.faiss_index_path)
    """
    if index_path is None:
        index_path = settings.faiss_index_path
    
    logger.info(f"💾 Sauvegarde de l'index FAISS dans: {index_path}")
    
    # Créer le dossier si nécessaire
    os.makedirs(index_path, exist_ok=True)
    
    vectorstore.save_local(index_path)
    logger.info("✅ Index FAISS sauvegardé")


def ingest_documents(use_local_pdfs: bool = False, local_pdf_dir: str = None) -> dict:
    """
    Fonction principale d'ingestion complète:
    1. Télécharge les PDFs depuis MinIO (ou utilise des PDFs locaux)
    2. Extrait le texte
    3. Découpe en chunks
    4. Vectorise et crée l'index FAISS
    5. Sauvegarde l'index
    
    Args:
        use_local_pdfs: Si True, utilise les PDFs du dossier local au lieu de MinIO
        local_pdf_dir: Chemin du dossier contenant les PDFs locaux (défaut: ./Cours)
        
    Returns:
        dict: Statistiques de l'ingestion
    """
    logger.info("=" * 60)
    logger.info("🚀 DÉMARRAGE DE L'INGESTION DES DOCUMENTS")
    logger.info("=" * 60)
    
    try:
        # Étape 1: Récupérer les PDFs
        if use_local_pdfs:
            # Utiliser les PDFs du dossier "Cours" par défaut
            if local_pdf_dir is None:
                local_pdf_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "Cours")
            
            logger.info(f"📁 Utilisation des PDFs locaux depuis: {local_pdf_dir}")
            
            if not os.path.exists(local_pdf_dir):
                raise ValueError(f"Le dossier {local_pdf_dir} n'existe pas")
            
            pdf_dir = local_pdf_dir
            pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith('.pdf')]
        else:
            # Télécharger depuis MinIO
            pdf_files = download_pdf_files()
            pdf_dir = settings.temp_pdf_dir
        
        if not pdf_files:
            raise ValueError("Aucun fichier PDF trouvé")
        
        # Étape 2: Charger les PDFs
        documents = load_pdfs_from_directory(pdf_dir)
        
        if not documents:
            raise ValueError("Aucun document chargé")
        
        # Étape 3: Découper en chunks
        chunks = split_documents(documents)
        
        # Étape 4: Créer les embeddings
        embeddings = create_embeddings()
        
        # Étape 5: Créer l'index FAISS
        vectorstore = create_faiss_index(chunks, embeddings)
        
        # Étape 6: Sauvegarder l'index
        save_faiss_index(vectorstore)
        
        # Nettoyage: supprimer les PDFs temporaires si téléchargés depuis MinIO
        if not use_local_pdfs and os.path.exists(settings.temp_pdf_dir):
            shutil.rmtree(settings.temp_pdf_dir)
            logger.info("🧹 Fichiers temporaires supprimés")
        
        stats = {
            "status": "success",
            "files_processed": len(pdf_files) if isinstance(pdf_files, list) else len(os.listdir(pdf_dir)),
            "total_pages": len(documents),
            "total_chunks": len(chunks),
            "index_path": settings.faiss_index_path
        }
        
        logger.info("=" * 60)
        logger.info("✅ INGESTION TERMINÉE AVEC SUCCÈS")
        logger.info(f"   📊 Fichiers traités: {stats['files_processed']}")
        logger.info(f"   📄 Pages extraites: {stats['total_pages']}")
        logger.info(f"   ✂️  Chunks créés: {stats['total_chunks']}")
        logger.info(f"   💾 Index sauvegardé: {stats['index_path']}")
        logger.info("=" * 60)
        
        return stats
        
    except Exception as e:
        logger.error(f"❌ ERREUR LORS DE L'INGESTION: {str(e)}")
        raise
