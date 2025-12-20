#!/bin/bash

# ============================================
# Script de démarrage pour Chatbot-edu
# ============================================

set -e  # Arrêter en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration par défaut
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
PORT=${SERVICE_PORT:-8005}
HOST=${SERVICE_HOST:-0.0.0.0}
EUREKA_SERVER=${EUREKA_SERVER_URL:-http://localhost:8761/eureka}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Chatbot-edu - Script de démarrage${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Fonction pour afficher les messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    error "Python 3 n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

info "Python version: $(python3 --version)"

# Vérifier si l'environnement virtuel existe
if [ ! -d "$VENV_DIR" ]; then
    warning "Environnement virtuel non trouvé. Création en cours..."
    python3 -m venv "$VENV_DIR"
    success "Environnement virtuel créé"
fi

# Activer l'environnement virtuel
info "Activation de l'environnement virtuel..."
source "$VENV_DIR/bin/activate"

# Vérifier si les dépendances sont installées
if [ ! -f "$VENV_DIR/bin/uvicorn" ]; then
    warning "Dépendances non installées. Installation en cours..."
    info "Installation des dépendances depuis requirements.txt..."
    pip install --upgrade pip
    pip install -r "$SCRIPT_DIR/requirements.txt"
    success "Dépendances installées"
else
    info "Vérification des dépendances..."
    pip install -q --upgrade pip
    pip install -q -r "$SCRIPT_DIR/requirements.txt"
fi

# Vérifier si le fichier .env existe
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    warning "Fichier .env non trouvé. Création d'un fichier .env par défaut..."
    cat > "$SCRIPT_DIR/.env" << EOF
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Service Configuration
SERVICE_PORT=$PORT
SERVICE_HOST=$HOST
EUREKA_SERVER_URL=$EUREKA_SERVER

# MinIO Configuration (optionnel)
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=course-materials
MINIO_SECURE=false

# LLM Provider (openai, ollama, gemini)
LLM_PROVIDER=openai

# Ollama Configuration (si LLM_PROVIDER=ollama)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2

# Gemini Configuration (si LLM_PROVIDER=gemini)
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-1.5-flash
EOF
    warning "Fichier .env créé. Veuillez configurer OPENAI_API_KEY avant de continuer."
    echo ""
    read -p "Voulez-vous continuer quand même? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Arrêt du script."
        exit 0
    fi
fi

# Vérifier si l'index FAISS existe
if [ ! -d "$SCRIPT_DIR/faiss_index" ] || [ ! -f "$SCRIPT_DIR/faiss_index/index.faiss" ]; then
    warning "Index FAISS non trouvé. Le service démarrera mais ne pourra pas répondre aux questions."
    warning "Pour créer l'index, utilisez: POST /admin/ingest après le démarrage"
fi

# Exporter les variables d'environnement
export SERVICE_PORT=$PORT
export SERVICE_HOST=$HOST
export EUREKA_SERVER_URL=$EUREKA_SERVER

# Afficher la configuration
echo ""
info "Configuration:"
echo "  - Port: $PORT"
echo "  - Host: $HOST"
echo "  - Eureka Server: $EUREKA_SERVER"
echo "  - Working Directory: $SCRIPT_DIR"
echo ""

# Démarrer le serveur
success "Démarrage du serveur Chatbot-edu..."
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Serveur démarré sur http://$HOST:$PORT${NC}"
echo -e "${GREEN}  Documentation: http://$HOST:$PORT/docs${NC}"
echo -e "${GREEN}  Health Check: http://$HOST:$PORT/health${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

# Lancer uvicorn
cd "$SCRIPT_DIR"
uvicorn main:app \
    --host "$HOST" \
    --port "$PORT" \
    --reload \
    --log-level info

