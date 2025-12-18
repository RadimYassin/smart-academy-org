# 🚀 EduBot API - Documentation pour Intégration

## 📋 Vue d'ensemble

EduBot expose une **API REST** complète permettant d'intégrer le chatbot pédagogique dans n'importe quelle application (web, mobile, desktop).

**Base URL:** `http://votre-serveur:8000`  
**Format:** JSON  
**Méthode:** POST pour les requêtes, GET pour l'info

---

## 🔗 Endpoints Disponibles

### 1. **Health Check** - Vérifier l'état du service

```http
GET /health
```

**Réponse:**
```json
{
  "status": "healthy",
  "faiss_index_exists": true,
  "llm_provider": "openai",
  "model": "gpt-4o-mini"
}
```

---

### 2. **Poser une Question** - Endpoint principal

```http
POST /chat/ask
```

**Body (JSON):**
```json
{
  "question": "Qu'est-ce qu'une classe en Java ?"
}
```

**Réponse:**
```json
{
  "answer": "Une classe en Java est...",
  "sources": [
    {
      "content": "...",
      "metadata": {
        "source_file": "Java-8.pdf",
        "page": 23
      }
    }
  ],
  "model_used": "gpt-4o-mini",
  "num_sources": 4
}
```

---

### 3. **Documentation Interactive** - Swagger UI

```http
GET /docs
```

Interface web pour tester tous les endpoints directement dans le navigateur.

---

## 💻 Exemples d'Intégration

### JavaScript / TypeScript (Frontend Web)

```javascript
async function askEduBot(question) {
  const response = await fetch('http://localhost:8000/chat/ask', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ question })
  });
  
  const data = await response.json();
  return data;
}

// Utilisation
const result = await askEduBot("Explique l'héritage en Python");
console.log(result.answer);
console.log(`Sources utilisées: ${result.num_sources}`);
```

---

### Python (Application Backend)

```python
import requests

def ask_edubot(question):
    url = "http://localhost:8000/chat/ask"
    response = requests.post(url, json={"question": question})
    return response.json()

# Utilisation
result = ask_edubot("Qu'est-ce qu'une méthode en Java ?")
print(result['answer'])
print(f"Modèle: {result['model_used']}")
```

---

### cURL (Ligne de commande)

```bash
curl -X POST http://localhost:8000/chat/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "Explique la POO en Java"}'
```

---

### React (Composant Chatbot)

```jsx
import React, { useState } from 'react';

function EduBotChat() {
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  const [loading, setLoading] = useState(false);

  const askQuestion = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/chat/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question })
      });
      const data = await response.json();
      setAnswer(data.answer);
    } catch (error) {
      console.error(error);
    }
    setLoading(false);
  };

  return (
    <div>
      <input 
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
        placeholder="Posez votre question..."
      />
      <button onClick={askQuestion} disabled={loading}>
        {loading ? 'Recherche...' : 'Envoyer'}
      </button>
      {answer && <p>{answer}</p>}
    </div>
  );
}
```

---

### Flutter (Application Mobile)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> askEduBot(String question) async {
  final response = await http.post(
    Uri.parse('http://votre-serveur:8000/chat/ask'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'question': question}),
  );
  
  return json.decode(response.body);
}

// Utilisation
var result = await askEduBot("Qu'est-ce qu'un constructeur en Java ?");
print(result['answer']);
```

---

## 🌐 Déploiement et Accès Externe

### Option 1: Réseau Local (WiFi)

Pour que vos amis accèdent via WiFi local :

```powershell
# Obtenez votre IP locale
ipconfig

# Lancez le serveur avec l'IP 0.0.0.0
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Vos amis peuvent accéder via : `http://VOTRE_IP:8000`

---

### Option 2: Tunnel ngrok (Accès Internet)

Pour exposer sur Internet (temporairement) :

```bash
# Installer ngrok: https://ngrok.com/download

# Lancer le tunnel
ngrok http 8000
```

Vous obtenez une URL publique : `https://xxxx.ngrok.io`

---

### Option 3: Déploiement Cloud

**Hébergement gratuit/pas cher :**
- **Render.com** (gratuit)
- **Railway.app** (gratuit)
- **Google Cloud Run** (gratuit jusqu'à certain usage)
- **AWS EC2** (petit serveur)

**Fichiers nécessaires :**
- `requirements.txt` ✅ (déjà présent)
- `Dockerfile` (je peux créer)
- `.env` (avec vos clés API)

---

## 🔒 Sécurité (Important!)

### Ajouter une Clé API

Modifiez `main.py` pour ajouter une authentification :

```python
from fastapi import Header, HTTPException

API_KEY = "votre-cle-secrete-123"

@app.post("/chat/ask")
async def ask_question_endpoint(
    request: ChatRequest,
    x_api_key: str = Header(...)
):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    
    # ... reste du code
```

**Utilisation par vos amis :**
```javascript
fetch('http://api/chat/ask', {
  headers: {
    'X-API-Key': 'votre-cle-secrete-123',
    'Content-Type': 'application/json'
  },
  // ...
})
```

---

## 📊 Limites et Quotas

Recommandations pour partage :
- ⚠️ **Coûts OpenAI** : Surveillez votre usage
- 🔐 **Rate Limiting** : Ajoutez des limites (ex: 10 req/min par utilisateur)
- 💾 **Cache** : Cachez les réponses fréquentes
- 📈 **Monitoring** : Suivez l'utilisation

---

## 🚀 Pour Démarrer

**1. Vos amis clonent ou reçoivent l'URL**

**2. Testent la santé:**
```bash
curl http://votre-url:8000/health
```

**3. Posent leur première question:**
```bash
curl -X POST http://votre-url:8000/chat/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "Test"}'
```

---

## 📖 Documentation Swagger

Vos amis peuvent voir la doc interactive sur :
```
http://votre-url:8000/docs
```

Interface complète avec :
- 📝 Tous les endpoints
- 🧪 Tests en direct
- 📚 Schémas de requêtes/réponses

---

## ⚡ Endpoints Additionnels Possibles

Voulez-vous que j'ajoute :
- `/chat/image` - Analyse d'images
- `/chat/pdf` - Analyse de PDFs
- `/chat/vocal` - Transcription + réponse
- `/chat/history` - Historique conversations

**Dites-moi et je les implémente !**
