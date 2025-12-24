"""
Configuration MLflow pour le tracking des expériences ML.
MLflow est optionnel - si non disponible, le système fonctionnera sans tracking.
"""

import os
from contextlib import contextmanager

# Try to import mlflow, but make it optional
try:
    import mlflow
    import mlflow.sklearn # Assuming sklearn models might be logged, as per common use cases
    MLFLOW_AVAILABLE = True
except ImportError:
    MLFLOW_AVAILABLE = False
    print("⚠️  MLflow not available. Experiment tracking disabled. Install with: pip install mlflow")

# Configuration values are now expected from a config file
# If src.config doesn't exist or these variables aren't there, this will cause an ImportError/AttributeError.
# For this change, I'll assume src.config exists and contains these.
try:
    from src.config import MLFLOW_TRACKING_URI, MLFLOW_EXPERIMENT_NAME
except ImportError:
    # Fallback if src.config is not available or variables are missing
    # This might happen if the user only provided a partial context for the change.
    # For now, I'll define them as placeholders if not found.
    MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
    MLFLOW_EXPERIMENT_NAME = "EduPath-MS"
    if not MLFLOW_AVAILABLE:
        print("⚠️  Could not import MLFLOW_TRACKING_URI or MLFLOW_EXPERIMENT_NAME from src.config. Using defaults or environment variables.")


def init_mlflow():
    """
    Initialise MLflow avec l'URI de tracking et le nom de l'expérience.
    Retourne True si MLflow est disponible, False sinon.
    """
    if not MLFLOW_AVAILABLE:
        print("📊 MLflow tracking disabled (module not installed)")
        return False
    
    try:
        # Configurer l'URI de tracking
        mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
        
        # Créer ou obtenir l'expérience
        experiment = mlflow.get_experiment_by_name(MLFLOW_EXPERIMENT_NAME)
        if experiment is None:
            mlflow.create_experiment(MLFLOW_EXPERIMENT_NAME)
        
        mlflow.set_experiment(MLFLOW_EXPERIMENT_NAME)
        
        print(f"✅ MLflow initialisé:")
        print(f"  - Tracking URI: {MLFLOW_TRACKING_URI}")
        print(f"  - Expérience: {MLFLOW_EXPERIMENT_NAME}")
        
        return True
    except Exception as e:
        print(f"⚠️  MLflow initialization failed: {e}")
        print("   Continuing without experiment tracking")
        return False


@contextmanager
def MLflowRun(run_name=None):
    """
    Context manager pour une run MLflow.
    Si MLflow n'est pas disponible, ne fait rien.
    
    Usage:
        with MLflowRun("my_experiment"):
            # votre code ML
            log_params({"param1": value})
            log_metrics({"accuracy": 0.95})
    """
    if not MLFLOW_AVAILABLE:
        print(f"📊 MLflowRun '{run_name}' skipped (MLflow not available)")
        yield None # Yield None to allow 'with' statement to proceed without a run object
        return

    try:
        with mlflow.start_run(run_name=run_name) as run:
            yield run
    except Exception as e:
        print(f"⚠️  MLflow run '{run_name}' failed: {e}")
        yield None # Yield None if run fails to start


def log_params(params):
    """
    Log les paramètres d'un modèle.
    
    Args:
        params: Dict des paramètres
    """
    if not MLFLOW_AVAILABLE:
        return
    
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
    if not MLFLOW_AVAILABLE:
        return
    
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
    if not MLFLOW_AVAILABLE:
        print(f"📊 Model logging skipped (MLflow not available)")
        return False
    
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
