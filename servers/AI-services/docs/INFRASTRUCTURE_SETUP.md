# Guide d'Installation et Configuration - Infrastructure EduPath-MS

Ce guide explique comment installer et configurer **PostgreSQL**, **MLflow** et **Airflow** pour le projet EduPath-MS.

---

## 📋 Prérequis

- Python 3.8+
- Docker et Docker Compose (recommandé)
- OU PostgreSQL installé localement

---

## 🚀 Option 1: Déploiement avec Docker (RECOMMANDÉ)

### Étape 1: Démarrage des services

```bash
# Démarrer tous les services (PostgreSQL + MLflow + Airflow)
docker-compose up -d

# Vérifier que tout fonctionne
docker-compose ps
```

Les services seront disponibles sur:
- **PostgreSQL**: `localhost:5432`
- **MLflow UI**: http://localhost:5000
- **Airflow UI**: http://localhost:8080 (admin/admin)

### Étape 2: Initialiser la base de données

```bash
# Créer les tables
python scripts/init_db.py
```

### Étape 3: Configurer les variables d'environnement

Créez un fichier `.env`:
```bash
# Copier le template
cp .env.example .env

# Éditer avec vos valeurs
DATABASE_URL=postgresql://edupath_user:edupath_password@localhost:5432/edupath_db
MLFLOW_TRACKING_URI=http://localhost:5000
USE_DATABASE=true
OPENAI_API_KEY=sk-your-key-here
```

### Étape 4: Exécuter le pipeline

**Mode Manuel**:
```bash
python run_pipeline.py
```

**Mode Airflow**:
1. Aller sur http://localhost:8080
2. Login: admin/admin
3. Activer le DAG `edupath_ms_pipeline`
4. Cliquer sur "Trigger DAG"

---

## 🛠️ Option 2: Installation Locale (Sans Docker)

### Étape 1: Installer PostgreSQL

**Windows**:
1. Télécharger depuis https://www.postgresql.org/download/windows/
2. Installer avec les paramètres par défaut

**MacOS**:
```bash
brew install postgresql
brew services start postgresql
```

**Linux (Ubuntu)**:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Étape 2: Créer l'utilisateur et la base de données

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Dans psql:
CREATE USER edupath_user WITH PASSWORD 'edupath_password';
CREATE DATABASE edupath_db OWNER edupath_user;
GRANT ALL PRIVILEGES ON DATABASE edupath_db TO edupath_user;
\q
```

### Étape 3: Installer MLflow

```bash
pip install mlflow

# Démarrer le serveur MLflow
mlflow server --backend-store-uri postgresql://edupath_user:edupath_password@localhost/edupath_db --default-artifact-root ./mlruns --host 0.0.0.0 --port 5000
```

Accéder à l'interface: http://localhost:5000

### Étape 4: Installer Airflow

```bash
# Installer Airflow
pip install apache-airflow

# Initialiser la base de données Airflow
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql://edupath_user:edupath_password@localhost/edupath_db
airflow db init

# Créer un utilisateur admin
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@edupath.com \
    --password admin

# Démarrer Airflow webserver et scheduler
airflow webserver --port 8080 &
airflow scheduler &
```

Accéder à l'interface: http://localhost:8080

### Étape 5: Configuration

Créer `.env`:
```bash
DATABASE_URL=postgresql://edupath_user:edupath_password@localhost:5432/edupath_db
MLFLOW_TRACKING_URI=http://localhost:5000
USE_DATABASE=true
OPENAI_API_KEY=sk-your-key-here
```

Initialiser la base:
```bash
python scripts/init_db.py
```

---

## 📊 Utilisation

### Mode CSV (Sans PostgreSQL)

Par défaut, le système fonctionne en mode CSV:

```bash
# Dans .env:
USE_DATABASE=false

# Exécuter
python run_pipeline.py
```

### Mode PostgreSQL

Activez PostgreSQL dans `.env`:

```bash
# Dans .env:
USE_DATABASE=true

# Exécuter
python run_pipeline.py
```

Les données seront stockées dans PostgreSQL au lieu de CSV.

### MLflow Tracking

Quand MLflow est configuré, les expériences sont automatiquement trackées:

```bash
# Voir les expériences
mlflow ui  # Ouvrir http://localhost:5000
```

### Airflow Orchestration

Le DAG `edupath_ms_pipeline` orchestre automatiquement:
1. **load_data**: Chargement des données
2. **prepa_data**: Nettoyage (PrepaData)
3. **student_profiler**: Clustering (StudentProfiler)
4. **path_predictor**: Prédiction (PathPredictor) avec MLflow
5. **reco_builder**: Recommandations (RecoBuilder)

**Exécution manuelle**:
```bash
airflow dags test edupath_ms_pipeline
```

**Exécution programmée**:
- Schedule: `@daily` (1x par jour)
- Modifiable dans `airflow/dags/edupath_pipeline.py`

---

## 🧪 Tests

### Vérifier PostgreSQL

```bash
# Test de connexion
python -c "from src.database import init_db; init_db()"
```

### Vérifier MLflow

```bash
# Test
python -c "from src.mlflow_config import init_mlflow; init_mlflow()"
```

### Vérifier Airflow

```bash
# Lister les DAGs
airflow dags list

# Devrait afficher: edupath_ms_pipeline
```

---

## 🔧 Dépannage

### PostgreSQL: "Connection refused"

- Vérifiez que PostgreSQL est démarré
- Vérifiez le port (5432) n'est pas utilisé
- Vérifiez DATABASE_URL dans .env

### MLflow: Erreur de connexion

- Démarrez le serveur: `mlflow server ...`
- Vérifiez MLFLOW_TRACKING_URI dans .env

### Airflow: DAG non visible

- Vérifiez que le fichier DAG est dans `airflow/dags/`
- Redémarrez le scheduler: `airflow scheduler`
- Vérifiez les logs: `airflow/logs/`

---

## 📌 Architecture Finale

```
┌──────────────┐
│  Airflow     │  Orchestration
│  (8080)      │
└──────┬───────┘
       │
┌──────▼───────┐
│  Pipeline    │  4 Microservices
│  Python      │
└──────┬───────┘
       │
┌──────▼───────────────────┐
│  PostgreSQL   │  MLflow  │
│  (5432)       │  (5000)  │
└───────────────┴──────────┘
```

---

## ✅ Checklist de Déploiement

- [ ] PostgreSQL installé et démarré
- [ ] Base de données `edupath_db` créée
- [ ] Tables initialisées (`python scripts/init_db.py`)
- [ ] MLflow serveur démarré
- [ ] Airflow webserver + scheduler démarrés
- [ ] Fichier `.env` configuré
- [ ] Dépendances installées (`pip install -r requirements.txt`)
- [ ] DAG visible dans Airflow UI
- [ ] Test d'exécution réussi

---

**Vous êtes prêt ! Le système est maintenant 100% conforme au cahier des charges.** 🎉
