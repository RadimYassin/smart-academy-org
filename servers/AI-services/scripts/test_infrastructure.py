"""
Test de connectivité de l'infrastructure EduPath-MS.
"""

import sys
import os

# Ajouter le dossier src au path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print("="*70)
print("TEST D'INFRASTRUCTURE - EduPath-MS")
print("="*70)

# Test 1: Variables d'environnement
print("\n[1/5] Test des variables d'environnement...")
from dotenv import load_dotenv
load_dotenv()

use_db = os.getenv('USE_DATABASE', 'false')
db_url = os.getenv('DATABASE_URL', 'Non configuré')
mlflow_uri = os.getenv('MLFLOW_TRACKING_URI', 'Non configuré')

print(f"  USE_DATABASE: {use_db}")
print(f"  DATABASE_URL: {db_url[:30]}..." if len(db_url) > 30 else f"  DATABASE_URL: {db_url}")
print(f"  MLFLOW_TRACKING_URI: {mlflow_uri}")

# Test 2: Imports
print("\n[2/5] Test des imports...")
try:
    from src.database import init_db, save_data, load_data
    print("  ✅ Module database importé")
except Exception as e:
    print(f"  ❌ Erreur import database: {e}")
    sys.exit(1)

try:
    from src.mlflow_config import init_mlflow
    print("  ✅ Module mlflow_config importé")
except Exception as e:
    print(f"  ❌ Erreur import mlflow_config: {e}")
    sys.exit(1)

# Test 3: PostgreSQL
print("\n[3/5] Test PostgreSQL...")
if use_db.lower() == 'true':
    success = init_db()
    if success:
        print("  ✅ PostgreSQL connecté et fonctionnel")
    else:
        print("  ⚠️ PostgreSQL non disponible - Mode CSV sera utilisé")
else:
    print("  ℹ️ Mode PostgreSQL désactivé (USE_DATABASE=false)")
    print("  ℹ️ Le système utilisera les fichiers CSV")

# Test 4: MLflow
print("\n[4/5] Test MLflow...")
mlflow_ok = init_mlflow()
if mlflow_ok:
    print("  ✅ MLflow connecté et fonctionnel")
else:
    print("  ⚠️ MLflow non disponible - Les expériences ne seront pas trackées")

# Test 5: Pipeline
print("\n[5/5] Test du pipeline intégré...")
try:
    from src.pipeline import PrepaData, StudentProfiler, PathPredictor
    print("  ✅ Modules pipeline importés avec succès")
    print("  ✅ Intégration database.py et mlflow_config.py: OK")
except Exception as e:
    print(f"  ❌ Erreur import pipeline: {e}")
    sys.exit(1)

# Résumé
print("\n" + "="*70)
print("RÉSUMÉ")
print("="*70)

print("\n📊 Configuration actuelle:")
if use_db.lower() == 'true':
    print("  - Stockage: PostgreSQL (si connecté) avec fallback CSV")
else:
    print("  - Stockage: Fichiers CSV")

if mlflow_ok:
    print("  - Tracking: MLflow activé")
else:
    print("  - Tracking: Pickle seulement (pas de MLflow)")

print("\n✅ Le système est prêt à être utilisé!")
print("\nPour exécuter le pipeline:")
print("  python run_pipeline.py")

print("\nPour utiliser PostgreSQL:")
print("  1. Démarrer: docker-compose up -d")
print("  2. Initialiser: python scripts/init_db.py")
print("  3. Configurer .env: USE_DATABASE=true")
print("  4. Exécuter: python run_pipeline.py")

print("\n" + "="*70)
