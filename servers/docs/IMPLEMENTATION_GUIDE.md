# 📚 EduPath-MS - Guide d'Implémentation Complet

**Documentation pour Développeurs**  
**Version**: 1.0  
**Date**: Décembre 2025

---

## 🎯 À Propos de ce Projet

EduPath-MS est une **plateforme complète de Learning Analytics** composée de **4 microservices** pour:
- ✅ Analyser les données d'apprentissage
- ✅ Profiler les étudiants automatiquement
- ✅ Prédire les risques d'échec
- ✅ Générer des recommandations personnalisées

### Pourquoi utiliser EduPath-MS ?

- **Réduire le décrochage**: Identifier les étudiants à risque avant qu'il ne soit trop tard
- **Personnalisation**: Recommandations adaptées à chaque profil
- **Automatisation**: Pipeline ML complet sans intervention manuelle
- **Scalable**: Architecture microservices prête pour production

---

## 📂 Structure du Projet

```
EduPath-MS/
│
├── 📁 src/                          # Code source des microservices
│   ├── __init__.py
│   ├── config.py                    # Configuration centralisée
│   ├── database.py                  # Module PostgreSQL
│   ├── mlflow_config.py             # Configuration MLflow
│   ├── pipeline.py                  # Les 3 premiers microservices
│   └── recobuilder.py              # 4ème microservice (recommandations)
│
├── 📁 data/                         # Données et ressources
│   ├── raw/                         # Données brutes
│   ├── processed/                   # Données traitées
│   └── resources/                   # Ressources pédagogiques
│       └── educational_resources.json
│
├── 📁 outputs/                      # Résultats du pipeline
│   ├── figures/                     # Visualisations
│   ├── models/                      # Modèles ML sauvegardés
│   └── recommendations.csv          # Recommandations générées
│
├── 📁 airflow/                      # Orchestration
│   └── dags/
│       └── edupath_pipeline.py     # DAG principal
│
├── 📁 scripts/                      # Scripts utilitaires
│   └── init_db.py                  # Initialisation PostgreSQL
│
├── 📁 docs/                         # Documentation
│   ├── INFRASTRUCTURE_SETUP.md     # Setup infrastructure
│   ├── RECOBUILDER_GUIDE.md        # Guide RecoBuilder
│   └── IMPLEMENTATION_GUIDE.md     # 👈 CE FICHIER
│
├── 📄 docker-compose.yml           # Infrastructure Docker
├── 📄 requirements.txt             # Dépendances Python
├── 📄 .env.example                 # Template configuration
├── 📄 run_pipeline.py              # Script principal
└── 📄 README.md                    # Vue d'ensemble
```

---

## 🧩 Les 4 Microservices

### 1️⃣ PrepaData - Nettoyage des Données

**Rôle**: Nettoyer, normaliser et préparer les données pour l'analyse.

**Input**:
- Fichiers CSV avec notes des étudiants
- Colonnes: ID, Subject, Practical, Theoretical, Total, Status, etc.

**Output**:
- Données nettoyées (CSV ou PostgreSQL)
- Variable cible `is_fail` créée
- Matières encodées numériquement

**Utilisation**:
```python
from src.pipeline import PrepaData

preparer = PrepaData(df)
df_clean = preparer.run_all(threshold=10)
```

**Fonctionnalités**:
- ✅ Recalcul de la colonne Total
- ✅ Encodage des matières (LabelEncoder)
- ✅ Création variable binaire is_fail

---

### 2️⃣ StudentProfiler - Clustering d'Étudiants

**Rôle**: Identifier des profils types d'étudiants (excellents, en difficulté, décrocheurs).

**Input**:
- Données nettoyées de PrepaData

**Output**:
- Profils étudiants avec clusters (CSV ou PostgreSQL)
- Visualisations (PCA, méthode du coude)

**Utilisation**:
```python
from src.pipeline import StudentProfiler

profiler = StudentProfiler(df_clean)
student_profiles = profiler.run_all(n_clusters=4)
```

**Algorithmes**:
- 🔹 K-Means clustering
- 🔹 PCA pour visualisation
- 🔹 Méthode du coude pour K optimal

