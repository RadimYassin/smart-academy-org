"""
Moteur RAG (Retrieval Augmented Generation)
Charge l'index FAISS et configure la chaîne LangChain pour répondre aux questions
"""

import os
from typing import Dict, List
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_openai import ChatOpenAI
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
from core.config import settings
from core.prompts import SOCRATIC_SYSTEM_PROMPT, RAG_PROMPT_TEMPLATE
import logging

logger = logging.getLogger(__name__)


# Variable globale pour le cache du vectorstore
_vectorstore_cache = None


def load_vectorstore() -> FAISS:
    """
    Charge l'index FAISS depuis le disque
    Utilise un cache pour éviter de recharger à chaque requête
    
    Returns:
        FAISS: Index vectoriel chargé
    """
    global _vectorstore_cache
    
    if _vectorstore_cache is not None:
        logger.debug("📦 Utilisation du vectorstore en cache")
        return _vectorstore_cache
    
    index_path = settings.faiss_index_path
    
    if not os.path.exists(index_path):
        raise FileNotFoundError(
            f"❌ Index FAISS non trouvé dans '{index_path}'. "
            f"Veuillez d'abord lancer l'ingestion via POST /ingest"
        )
    
    logger.info(f"📂 Chargement de l'index FAISS depuis: {index_path}")
    
    # Créer les mêmes embeddings que pour l'ingestion
    embeddings = HuggingFaceEmbeddings(
        model_name=settings.embedding_model,
        model_kwargs={'device': 'cpu'},
        encode_kwargs={'normalize_embeddings': True}
    )
    
    # Charger l'index FAISS
    vectorstore = FAISS.load_local(
        index_path,
        embeddings,
        allow_dangerous_deserialization=True  # Nécessaire pour FAISS
    )
    
    _vectorstore_cache = vectorstore
    logger.info("✅ Index FAISS chargé avec succès")
    
    return vectorstore


def get_llm():
    """
    Crée et retourne le LLM configuré (OpenAI ou Ollama)
    
    Returns:
        LLM instance configurée
    """
    if settings.llm_provider == "openai":
        logger.info(f"🤖 Utilisation de OpenAI: {settings.openai_model}")
        
        if not settings.openai_api_key:
            raise ValueError("❌ OPENAI_API_KEY non configurée dans .env")
        
        return ChatOpenAI(
            model=settings.openai_model,
            temperature=settings.openai_temperature,
            api_key=settings.openai_api_key
        )
    
    elif settings.llm_provider == "ollama":
        logger.info(f"🤖 Utilisation de Ollama: {settings.ollama_model}")
        
        # Utiliser notre wrapper élégant Ollama
        from services.ollama_wrapper import OllamaChat
        from langchain_core.runnables import RunnableLambda
        
        # Créer le client Ollama
        ollama_client = OllamaChat(
            model=settings.ollama_model,
            base_url=settings.ollama_base_url,
            temperature=settings.openai_temperature
        )
        
        # Encapsuler dans un RunnableLambda pour compatibilité LangChain
        # Ceci permet à LangChain d'accepter notre wrapper custom
        ollama_runnable = RunnableLambda(ollama_client.invoke)
        
        return ollama_runnable
    
    elif settings.llm_provider == "gemini":
        logger.info(f"🌟 Utilisation de Gemini: {os.getenv('GEMINI_MODEL', 'gemini-1.5-flash')}")
        
        # Utiliser notre wrapper Gemini
        from services.gemini_wrapper import GeminiChat
        
        # Créer le client Gemini
        gemini_client = GeminiChat(
            model=os.getenv('GEMINI_MODEL', 'gemini-1.5-flash'),
            temperature=settings.openai_temperature
        )
        
        # Le wrapper Gemini est déjà compatible
        return gemini_client
    
    else:
        raise ValueError(f"❌ LLM provider '{settings.llm_provider}' non supporté")




def get_rag_chain():
    """
    Crée et configure la chaîne RAG complète avec LangChain
    
    Returns:
        Chain: Chaîne de retrieval configurée
    """
    logger.info("⚙️  Configuration de la chaîne RAG...")
    
    # Charger le vectorstore
    vectorstore = load_vectorstore()
    
    # Créer le retriever
    retriever = vectorstore.as_retriever(
        search_type="similarity",
        search_kwargs={"k": settings.retrieval_top_k}
    )
    
    # Créer le LLM
    llm = get_llm()
    
    # Créer le prompt template
    prompt = ChatPromptTemplate.from_messages([
        ("system", SOCRATIC_SYSTEM_PROMPT),
        ("human", RAG_PROMPT_TEMPLATE)
    ])
    
    # Créer la chaîne de combinaison de documents
    combine_docs_chain = create_stuff_documents_chain(llm, prompt)
    
    # Créer la chaîne de retrieval complète
    rag_chain = create_retrieval_chain(retriever, combine_docs_chain)
    
    logger.info("✅ Chaîne RAG configurée")
    return rag_chain


