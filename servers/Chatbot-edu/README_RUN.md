# Scripts de démarrage pour Chatbot-edu

Ce dossier contient des scripts pour démarrer facilement le service Chatbot-edu.

## Scripts disponibles

### Linux/macOS
```bash
./run.sh
```

### Windows
```cmd
run.bat
```

## Prérequis

1. **Python 3.9+** installé
2. **Variables d'environnement** configurées (voir ci-dessous)

## Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine du projet avec les variables suivantes :

```env
# OpenAI Configuration (requis si LLM_PROVIDER=openai)
OPENAI_API_KEY=your_openai_api_key_here

# Service Configuration
SERVICE_PORT=8005
SERVICE_HOST=0.0.0.0
EUREKA_SERVER_URL=http://localhost:8761/eureka

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
```

### Variables d'environnement système (optionnel)

Vous pouvez aussi définir ces variables avant d'exécuter le script :

```bash
export SERVICE_PORT=8005
export SERVICE_HOST=0.0.0.0
export EUREKA_SERVER_URL=http://localhost:8761/eureka
./run.sh
```

## Utilisation

### 1. Démarrer le service

```bash
# Linux/macOS
./run.sh

# Windows
run.bat
```

Le script va :
- ✅ Vérifier que Python est installé
- ✅ Créer l'environnement virtuel si nécessaire
- ✅ Installer les dépendances
- ✅ Créer un fichier `.env` par défaut si absent
- ✅ Démarrer le serveur sur le port configuré

### 2. Accéder à la documentation

Une fois le serveur démarré, accédez à :
- **API Documentation**: http://localhost:8005/docs
- **Health Check**: http://localhost:8005/health
- **Root**: http://localhost:8005/

### 3. Créer l'index FAISS (première fois)

Si l'index FAISS n'existe pas, vous devez l'ingérer :

```bash
# Option 1: Depuis MinIO
curl -X POST "http://localhost:8005/admin/ingest" \
  -H "Content-Type: application/json" \
  -d '{"source": "minio"}'

# Option 2: Depuis le dossier local Cours/
curl -X POST "http://localhost:8005/admin/ingest" \
  -H "Content-Type: application/json" \
  -d '{"source": "local"}'
```

Ou utilisez le script Python :
```bash
python run_ingestion.py
```

## Démarrer avec Docker Compose (MinIO inclus)

Si vous voulez aussi démarrer MinIO pour le stockage de documents :

```bash
docker-compose up -d
```

Cela démarre MinIO sur :
- **API**: http://localhost:9000
- **Console Web**: http://localhost:9001
- **Credentials**: minioadmin / minioadmin

## Dépannage

### Erreur: "Python n'est pas installé"
Installez Python 3.9+ depuis [python.org](https://www.python.org/downloads/)

### Erreur: "OPENAI_API_KEY not found"
Configurez votre clé API OpenAI dans le fichier `.env`

### Erreur: "Index FAISS non trouvé"
Lancez l'ingestion des documents avec `POST /admin/ingest` ou `python run_ingestion.py`

### Erreur: "Port already in use"
Changez le port dans `.env` ou via `export SERVICE_PORT=8006`

## Commandes utiles

```bash
# Vérifier que le service fonctionne
curl http://localhost:8005/health

# Poser une question au chatbot
curl -X POST "http://localhost:8005/chat/ask" \
  -H "Content-Type: application/json" \
  -d '{"question": "Qu'est-ce que Python?"}'

# Voir les logs
tail -f edubot.log
```

