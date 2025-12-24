
"""
DAG Airflow pour orchestrer le pipeline EduPath-MS.
Exécute les 4 microservices en séquence.
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
import sys
import os

# Ajouter le dossier du projet au path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, PROJECT_ROOT)

# Importer les composants
from src.pipeline import PrepaData, StudentProfiler, PathPredictor
from src import config
import pandas as pd


# Fonctions pour chaque tâche
def task_load_data(**context):
    """Charge les données brutes."""
    print("📂 Chargement des données...")
    
    df1 = pd.read_csv(config.DATASET_1)
    df2 = pd.read_csv(config.DATASET_2)
    df_combined = pd.concat([df1, df2], ignore_index=True)
    
    # Sauvegarder pour les tâches suivantes
    context['ti'].xcom_push(key='data_shape', value=df_combined.shape)
    
    # Sauvegarder temporairement
    temp_file = os.path.join(config.PROCESSED_DATA_DIR, 'temp_raw_data.csv')
    df_combined.to_csv(temp_file, index=False)
    
    print(f"✅ Données chargées: {df_combined.shape}")
    return temp_file


def task_prepa_data(**context):
    """Exécute PrepaData (Composant 1)."""
    print("🔧 Exécution PrepaData...")
    
    # Charger depuis le fichier temporaire
    temp_file = context['ti'].xcom_pull(task_ids='load_data')
    df = pd.read_csv(temp_file)
    
    # Exécuter PrepaData
    preparer = PrepaData(df)
    df_clean = preparer.run_all(threshold=config.DEFAULT_FAIL_THRESHOLD)
    
    # Sauvegarder
    from src.database import save_data
    save_data(df_clean, 'cleaned_data', config.CLEANED_DATA)
    
    context['ti'].xcom_push(key='cleaned_records', value=len(df_clean))
    
    print(f"✅ PrepaData terminé: {len(df_clean)} enregistrements")


def task_student_profiler(**context):
    """Exécute StudentProfiler (Composant 2)."""
    print("👥 Exécution StudentProfiler...")
    
    # Charger les données nettoyées
    from src.database import load_data
    df_clean = load_data('cleaned_data', config.CLEANED_DATA)
    
    # Exécuter StudentProfiler
    profiler = StudentProfiler(df_clean)
    student_profiles = profiler.run_all(n_clusters=config.DEFAULT_N_CLUSTERS)
    
    # Sauvegarder
    from src.database import save_data
    save_data(student_profiles, 'student_profiles', config.STUDENT_PROFILES)
    
    context['ti'].xcom_push(key='students_profiled', value=len(student_profiles))
    
    print(f"✅ StudentProfiler terminé: {len(student_profiles)} profils")


def task_path_predictor(**context):
    """Exécute PathPredictor (Composant 3) avec MLflow."""
    print("🎯 Exécution PathPredictor...")
    
    # Charger les données
    from src.database import load_data
    df_clean = load_data('cleaned_data', config.CLEANED_DATA)
    
    # Initialiser MLflow
    from src.mlflow_config import init_mlflow, MLflowRun
    mlflow_available = init_mlflow()
    
    # Exécuter PathPredictor
    predictor = PathPredictor(df_clean)
    
    if mlflow_available:
        # Avec MLflow tracking
        with MLflowRun("path_predictor_airflow"):
            model = predictor.run_all()
            
            # Logger le modèle
            from src.mlflow_config import log_model
            log_model(model, "xgboost_model")
    else:
        # Sans MLflow
        model = predictor.run_all()
    
    # Sauvegarder le modèle
    import pickle
    with open(config.XGBOOST_MODEL, 'wb') as f:
        pickle.dump(model, f)
    
    print(f"✅ PathPredictor terminé")


def task_reco_builder(**context):
    """Exécute RecoBuilder (Composant 4) si OpenAI configuré."""
    print("🎓 Exécution RecoBuilder...")
    
    try:
        from src.recobuilder import RecoBuilder
        from src.database import load_data
        
        # Charger les données
        df_clean = load_data('cleaned_data', config.CLEANED_DATA)
        df_profiles = load_data('student_profiles', config.STUDENT_PROFILES)
        
        # Exécuter RecoBuilder
        recommender = RecoBuilder()
        recommendations = recommender.run_all(
            resources_path=config.EDUCATIONAL_RESOURCES,
            df_clean=df_clean,
            df_profiles=df_profiles
        )
        
        # Sauvegarder
        from src.database import save_data
        df_reco = recommender.save_recommendations(recommendations, config.RECOMMENDATIONS_OUTPUT)
        save_data(df_reco, 'recommendations', config.RECOMMENDATIONS_OUTPUT)
        
        context['ti'].xcom_push(key='recommendations_generated', value=len(recommendations))
        
        print(f"✅ RecoBuilder terminé: {len(recommendations)} recommandations")
        
    except Exception as e:
        print(f"⚠️ RecoBuilder ignoré: {e}")
        print("   Vérifiez que OpenAI est configuré dans .env")


# Configuration du DAG
default_args = {
    'owner': 'edupath',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'edupath_ms_pipeline',
    default_args=default_args,
    description='Pipeline complet EduPath-MS - Learning Analytics',
    schedule_interval='@daily',  # Exécution quotidienne
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['edupath', 'ml', 'learning-analytics'],
)

# Définition des tâches
load_data_task = PythonOperator(
    task_id='load_data',
    python_callable=task_load_data,
    dag=dag,
)

prepa_data_task = PythonOperator(
    task_id='prepa_data',
    python_callable=task_prepa_data,
    dag=dag,
)

student_profiler_task = PythonOperator(
    task_id='student_profiler',
    python_callable=task_student_profiler,
    dag=dag,
)

path_predictor_task = PythonOperator(
    task_id='path_predictor',
    python_callable=task_path_predictor,
    dag=dag,
)

reco_builder_task = PythonOperator(
    task_id='reco_builder',
    python_callable=task_reco_builder,
    dag=dag,
)

# Définition des dépendances
load_data_task >> prepa_data_task >> student_profiler_task >> path_predictor_task >> reco_builder_task