def format_sources(source_documents: List) -> List[Dict]:
    """
    Formate les documents sources pour la réponse API
    
    Args:
        source_documents: Liste de documents retournés par le retriever
        
    Returns:
        List[Dict]: Liste de sources formatées
    """
    sources = []
    
    for doc in source_documents:
        source = {
            "content": doc.page_content[:300] + "..." if len(doc.page_content) > 300 else doc.page_content,
            "metadata": doc.metadata,
            "page": doc.metadata.get("page", "N/A"),
            "source_file": doc.metadata.get("source_file", "Unknown")
        }
        sources.append(source)
    
    return sources


def ask_question(question: str) -> Dict:
    """
    Point d'entrée principal pour poser une question au RAG
    Implémentation custom élégante qui évite les problèmes de compatibilité LangChain
    
    Args:
        question: Question de l'étudiant
        
    Returns:
        Dict: Réponse avec answer et sources
    """
    logger.info(f"❓ Question reçue: {question[:100]}...")
    
    try:
        # Étape 1: Charger le vectorstore
        vectorstore = load_vectorstore()
        logger.info("✅ Vectorstore chargé")
        
        # Étape 2: Récupérer les documents pertinents (optimisé pour qualité)
        docs = vectorstore.similarity_search(question, k=4)  # 4 docs pour meilleure couverture
        logger.info(f"✅ {len(docs)} documents récupérés")
        
        # Étape 3: Construire le contexte depuis les documents (limité pour performance)
        context_parts = []
        for i, doc in enumerate(docs, 1):
            source_file = doc.metadata.get('source_file', 'Unknown')
            page = doc.metadata.get('page', 'N/A')
            # Limiter la taille du contenu (500 chars pour équilibre qualité/vitesse)
            content = doc.page_content[:500] + "..." if len(doc.page_content) > 500 else doc.page_content
            context_parts.append(
                f"[Document {i} - {source_file}, Page {page}]\n{content}"
            )
        
        context = "\n\n---\n\n".join(context_parts)
        
        # Étape 4: Construire le prompt complet avec système + contexte + question
        full_prompt = f"""{SOCRATIC_SYSTEM_PROMPT}

Contexte documentaire (extraits de cours):
{context}

Question de l'étudiant: {question}

Réponds en suivant les principes socratiques définis dans le prompt système.
N'oublie pas de citer les sources avec précision (nom du fichier PDF et numéro de page)."""
        
        logger.info("✅ Prompt construit")
        
        # Étape 5: Appeler le LLM (Ollama ou Gemini)
        if settings.llm_provider == "ollama":
            from services.ollama_wrapper import OllamaChat
            
            ollama = OllamaChat(
                model=settings.ollama_model,
                base_url=settings.ollama_base_url,
                temperature=settings.openai_temperature
            )
            
            logger.info("🤖 Appel à Ollama...")
            response = ollama.invoke(full_prompt)
            answer = response.content
        
        elif settings.llm_provider == "gemini":
            from services.gemini_wrapper import GeminiChat
            
            gemini = GeminiChat(
                model=os.getenv('GEMINI_MODEL', 'gemini-1.5-flash'),
                temperature=settings.openai_temperature
            )
            
            logger.info("🌟 Appel à Gemini...")
            response = gemini.invoke(full_prompt)
            answer = response.content
        
        elif settings.llm_provider == "openai":
            from langchain_openai import ChatOpenAI
            
            llm = ChatOpenAI(
                model=settings.openai_model,
                temperature=settings.openai_temperature,
                api_key=settings.openai_api_key
            )
            
            logger.info("🤖 Appel à OpenAI...")
            response = llm.invoke(full_prompt)
            answer = response.content
        
        else:
            raise ValueError(f"Provider {settings.llm_provider} non supporté")
        
        logger.info("✅ Réponse générée")
        
        # Étape 6: Formater les sources
        formatted_sources = format_sources(docs)
        
        # Étape 7: Construire la réponse finale
        result = {
            "answer": answer,
            "sources": formatted_sources,
            "model_used": settings.ollama_model if settings.llm_provider == "ollama" else settings.openai_model,
            "num_sources": len(formatted_sources)
        }
        
        logger.info(f"✅ Réponse complète ({len(formatted_sources)} sources utilisées)")
        return result
        
    except Exception as e:
        logger.error(f"❌ Erreur lors du traitement de la question: {str(e)}")
        raise


def reset_vectorstore_cache():
    """
    Réinitialise le cache du vectorstore
    Utile après une réingestion
    """
    global _vectorstore_cache
    _vectorstore_cache = None
    logger.info("🔄 Cache du vectorstore réinitialisé")
