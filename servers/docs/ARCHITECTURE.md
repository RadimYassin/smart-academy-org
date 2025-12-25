# 🏗️ Architecture EduPath-MS - Guide Technique

## Vue d'ensemble de l'Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    COUCHE ORCHESTRATION                          │
│                    Apache Airflow (DAG)                          │
│                    Schedule: @daily                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────────┐
│                   COUCHE MICROSERVICES                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │PrepaData │→ │Student   │→ │Path      │→ │Reco      │       │
│  │          │  │Profiler  │  │Predictor │  │Builder   │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│      │              │              │              │             │
│   Pandas       KMeans+PCA     XGBoost      OpenAI+FAISS        │
└──────┬─────────────┬──────────────┬──────────────┬─────────────┘
       │             │              │              │
┌──────▼─────────────▼──────────────▼──────────────▼─────────────┐
│                  COUCHE PERSISTENCE                              │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐         │
│  │ PostgreSQL  │  │   MLflow     │  │  Fichiers     │         │
│  │ (Tables)    │  │ (Tracking)   │  │   (CSV/JSON)  │         │
│  └─────────────┘  └──────────────┘  └───────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Flux de Données

### Phase 1: Ingestion et Nettoyage

```
[Données Brutes CSV]
         │
         ▼
   [PrepaData]
    - Validation
    - Normalisation
    - Encodage
    - Feature engineering
         │
         ▼
[Données Nettoyées]
    ├─> PostgreSQL: table cleaned_data
    └─> CSV: data/processed/data_cleaned.csv
```

### Phase 2: Profiling

```
[Données Nettoyées]
         │
         ▼
  [StudentProfiler]
    - Agrégation par ID
    - Normalisation
    - K-Means clustering
    - PCA visualisation
         │
         ▼
[Profils Étudiants]
    ├─> PostgreSQL: table student_profiles
    └─> CSV: data/processed/student_profiles.csv
```

### Phase 3: Prédiction

```
[Données Nettoyées]
         │
         ▼
   [PathPredictor]
    - Feature extraction
    - Train/Test split
    - XGBoost training
    - Évaluation
         │
         ├─> [Modèle XGBoost]
         │   ├─> MLflow: expérience trackée
         │   └─> Pickle: outputs/models/xgboost_model.pkl
         │
         └─> [Prédictions]
             ├─> PostgreSQL: table predictions
             └─> Intégré dans le modèle
```

### Phase 4: Recommandations

```
[Profils] + [Données] + [Ressources]
         │
         ▼
   [RecoBuilder]
    - Analyse profil
    - Embeddings (OpenAI)
    - Recherche FAISS
    - Génération GPT-4
         │
         ▼
 [Recommandations]
    ├─> PostgreSQL: table recommendations
    └─> CSV: outputs/recommendations.csv
```

---

## 🔧 Technologies par Composant

### PrepaData
```
Langage: Python 3.8+
Librairies:
  - pandas (manipulation données)
  - scikit-learn (LabelEncoder)
  - numpy (calculs)

Input: CSV brut
Output: DataFrame nettoyé
```

### StudentProfiler
```
Langage: Python 3.8+
Librairies:
  - scikit-learn (KMeans, StandardScaler, PCA)
  - matplotlib + seaborn (visualisations)

Algorithmes:
  - K-Means clustering
  - PCA (réduction dimensionnalité)
  - Silhouette Score (validation)

Input: DataFrame nettoyé
Output: DataFrame avec clusters
```

### PathPredictor
```
Langage: Python 3.8+
Librairies:
  - xgboost (classification)
  - scikit-learn (métriques, split)
  - mlflow (tracking)

Algorithme:
  - XGBoost Classifier
  - Gestion déséquilibre: scale_pos_weight

Input: DataFrame nettoyé
Output: Modèle + prédictions
```

### RecoBuilder
```
Langage: Python 3.8+
Librairies:
  - openai (GPT-4 + Embeddings)
  - faiss (recherche vectorielle)
  - python-dotenv (configuration)

APIs:
  - OpenAI text-embedding-3-small
  - OpenAI gpt-4o-mini

Input: Profils + Ressources
Output: Recommandations personnalisées
```

---

## 💾 Schéma Base de Données PostgreSQL

### Table: cleaned_data
```sql
CREATE TABLE cleaned_data (
    id SERIAL PRIMARY KEY,
    student_id INTEGER,
    subject VARCHAR(255),
    subject_encoded INTEGER,
    semester INTEGER,
    practical FLOAT,
    theoretical FLOAT,
    total FLOAT,
    is_fail INTEGER,
    major VARCHAR(100),
    major_year INTEGER,
    status VARCHAR(50)
);
```

### Table: student_profiles
```sql
CREATE TABLE student_profiles (
    id SERIAL PRIMARY KEY,
    student_id INTEGER UNIQUE,
    average_grade FLOAT,
    total_failures INTEGER,
    total_courses INTEGER,
    avg_practical FLOAT,
    avg_theoretical FLOAT,
    failure_rate FLOAT,
    absence_count INTEGER,
    cluster INTEGER
);
```

