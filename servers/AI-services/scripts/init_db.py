"""
Script d'initialisation de la base de données PostgreSQL.
Crée les tables nécessaires pour EduPath-MS.
"""

import sys
import os

# Ajouter le dossier parent au path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.database import init_db, create_tables, close_db


def main():
    """
    Initialise la base de données PostgreSQL.
    """
    print("="*70)
    print("INITIALISATION DE LA BASE DE DONNÉES PostgreSQL")
    print("="*70)
    
    print("\n📊 Connexion à PostgreSQL...")
    if not init_db():
        print("\n❌ Échec de connexion à PostgreSQL")
        print("\nVérifiez que:")
        print("  1. PostgreSQL est installé et démarré")
        print("  2. Le fichier .env contient DATABASE_URL correct")
        print("  3. L'utilisateur et la base de données existent")
        print("\nCommandes PostgreSQL pour créer l'utilisateur et la base:")
        print("  CREATE USER edupath_user WITH PASSWORD 'edupath_password';")
        print("  CREATE DATABASE edupath_db OWNER edupath_user;")
        return False
    
    print("\n📋 Création des tables...")
    if not create_tables():
        print("\n❌ Échec de création des tables")
        return False
    
    print("\n✅ Base de données initialisée avec succès!")
    print("\nTables créées:")
    print("  - cleaned_data: Données nettoyées")
    print("  - student_profiles: Profils étudiants")
    print("  - predictions: Historique prédictions")
    print("  - recommendations: Recommandations")
    
    close_db()
    
    print("\n" + "="*70)
    print("✅ INITIALISATION TERMINÉE")
    print("="*70)
    
    return True


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
