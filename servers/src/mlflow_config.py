"""
Configuration et helper functions pour MLflow tracking.
Permet de tracker les expériences ML et les modèles.
"""

import os
import mlflow
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()

# Configuration
MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
EXPERIMENT_NAME = "EduPath-MS"


def init_mlflow():
    """
    Initialise MLflow tracking.
    """
    try:
        mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
        mlflow.set_experiment(EXPERIMENT_NAME)
        print(f"✅ MLflow initialisé: {MLFLOW_TRACKING_URI}")
        return True
    except Exception as e:
        print(f"⚠️ MLflow non disponible: {e}")
        print(f"   Les métriques ne seront pas trackées")
        return False


def start_run(run_name=None):
    """
    Démarre un run MLflow.
    
    Args:
        run_name: Nom optionnel du run
    
    Returns:
        Run context ou None si MLflow non disponible
    """
    try:
        return mlflow.start_run(run_name=run_name)
    except:
        return None


def log_params(params):
    """
    Log les paramètres d'un modèle.
    
    Args:
        params: Dict des paramètres
    """
    try:
        for key, value in params.items():
            mlflow.log_param(key, value)
    except:
        pass


def log_metrics(metrics):
    """
    Log les métriques d'un modèle.
    
    Args:
        metrics: Dict des métriques
    """
    try:
        for key, value in metrics.items():
            mlflow.log_metric(key, value)
    except:
        pass


def log_model(model, artifact_path, **kwargs):
    """
    Log un modèle dans MLflow.
    
    Args:
        model: Modèle à logger
        artifact_path: Chemin de l'artifact
        **kwargs: Arguments supplémentaires
    """
    try:
        mlflow.xgboost.log_model(model, artifact_path, **kwargs)
        print(f"✅ Modèle loggé dans MLflow: {artifact_path}")
        return True
    except Exception as e:
        print(f"⚠️ Modèle non loggé dans MLflow: {e}")
        return False


def log_artifact(local_path, artifact_path=None):
    """
    Log un artifact (figure, fichier, etc).
    
    Args:
        local_path: Chemin local du fichier
        artifact_path: Chemin dans MLflow (optionnel)
    """
    try:
        mlflow.log_artifact(local_path, artifact_path)
        return True
    except:
        return False


def end_run():
    """
    Termine le run MLflow actif.
    """
    try:
        mlflow.end_run()
    except:
        pass


# Context manager pour faciliter l'utilisation
class MLflowRun:
    """
    Context manager pour gérer automatiquement les runs MLflow.
    
    Usage:
        with MLflowRun("my_experiment"):
            mlflow_config.log_params({...})
            mlflow_config.log_metrics({...})
    """
    
    def __init__(self, run_name=None):
        self.run_name = run_name
        self.run = None
    
    def __enter__(self):
        try:
            self.run = mlflow.start_run(run_name=self.run_name)
            return self
        except:
            return None
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            mlflow.end_run()
        except:
            pass


# Test
if __name__ == "__main__":
    print("Test du module MLflow...")
    
    if init_mlflow():
        print("✅ Configuration MLflow réussie")
        
        # Test avec un run simple
        with MLflowRun("test_run"):
            log_params({"param1": "value1"})
            log_metrics({"metric1": 0.95})
            print("✅ Test run MLflow créé")
    else:
        print("⚠️ MLflow non configuré (normal si serveur non démarré)")