**Profils détectés**:
- 🟢 Excellents
- 🟡 Moyens/Stables
- 🟠 En difficulté
- 🔴 Décrocheurs

---

### 3️⃣ PathPredictor - Prédiction ML

**Rôle**: Prédire la probabilité de réussite/échec d'un étudiant.

**Input**:
- Données nettoyées de PrepaData

**Output**:
- Modèle XGBoost entraîné
- Prédictions avec probabilités
- Métriques de performance
- Feature importance

**Utilisation**:
```python
from src.pipeline import PathPredictor

predictor = PathPredictor(df_clean)
model = predictor.run_all()
```

**Algorithme**:
- 🤖 XGBoost Classifier
- 📊 Gestion du déséquilibre de classes
- 📈 Tracking MLflow (optionnel)

**Performance**:
- Accuracy: 88-90%
- Précision + Recall équilibrés

---

### 4️⃣ RecoBuilder - Recommandations Personnalisées

**Rôle**: Générer des recommandations pédagogiques ciblées.

**Input**:
- Données nettoyées (PrepaData)
- Profils étudiants (StudentProfiler)
- Base de ressources pédagogiques

**Output**:
- Recommandations par étudiant (CSV ou PostgreSQL)
- Plans d'action personnalisés (GPT-4)
- Ressources adaptées (FAISS)

**Utilisation**:
```python
from src.recobuilder import RecoBuilder

recommender = RecoBuilder()
recommendations = recommender.run_all(
    resources_path='data/resources/educational_resources.json',
    df_clean=df_clean,
    df_profiles=df_profiles
)
```

**Technologies**:
- 🧠 OpenAI GPT-4 (génération de plans)
- 🔍 OpenAI Embeddings (similarité sémantique)
- ⚡ FAISS (recherche vectorielle)

---

## 🚀 Installation Rapide

### Prérequis

- Python 3.8+
- Docker Desktop (optionnel mais recommandé)
- Clé API OpenAI (pour RecoBuilder)

### Installation

```bash
# 1. Cloner le projet
git clone <votre-repo>
cd EduPath-MS

# 2. Installer les dépendances
pip install -r requirements.txt

# 3. Configurer .env
cp .env.example .env
# Éditer .env avec votre clé OpenAI

# 4. Exécuter le pipeline
python run_pipeline.py
```

### Avec Docker (Infrastructure complète)

```bash
# Démarrer PostgreSQL + MLflow + Airflow
docker-compose up -d

# Initialiser la base de données
python scripts/init_db.py

# Configurer .env
USE_DATABASE=true

# Exécuter
python run_pipeline.py
```

---

## 💡 Comment Adapter à Votre Plateforme

### Étape 1: Préparer vos données

Vos données doivent contenir au minimum:

| Colonne | Description | Exemple |
|---------|-------------|---------|
| `ID` | Identifiant étudiant | 12345 |
| `Subject` | Matière | Mathématiques |
| `Total` | Note finale | 75 |
| `Status` | Statut | Success/Fail |

**Format CSV attendu**:
```csv
ID,Subject,Practical,Theoretical,Total,Status,Semester
12345,Math,40,35,75,Success,1
12345,Physics,25,20,45,Fail,1
```

### Étape 2: Adapter les seuils

Dans `src/config.py`:

```python
# Seuil d'échec (ajuster selon votre système de notation)
DEFAULT_FAIL_THRESHOLD = 10  # Modifier selon votre besoin

# Nombre de clusters (profils étudiants)
DEFAULT_N_CLUSTERS = 4  # 3-5 recommandé
```

### Étape 3: Personnaliser les ressources

Modifiez `data/resources/educational_resources.json`:

```json
{
  "resources": [
    {
      "resource_id": "custom_001",
      "title": "Votre Ressource",
      "subject": "Mathématiques",
      "type": "video",
      "difficulty": "moyen",
      "description": "Description",
      "url": "https://votre-lms.com/resource1",
      "duration_min": 60,
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

### Étape 4: Intégrer à votre LMS

**Option A - API REST** (recommandé):

Créez une API Flask/FastAPI:

```python
from flask import Flask, request, jsonify
from src.recobuilder import RecoBuilder

