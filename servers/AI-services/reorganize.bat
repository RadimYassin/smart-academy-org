@echo off
REM ========================================================================
REM Script de Restructuration du Projet EduPath-MS
REM ========================================================================

echo ========================================================================
echo RESTRUCTURATION DU PROJET EduPath-MS
echo ========================================================================
echo.

REM 1. Créer les dossiers nécessaires
echo [1/5] Création des dossiers...
if not exist examples mkdir examples
if not exist reports mkdir reports
if not exist legacy mkdir legacy
if not exist data\processed mkdir data\processed
if not exist outputs\figures mkdir outputs\figures
if not exist outputs\models mkdir outputs\models
echo     ✓ Dossiers créés

REM 2. Déplacer les exemples
echo.
echo [2/5] Organisation des exemples...
if exist demo_recobuilder.py move /Y demo_recobuilder.py examples\
if exist demo_model.py move /Y demo_model.py examples\
if exist demo_utilite.py move /Y demo_utilite.py examples\
if exist examples.py move /Y examples.py examples\
echo     ✓ Exemples organisés

REM 3. Déplacer les rapports
echo.
echo [3/5] Organisation des rapports...
if exist RAPPORT_PRESENTATION.md move /Y RAPPORT_PRESENTATION.md reports\
if exist PRESENTATION_PROF.md move /Y PRESENTATION_PROF.md reports\
if exist COMMENT_FAIRE_4_OBJECTIFS.txt move /Y COMMENT_FAIRE_4_OBJECTIFS.txt reports\
if exist UTILITE_MODELE.txt move /Y UTILITE_MODELE.txt reports\
if exist DEMO_RESULTATS.txt move /Y DEMO_RESULTATS.txt reports\
echo     ✓ Rapports organisés

REM 4. Déplacer les scripts
echo.
echo [4/5] Organisation des scripts...
if exist test_infrastructure.py move /Y test_infrastructure.py scripts\
if exist test_microservices.py move /Y test_microservices.py scripts\
echo     ✓ Scripts organisés

REM 5. Déplacer legacy
echo.
echo [5/5] Organisation des fichiers legacy...
if exist edupath_pipeline.py move /Y edupath_pipeline.py legacy\
if exist plan_action_complet.py move /Y plan_action_complet.py legacy\
if exist PROJECT_TREE.txt move /Y PROJECT_TREE.txt legacy\
if exist PROGRESSION_INSTALL.md move /Y PROGRESSION_INSTALL.md legacy\
if exist INSTALLATION_GUIDE.md move /Y INSTALLATION_GUIDE.md legacy\
if exist data_cleaned.csv move /Y data_cleaned.csv data\processed\
if exist elbow_method.png move /Y elbow_method.png outputs\figures\
echo     ✓ Legacy organisé

REM 6. Nettoyer cache Python
echo.
echo [6/5] Nettoyage des caches...
if exist __pycache__ rmdir /S /Q __pycache__
if exist src\__pycache__ rmdir /S /Q src\__pycache__
echo     ✓ Cache nettoyé

echo.
echo ========================================================================
echo ✓ RESTRUCTURATION TERMINÉE
echo ========================================================================
echo.
echo Nouvelle structure:
echo   ├── src/           (Code source)
echo   ├── data/          (Données)
echo   ├── outputs/       (Résultats)
echo   ├── examples/      (Démos)
echo   ├── reports/       (Rapports)
echo   ├── scripts/       (Utilitaires)
echo   ├── airflow/       (Orchestration)
echo   ├── docs/          (Documentation)
echo   └── legacy/        (Anciens fichiers)
echo.
echo ✓ Projet structuré et prêt!
echo.
pause
