# EduBot - Assistant Pédagogique Intelligent

<div align="center">

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-0.109-green.svg)
![LangChain](https://img.shields.io/badge/LangChain-0.1-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

🤖 **Microservice RAG (Retrieval Augmented Generation) pour l'enseignement socratique**

</div>

---

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Stack Technique](#-stack-technique)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [API Endpoints](#-api-endpoints)
- [Approche Socratique](#-approche-socratique)
- [Structure du Projet](#-structure-du-projet)
- [Développement](#-développement)

---

## 🎯 Vue d'ensemble

**EduBot** est un assistant pédagogique intelligent qui utilise la technique RAG (Retrieval Augmented Generation) pour répondre aux questions des étudiants en se basant sur des documents de cours PDF.

### Caractéristiques principales:

✅ **Indexation automatique** de cours PDF (local ou MinIO)  
✅ **Recherche vectorielle** avec FAISS pour retrouver les passages pertinents  
✅ **Approche socratique** - guide l'étudiant plutôt que de donner des réponses directes  
✅ **Citations de sources** - référence toujours les documents utilisés  
✅ **API REST** moderne avec FastAPI  
✅ **Flexible** - Support OpenAI GPT-4o-mini et Ollama  

---

## 🏗️ Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Étudiant  │────────▶│   FastAPI    │────────▶│    FAISS    │
│             │  POST   │   /chat/ask  │  Query  │ VectorStore │
└─────────────┘         └──────────────┘         └─────────────┘
                              │                         │
                              ▼                         ▼
                        ┌──────────────┐         ┌─────────────┐
                        │  LangChain   │────────▶│ OpenAI/     │
                        │  RAG Chain   │         │ Ollama LLM  │
                        └──────────────┘         └─────────────┘
                              │
                              ▼
                        ┌──────────────┐
                        │  Réponse +   │
                        │   Sources    │
                        └──────────────┘
```

### Workflow:

1. **Ingestion** (`POST /admin/ingest`):
   - Télécharge PDFs depuis MinIO ou utilise dossier local `Cours/`
   - Extrait le texte avec `PyPDFLoader`
   - Découpe en chunks (1000 caractères, overlap 200)
   - Génère embeddings avec `sentence-transformers/all-MiniLM-L6-v2`
   - Crée index FAISS et sauvegarde localement

2. **Question** (`POST /chat/ask`):
   - Reçoit la question de l'étudiant
   - Recherche les top-4 chunks pertinents dans FAISS
   - Envoie contexte + question au LLM avec prompt socratique
   - Retourne réponse pédagogique + sources citées

---

## 🛠️ Stack Technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Langage** | Python | 3.9+ |
| **API Framework** | FastAPI | 0.109 |
| **Orchestration IA** | LangChain | 0.1.6 |
| **Vector Store** | FAISS (CPU) | 1.7.4 |
| **Embeddings** | HuggingFace Transformers | sentence-transformers/all-MiniLM-L6-v2 |
| **LLM** | OpenAI | GPT-4o-mini |
| **Storage** | MinIO | 7.2.3 |
| **PDF Parsing** | PyPDF | 3.17.4 |
| **Validation** | Pydantic | 2.5.3 |

---

## 📦 Installation

### Prérequis:

- Python 3.9+
- pip
- (Optionnel) Docker pour MinIO

### Étapes:

```bash
# 1. Cloner le projet
cd "c:\Users\PC\Desktop\Chatbot edu"

# 2. Créer un environnement virtuel
python -m venv venv

# 3. Activer l'environnement
# Windows:
venv\Scripts\activate
# Linux/Mac:
# source venv/bin/activate

# 4. Installer les dépendances
pip install -r requirements.txt

# 5. Créer le fichier .env
copy .env.example .env
# Éditer .env et ajouter votre clé OpenAI
```

---

## ⚙️ Configuration

Créez un fichier `.env` à la racine du projet (copier depuis `.env.example`):

```env
# === OpenAI ===
OPENAI_API_KEY=sk-votre-clé-ici

# === LLM Provider ===
LLM_PROVIDER=openai
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.7

# === MinIO (optionnel) ===
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=course-materials
MINIO_SECURE=false

# === FAISS ===
FAISS_INDEX_PATH=./faiss_index
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
RETRIEVAL_TOP_K=4
```

### Pour utiliser Ollama (alternative à OpenAI):

```env
LLM_PROVIDER=ollama
OLLAMA_MODEL=llama2
OLLAMA_BASE_URL=http://localhost:11434
```

---

## 🚀 Utilisation

### Option 1: Utiliser les PDFs locaux (Recommandé pour débuter)

Vos 45 fichiers PDF sont déjà dans le dossier `Cours/`. Pas besoin de MinIO !

```bash
# 1. Lancer l'API
python main.py
# ou
uvicorn main:app --reload

# 2. L'API démarre sur http://localhost:8000

# 3. Indexer les PDFs du dossier Cours/
curl -X POST http://localhost:8000/admin/ingest \
  -H "Content-Type: application/json" \
  -d '{"use_local_pdfs": true}'

# 4. Poser une question
curl -X POST http://localhost:8000/chat/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "Qu'\''est-ce qu'\''une classe en Python ?"}'
```

### Option 2: Utiliser MinIO (Production)

```bash
# 1. Démarrer MinIO avec Docker
docker-compose up -d

# 2. Accéder à la console MinIO: http://localhost:9001
#    Login: minioadmin / minioadmin

# 3. Uploader vos PDFs dans le bucket "course-materials"

# 4. Lancer l'ingestion depuis MinIO
curl -X POST http://localhost:8000/admin/ingest \
  -H "Content-Type: application/json" \
  -d '{"use_local_pdfs": false}'
```

---

## 📡 API Endpoints

### Documentation interactive:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Endpoints principaux:

#### 1. Health Check
```http
GET /health
```

Réponse:
```json
{
  "status": "healthy",
  "faiss_index_exists": true,
  "llm_provider": "openai",
  "model": "gpt-4o-mini"
}
```

#### 2. Indexer les documents
```http
POST /admin/ingest
Content-Type: application/json

{
  "use_local_pdfs": true,
  "local_pdf_dir": "./Cours"
}
```

Réponse:
```json
{
  "status": "success",
  "files_processed": 45,
  "total_pages": 1250,
  "total_chunks": 3400,
  "message": "Ingestion réussie: 45 fichiers PDF indexés",
  "index_path": "./faiss_index"
}
```

#### 3. Poser une question
```http
POST /chat/ask
Content-Type: application/json

{
  "question": "Comment fonctionne l'héritage en Java ?"
}
```

Réponse:
```json
{
  "answer": "Excellente question sur l'héritage en Java ! ...",
  "sources": [
    {
      "content": "L'héritage en Java permet...",
      "page": 45,
      "source_file": "Java-10.pdf",
      "metadata": {...}
    }
  ],
  "model_used": "gpt-4o-mini",
  "num_sources": 3
}
```

---

## 🎓 Approche Socratique

EduBot n'est pas un simple moteur de Q&A. Il applique la **méthode socratique**:

### ❌ Ce qu'il NE fait PAS:
```
Q: Qu'est-ce qu'une boucle for en Python ?
R: Une boucle for permet d'itérer sur une séquence.
```

### ✅ Ce qu'il FAIT:
```
Q: Qu'est-ce qu'une boucle for en Python ?

R: Excellente question sur les boucles ! 

Imagine que tu as une liste de courses et que tu veux traiter 
chaque article un par un. La boucle for est exactement cet outil 
en programmation.

En Python, la syntaxe est :
for element in sequence:
    # faire quelque chose avec element

Exemple concret :
fruits = ['pomme', 'banane', 'orange']
for fruit in fruits:
    print(f'J'aime les {fruit}s')

Questions de réflexion :
1. Quelle est la différence entre for et while ?
2. Comment parcourir une liste en récupérant aussi l'index ?

📚 Sources : Python-3.pdf - Pages 67-69
```

### Principes:
1. **Reformulation** de la question
2. **Explication progressive** avec analogies
3. **Exemples concrets**
4. **Questions de réflexion** pour vérifier la compréhension
5. **Citation des sources** systématique

---

## 📁 Structure du Projet

```
Chatbot edu/
├── Cours/                      # 45 PDFs de cours (Java, Python)
│   ├── Java-1.pdf
│   ├── Python-1.pdf
│   └── ...
│
├── app/
│   ├── __init__.py
│   └── models.py               # Schémas Pydantic (Request/Response)
│
├── core/
│   ├── __init__.py
│   ├── config.py               # Configuration (Settings)
│   └── prompts.py              # Prompts socratiques
│
├── services/
│   ├── __init__.py
│   ├── minio_client.py         # Client MinIO
│   ├── ingest.py               # Ingestion & vectorisation
│   └── rag.py                  # Moteur RAG
│
├── routers/
│   ├── __init__.py
│   ├── chat.py                 # Endpoint /ask
│   └── admin.py                # Endpoint /ingest
│
├── main.py                     # Application FastAPI
├── requirements.txt            # Dépendances Python
├── .env.example                # Template de configuration
├── .env                        # Configuration (à créer)
├── .gitignore                  # Exclusions Git
├── docker-compose.yml          # MinIO Docker
└── README.md                   # Ce fichier
```

---

## 🔧 Développement

### Logs

Les logs sont écrits dans:
- Console (stdout)
- Fichier `edubot.log`

```bash
# Suivre les logs en temps réel
tail -f edubot.log
```

### Tester l'API avec Python

```python
import requests

# Indexation
response = requests.post(
    "http://localhost:8000/admin/ingest",
    json={"use_local_pdfs": True}
)
print(response.json())

# Question
response = requests.post(
    "http://localhost:8000/chat/ask",
    json={"question": "Qu'est-ce qu'une liste en Python ?"}
)
print(response.json()["answer"])
```

### Réinitialiser le cache

```bash
curl -X DELETE http://localhost:8000/admin/cache
```

### Changer de modèle LLM

Éditez `.env`:
```env
# Pour GPT-4
OPENAI_MODEL=gpt-4

# Pour Ollama Llama2
LLM_PROVIDER=ollama
OLLAMA_MODEL=llama2
```

Redémarrez l'API.

---

## 🐛 Troubleshooting

### Problème: "Index FAISS non trouvé"

**Solution:** Lancez l'ingestion d'abord:
```bash
curl -X POST http://localhost:8000/admin/ingest \
  -d '{"use_local_pdfs": true}'
```

### Problème: "OPENAI_API_KEY non configurée"

**Solution:** Ajoutez votre clé dans `.env`:
```env
OPENAI_API_KEY=sk-votre-clé-ici
```

### Problème: MinIO inaccessible

**Solution:** Vérifiez que Docker est démarré:
```bash
docker-compose ps
docker-compose up -d
```

### Problème: Dépendances manquantes

**Solution:** Réinstallez:
```bash
pip install -r requirements.txt --upgrade
```

---

## 📊 Métriques du Projet

| Métrique | Valeur |
|----------|--------|
| Fichiers Python | 10 |
| Lignes de code | ~1200 |
| Endpoints API | 5 |
| PDFs de cours | 45 |
| Taille totale PDFs | ~120 MB |
| Chunks estimés | ~3000-4000 |

---

## 📝 Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer:

1. Forkez le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos modifications (`git commit -m 'Add AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

---

## 📧 Contact

Pour toute question sur le projet EduPath-MS, contactez l'équipe de développement.

---

<div align="center">

**Fait avec ❤️ pour l'éducation**

</div>