### Table: predictions
```sql
CREATE TABLE predictions (
    id SERIAL PRIMARY KEY,
    student_id INTEGER,
    subject VARCHAR(255),
    prediction INTEGER,
    probability_fail FLOAT,
    probability_success FLOAT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Table: recommendations
```sql
CREATE TABLE recommendations (
    id SERIAL PRIMARY KEY,
    student_id INTEGER,
    risk_level VARCHAR(50),
    subject VARCHAR(255),
    failure_rate FLOAT,
    resource_1 TEXT,
    resource_2 TEXT,
    resource_3 TEXT,
    personalized_plan TEXT,
    needs_tutoring BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔄 Mode Hybride (CSV/PostgreSQL)

Le système supporte 2 modes:

### Mode CSV (Défaut)
```python
# Dans .env
USE_DATABASE=false

# Utilise:
- df.to_csv() pour sauvegarder
- pd.read_csv() pour charger
```

### Mode PostgreSQL
```python
# Dans .env
USE_DATABASE=true

# Utilise:
- save_data() qui appelle df.to_sql()
- load_data() qui appelle pd.read_sql()
```

**Avantage**: Fallback automatique vers CSV si PostgreSQL non disponible

---

## 📈 MLflow Tracking

### Expériences trackées

```python
with MLflowRun("path_predictor_run"):
    # Paramètres du modèle
    mlflow.log_param("max_depth", 6)
    mlflow.log_param("learning_rate", 0.1)
    mlflow.log_param("n_estimators", 100)
    
    # Métriques
    mlflow.log_metric("accuracy", 0.89)
    mlflow.log_metric("precision", 0.85)
   

 mlflow.log_metric("recall", 0.87)
    
    # Modèle
    mlflow.xgboost.log_model(model, "xgboost_model")
    
    # Artifacts (figures)
    mlflow.log_artifact("outputs/figures/confusion_matrix.png")
```

### Accès UI MLflow

```bash
# URL: http://localhost:5000
# Voir:
- Historique des runs
- Comparaison des métriques
- Téléchargement des modèles
```

---

## 🔄 Orchestration Airflow

### DAG Structure

```python
# 5 tâches séquentielles
load_data → prepa_data → student_profiler → path_predictor → reco_builder

# Schedule: @daily (1x par jour)
```

### Configuration

```python
# Dans airflow/dags/edupath_pipeline.py

# Modifier le schedule
dag = DAG(
    'edupath_ms_pipeline',
    schedule_interval='@daily',  # ou '@weekly', '@hourly'
    ...
)
```

---

## 🔐 Sécurité et Bonnes Pratiques

### Variables d'environnement

**Jamais** commit `.env` dans Git:

```bash
# .gitignore
.env
*.pkl
mlruns/
```

### Validation des données

```python
# Toujours valider l'input
assert 'ID' in df.columns
assert 'Total' in df.columns
assert df['Total'].between(0, 100).all()
```

### Gestion des erreurs

```python
try:
    recommender = RecoBuilder()
    recommendations = recommender.run_all(...)
except OpenAIError:
    logger.error("OpenAI API error")
    # Fallback: recommandations basiques
except Exception as e:
    logger.error(f"Unexpected error: {e}")
```

---

## 📊 Performance et Optimisation

### Temps d'exécution (estimation)

| Composant | 1000 étudiants | 10000 étudiants |
|-----------|----------------|-----------------|
| PrepaData | ~2 sec | ~10 sec |
| StudentProfiler | ~5 sec | ~30 sec |
| PathPredictor | ~10 sec | ~60 sec |
| RecoBuilder | ~30 sec* | ~300 sec* |

*Dépend de l'API OpenAI

### Optimisations possibles

1. **Batch processing** pour RecoBuilder
2. **Caching** des embeddings FAISS
3. **Parallélisation** avec Dask/Ray
4. **GPU** pour XGBoost training

---

## 🧪 Tests

### Tests unitaires

```python
# test_prepa_data.py
def test_recalculate_total():
    df = pd.DataFrame({
        'Practical': [40],
        'Theoretical': [35],
        'Total': [0]
    })
    preparer = PrepaData(df)
    preparer.recalculate_total()
    assert preparer.df['Total'].iloc[0] == 75
```

### Tests d'intégration

```bash
# Tester le pipeline complet
python run_pipeline.py

# Vérifier les outputs
ls outputs/
ls data/processed/
```

---

## 📚 Ressources Complémentaires

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Apache Airflow](https://airflow.apache.org/docs/)
- [XGBoost](https://xgboost.readthedocs.io/)
- [OpenAI API](https://platform.openai.com/docs)
- [FAISS](https://github.com/facebookresearch/faiss)

---

**Dernière mise à jour**: Décembre 2025
