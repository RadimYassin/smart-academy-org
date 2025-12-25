"""
Configuration centralisée pour le projet EduPath-MS.
Tous les chemins et paramètres sont définis ici.
"""

import os

# Dossier racine du projet
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Chemins des données
DATA_DIR = os.path.join(PROJECT_ROOT, 'data')
RAW_DATA_DIR = os.path.join(DATA_DIR, 'raw')
PROCESSED_DATA_DIR = os.path.join(DATA_DIR, 'processed')

# Chemins des fichiers de données brutes
DATASET_1 = os.path.join(RAW_DATA_DIR, '1- one_clean.csv')
DATASET_2 = os.path.join(RAW_DATA_DIR, '2- two_clean.csv')

# Chemins des sorties
OUTPUTS_DIR = os.path.join(PROJECT_ROOT, 'outputs')
FIGURES_DIR = os.path.join(OUTPUTS_DIR, 'figures')
MODELS_DIR = os.path.join(OUTPUTS_DIR, 'models')

# Fichiers de sortie
CLEANED_DATA = os.path.join(PROCESSED_DATA_DIR, 'data_cleaned.csv')
STUDENT_PROFILES = os.path.join(PROCESSED_DATA_DIR, 'student_profiles.csv')

# Graphiques
ELBOW_PLOT = os.path.join(FIGURES_DIR, 'elbow_method.png')
CLUSTERS_PLOT = os.path.join(FIGURES_DIR, 'student_clusters.png')
CONFUSION_MATRIX_PLOT = os.path.join(FIGURES_DIR, 'confusion_matrix.png')
FEATURE_IMPORTANCE_PLOT = os.path.join(FIGURES_DIR, 'feature_importance.png')

# Modèle
XGBOOST_MODEL = os.path.join(MODELS_DIR, 'xgboost_model.pkl')

# Paramètres par défaut
DEFAULT_FAIL_THRESHOLD = 10  # Seuil de note minimum pour la réussite
DEFAULT_N_CLUSTERS = 4       # Nombre de clusters pour K-Means

# Configuration RecoBuilder (Composant 4)
RESOURCES_DIR = os.path.join(DATA_DIR, 'resources')
EDUCATIONAL_RESOURCES = os.path.join(RESOURCES_DIR, 'educational_resources.json')
FAISS_INDEX = os.path.join(MODELS_DIR, 'faiss_index.bin')
RECOMMENDATIONS_OUTPUT = os.path.join(OUTPUTS_DIR, 'recommendations.csv')

# Configuration PostgreSQL (Infrastructure)
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://edupath_user:edupath_password@localhost:5432/edupath_db')
USE_DATABASE = os.getenv('USE_DATABASE', 'false').lower() == 'true'

# Configuration MLflow (Tracking ML)
MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
MLFLOW_EXPERIMENT_NAME = 'EduPath-MS'

# Créer les dossiers s'ils n'existent pas
for directory in [RAW_DATA_DIR, PROCESSED_DATA_DIR, FIGURES_DIR, MODELS_DIR, RESOURCES_DIR]:
    os.makedirs(directory, exist_ok=True)
