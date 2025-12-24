"""
Point d'entrée principal pour le pipeline EduPath-MS.
Exécutez ce fichier pour lancer l'analyse complète.
"""

import sys
import os

# Ajouter le dossier src au path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.pipeline import main

if __name__ == "__main__":
    print("🚀 Démarrage du pipeline EduPath-MS...")
    print("="*70)
    main()
