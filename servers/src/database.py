"""
Module de gestion de la base de données PostgreSQL pour EduPath-MS.
Fournit les connexions et fonctions helper pour interagir avec PostgreSQL.
"""

import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import pandas as pd
from datetime import datetime

# Charger les variables d'environnement
load_dotenv()

# Configuration
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://edupath_user:edupath_password@localhost:5432/edupath_db')
USE_DATABASE = os.getenv('USE_DATABASE', 'false').lower() == 'true'

# SQLAlchemy setup
Base = declarative_base()
engine = None
SessionLocal = None


def init_db():
    """
    Initialise la connexion à la base de données PostgreSQL.
    """
    global engine, SessionLocal
    
    try:
        engine = create_engine(DATABASE_URL, echo=False)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        print(f"✅ Connexion PostgreSQL établie: {DATABASE_URL.split('@')[1]}")
        return True
    except Exception as e:
        print(f"⚠️ Connexion PostgreSQL échouée: {e}")
        print(f"   Mode CSV sera utilisé à la place")
        return False


def create_tables():
    """
    Crée toutes les tables nécessaires dans PostgreSQL.
    """
    global engine
    
    if engine is None:
        if not init_db():
            return False
    
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Tables PostgreSQL créées")
        return True
    except Exception as e:
        print(f"❌ Erreur création tables: {e}")
        return False


def save_dataframe_to_db(df, table_name, if_exists='replace'):
    """
    Sauvegarde un DataFrame dans PostgreSQL.
    
    Args:
        df: DataFrame pandas à sauvegarder
        table_name: Nom de la table
        if_exists: 'replace', 'append', ou 'fail'
    
    Returns:
        bool: True si succès, False sinon
    """
    global engine
    
    if not USE_DATABASE:
        return False
    
    if engine is None:
        if not init_db():
            return False
    
    try:
        df.to_sql(table_name, engine, if_exists=if_exists, index=False)
        print(f"✅ Données sauvegardées dans PostgreSQL: {table_name} ({len(df)} lignes)")
        return True
    except Exception as e:
        print(f"❌ Erreur sauvegarde PostgreSQL: {e}")
        return False


def load_dataframe_from_db(table_name, query=None):
    """
    Charge un DataFrame depuis PostgreSQL.
    
    Args:
        table_name: Nom de la table
        query: Requête SQL optionnelle (si None, charge toute la table)
    
    Returns:
        DataFrame ou None si erreur
    """
    global engine
    
    if not USE_DATABASE:
        return None
    
    if engine is None:
        if not init_db():
            return None
    
    try:
        if query is None:
            query = f"SELECT * FROM {table_name}"
        
        df = pd.read_sql(query, engine)
        print(f"✅ Données chargées depuis PostgreSQL: {table_name} ({len(df)} lignes)")
        return df
    except Exception as e:
        print(f"❌ Erreur chargement PostgreSQL: {e}")
        return None


def get_session():
    """
    Retourne une session SQLAlchemy.
    """
    global SessionLocal
    
    if SessionLocal is None:
        if not init_db():
            return None
    
    return SessionLocal()


def close_db():
    """
    Ferme la connexion à la base de données.
    """
    global engine
    
    if engine is not None:
        engine.dispose()
        print("✅ Connexion PostgreSQL fermée")


# Fonctions helper pour compatibilité CSV/PostgreSQL
def save_data(df, table_name, csv_path):
    """
    Sauvegarde dans PostgreSQL OU CSV selon la configuration.
    
    Args:
        df: DataFrame à sauvegarder
        table_name: Nom de la table PostgreSQL
        csv_path: Chemin du fichier CSV (fallback)
    """
    if USE_DATABASE:
        success = save_dataframe_to_db(df, table_name)
        if success:
            return True
    
    # Fallback: CSV
    df.to_csv(csv_path, index=False)
    print(f"💾 Données sauvegardées en CSV: {csv_path}")
    return True


def load_data(table_name, csv_path):
    """
    Charge depuis PostgreSQL OU CSV selon la configuration.
    
    Args:
        table_name: Nom de la table PostgreSQL
        csv_path: Chemin du fichier CSV (fallback)
    
    Returns:
        DataFrame
    """
    if USE_DATABASE:
        df = load_dataframe_from_db(table_name)
        if df is not None:
            return df
    
    # Fallback: CSV
    df = pd.read_csv(csv_path)
    print(f"📂 Données chargées depuis CSV: {csv_path}")
    return df


# Modèles SQLAlchemy (optionnel, pour ORM)
class CleanedData(Base):
    """Table pour les données nettoyées."""
    __tablename__ = 'cleaned_data'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    student_id = Column(Integer)
    subject = Column(String)
    subject_encoded = Column(Integer)
    semester = Column(Integer)
    practical = Column(Float)
    theoretical = Column(Float)
    total = Column(Float)
    is_fail = Column(Integer)
    major = Column(String)
    major_year = Column(Integer)
    status = Column(String)


class StudentProfile(Base):
    """Table pour les profils étudiants."""
    __tablename__ = 'student_profiles'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    student_id = Column(Integer, unique=True)
    average_grade = Column(Float)
    total_failures = Column(Integer)
    total_courses = Column(Integer)
    avg_practical = Column(Float)
    avg_theoretical = Column(Float)
    failure_rate = Column(Float)
    absence_count = Column(Integer)
    cluster = Column(Integer)


class Prediction(Base):
    """Table pour l'historique des prédictions."""
    __tablename__ = 'predictions'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    student_id = Column(Integer)
    subject = Column(String)
    prediction = Column(Integer)
    probability_fail = Column(Float)
    probability_success = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow)


class Recommendation(Base):
    """Table pour les recommandations."""
    __tablename__ = 'recommendations'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    student_id = Column(Integer)
    risk_level = Column(String)
    subject = Column(String)
    failure_rate = Column(Float)
    resource_1 = Column(String)
    resource_2 = Column(String)
    resource_3 = Column(String)
    personalized_plan = Column(Text)
    needs_tutoring = Column(Boolean)
    created_at = Column(DateTime, default=datetime.utcnow)


# Test de connexion
if __name__ == "__main__":
    print("Test du module database...")
    
    if init_db():
        print("✅ Connexion réussie")
        
        if create_tables():
            print("✅ Tables créées")
        
        close_db()
    else:
        print("⚠️ Mode CSV utilisé (PostgreSQL non disponible)")