app = Flask(__name__)

@app.route('/api/recommend/<student_id>', methods=['GET'])
def get_recommendations(student_id):
    recommender = RecoBuilder()
    # ... charger données ...
    profile = recommender.analyze_student_profile(student_id, df_clean, df_profiles)
    reco = recommender.generate_recommendations(profile)
    return jsonify(reco)
```

**Option B - Fichiers CSV**:

Exportez les résultats et importez-les dans votre LMS:
```python
# Les recommandations sont dans outputs/recommendations.csv
# Importez ce fichier dans votre système
```

---

## 📊 Exemples d'Utilisation

### Exemple 1: Pipeline Complet

```python
import pandas as pd
from src.pipeline import PrepaData, StudentProfiler, PathPredictor
from src.recobuilder import RecoBuilder

# 1. Charger vos données
df = pd.read_csv('mes_donnees.csv')

# 2. Pipeline complet
preparer = PrepaData(df)
df_clean = preparer.run_all()

profiler = StudentProfiler(df_clean)
profiles = profiler.run_all(n_clusters=4)

predictor = PathPredictor(df_clean)
model = predictor.run_all()

# 3. Recommandations
recommender = RecoBuilder()
recommendations = recommender.run_all(
    resources_path='data/resources/educational_resources.json',
    df_clean=df_clean,
    df_profiles=profiles
)

print(f"✅ {len(recommendations)} recommandations générées")
```

### Exemple 2: Recommandations pour un étudiant spécifique

```python
from src.recobuilder import RecoBuilder

recommender = RecoBuilder()
recommender.load_resources('data/resources/educational_resources.json')
recommender.build_faiss_index()

# Analyser un étudiant
profile = recommender.analyze_student_profile(
    student_id=12345,
    df_clean=df_clean,
    df_profiles=profiles
)

# Générer recommandations
reco = recommender.generate_recommendations(profile)

print(f"Niveau de risque: {reco['risk_level']}")
print(f"Nombre de recommandations: {len(reco['recommendations'])}")
```

---

## 🔧 Configuration Avancée

### PostgreSQL

Modifier `DATA_URL` dans `.env`:

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/votre_db
USE_DATABASE=true
```

### MLflow

Modifier `MLFLOW_TRACKING_URI` dans `.env`:

```bash
MLFLOW_TRACKING_URI=http://votre-serveur:5000
```

### Airflow

Planifier l'exécution quotidienne:

```python
# Dans airflow/dags/edupath_pipeline.py
dag = DAG(
    'edupath_ms_pipeline',
    schedule_interval='@daily',  # Modifier ici
    ...
)
```

---

## 🆘 Support et Dépannage

### Problème: ImportError

```bash
pip install -r requirements.txt --upgrade
```

### Problème: PostgreSQL connexion refusée

```bash
# Vérifier que PostgreSQL est démarré
docker ps

# Redémarrer si nécessaire
docker-compose restart postgres
```

### Problème: OpenAI rate limit

Réduire le nombre d'étudiants traités:

```python
# Dans demo_recobuilder.py
sample_students = student_ids[:10]  # Limiter à 10
```

---

## 📖 Documentation Complète

- `README.md` - Vue d'ensemble
- `docs/INFRASTRUCTURE_SETUP.md` - Setup PostgreSQL/MLflow/Airflow
- `docs/RECOBUILDER_GUIDE.md` - Guide RecoBuilder détaillé
- `docs/IMPLEMENTATION_GUIDE.md` - Ce fichier

---

## 🤝 Contribuer

Pour adapter ce projet:

1. **Forkez** le repository
2. **Modifiez** selon vos besoins
3. **Testez** avec vos données
4. **Documentez** vos changements

---

## 📝 License

Projet académique - Libre d'utilisation pour l'éducation

---

## ✉️ Contact

Pour questions ou support, contactez le mainteneur du projet.

---

**Bon développement ! 🚀**
