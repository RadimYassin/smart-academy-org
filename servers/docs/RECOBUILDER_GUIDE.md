# Guide RecoBuilder - Moteur de Recommandations Pédagogiques

## 📋 Vue d'ensemble

RecoBuilder est le 4ème composant du pipeline EduPath-MS. Il génère des recommandations personnalisées pour les étudiants en utilisant OpenAI et FAISS.

## 🔧 Configuration

### 1. Obtenir une clé API OpenAI

1. Créez un compte sur [platform.openai.com](https://platform.openai.com)
2. Générez une clé API
3. Créez un fichier `.env` à la racine du projet:

```bash
OPENAI_API_KEY=sk-votre-cle-api-ici
```

### 2. Installation des dépendances

```bash
pip install openai>=1.0.0 faiss-cpu>=1.7.0 python-dotenv>=1.0.0
```

## 💡 Utilisation

### Démo interactive

```bash
python demo_recobuilder.py
```

Menu avec 4 scénarios:
- Étudiant brillant
- Étudiant en difficulté
- Étudiant à risque modéré
- Génération batch (top 10 à risque)

### Intégration dans votre code

```python
from src.recobuilder import RecoBuilder
import pandas as pd

# Charger les données
df_clean = pd.read_csv('data/processed/data_cleaned.csv')
df_profiles = pd.read_csv('data/processed/student_profiles.csv')

# Initialiser
recommender = RecoBuilder()

# Pipeline complet
recommendations = recommender.run_all(
    resources_path='data/resources/educational_resources.json',
    df_clean=df_clean,
    df_profiles=df_profiles,
    sample_students=[101, 102, 103]  # IDs spécifiques
)

# Sauvegarder
recommender.save_recommendations(recommendations, 'outputs/recommendations.csv')
```

## 📊 Format des recommandations

Le fichier `outputs/recommendations.csv` contient:

| Colonne | Description |
|---------|-------------|
| student_id | ID de l'étudiant |
| risk_level | Niveau de risque (TRÈS ÉLEVÉ, ÉLEVÉ, MODÉRÉ, FAIBLE) |
| subject | Matière concernée |
| failure_rate | Taux d'échec dans cette matière (%) |
| resource_1, resource_2, resource_3 | Ressources recommandées |
| url_1, url_2, url_3 | Liens vers les ressources |
| personalized_plan | Plan d'action généré par GPT-4 |
| needs_tutoring | TRUE si tutorat nécessaire |

## 🎨 Personnalisation

### Ajouter des ressources

Éditez `data/resources/educational_resources.json`:

```json
{
  "resources": [
    {
      "resource_id": "custom_001",
      "title": "Votre Ressource",
      "subject": "Mathématiques",
      "type": "video",
      "difficulty": "moyen",
      "description": "Description de la ressource",
      "url": "https://example.com/resource",
      "duration_min": 60,
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

### Modifier les paramètres GPT

Dans `src/recobuilder.py`, méthode `generate_recommendations()`:

```python
response = self.client.chat.completions.create(
    model="gpt-4",  # Changer le modèle
    temperature=0.7,  # Créativité (0-1)
    max_tokens=500  # Longueur de la réponse
)
```

## 💰 Coûts estimés

Avec `text-embedding-3-small` et `gpt-4o-mini`:

- Embeddings: ~$0.0001 par 1000 tokens
- Chat: ~$0.15 par 1M tokens

**Exemple**: 100 étudiants × 3 matières = ~$0.10

## ⚠️ Dépannage

### Erreur: "No module named 'openai'"
```bash
pip install openai faiss-cpu python-dotenv
```

### Erreur: "Clé API manquante"
Vérifiez que `.env` existe avec `OPENAI_API_KEY=...`

### Erreur: "Rate limit exceeded"
Vous avez atteint la limite de l'API. Attendez ou augmentez votre quota.

## 📌 Bonnes pratiques

✅ **Limiter le batch**: Ne traitez pas plus de 50 étudiants à la fois
✅ **Cache FAISS**: L'index FAISS se reconstruit, pensez à le sauvegarder
✅ **Validation humaine**: Les recommandations GPT doivent être vérifiées
✅ **Mise à jour ressources**: Actualisez régulièrement la base de données

## 🔗 Ressources

- [Documentation OpenAI](https://platform.openai.com/docs)
- [FAISS GitHub](https://github.com/facebookresearch/faiss)
- [Guide des embeddings](https://platform.openai.com/docs/guides/embeddings)
