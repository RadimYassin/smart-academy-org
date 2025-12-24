"""
EXEMPLE D'UTILISATION RAPIDE du Pipeline EduPath-MS
=====================================================

Ce fichier montre comment utiliser chaque composant individuellement.
"""

import pandas as pd
from edupath_pipeline import PrepaData, StudentProfiler, PathPredictor

# ============================================================================
# EXEMPLE 1: Utiliser uniquement PrepaData
# ============================================================================

print("="*70)
print("EXEMPLE 1: Nettoyage des données uniquement")
print("="*70)

# Charger les données
df = pd.read_csv('1- one_clean.csv')

# Appliquer le nettoyage
preparer = PrepaData(df)
df_clean = preparer.run_all(threshold=10)

# Voir les premières lignes
print("\nAperçu des données nettoyées:")
print(df_clean[['ID', 'Subject', 'Subject_Encoded', 'Total', 'is_fail']].head(10))

# ============================================================================
# EXEMPLE 2: Utiliser uniquement StudentProfiler
# ============================================================================

print("\n" + "="*70)
print("EXEMPLE 2: Profiling des étudiants uniquement")
print("="*70)

profiler = StudentProfiler(df_clean)
student_profiles = profiler.run_all(n_clusters=5)  # 5 clusters au lieu de 4

# Voir les profils
print("\nProfils des étudiants:")
print(student_profiles.head(10))

# ============================================================================
# EXEMPLE 3: Utiliser uniquement PathPredictor
# ============================================================================

print("\n" + "="*70)
print("EXEMPLE 3: Prédiction uniquement")
print("="*70)

predictor = PathPredictor(df_clean)
model = predictor.run_all()

# Faire une prédiction sur un nouvel étudiant
# Exemple: étudiant avec Subject_Encoded=5, Semester=2, Practical=15, Theoretical=25, Total=40
import numpy as np
new_student = np.array([[5, 2, 15, 25, 40, 1, 1]])  # [Subject, Semester, Practical, Theoretical, Total, MajorYear, Major_Encoded]
prediction = model.predict(new_student)

print(f"\nPrédiction pour un nouvel étudiant: {'ÉCHEC' if prediction[0] == 1 else 'RÉUSSITE'}")
prediction_proba = model.predict_proba(new_student)
print(f"Probabilité d'échec: {prediction_proba[0][1]*100:.2f}%")

# ============================================================================
# EXEMPLE 4: Analyse d'un étudiant spécifique
# ============================================================================

print("\n" + "="*70)
print("EXEMPLE 4: Analyse d'un étudiant spécifique")
print("="*70)

# Choisir un étudiant
student_id = 191112

# Voir toutes ses notes
student_data = df_clean[df_clean['ID'] == student_id]
print(f"\nDonnées de l'étudiant {student_id}:")
print(student_data[['Subject', 'Semester', 'Practical', 'Theoretical', 'Total', 'Status', 'is_fail']])

# Voir son profil
if student_id in student_profiles['ID'].values:
    profile = student_profiles[student_profiles['ID'] == student_id].iloc[0]
    print(f"\nProfil de l'étudiant {student_id}:")
    print(f"  - Moyenne générale: {profile['Average_Grade']:.2f}")
    print(f"  - Taux d'échec: {profile['Failure_Rate']:.2f}%")
    print(f"  - Cluster: {profile['Cluster']}")
    print(f"  - Nombre d'absences: {profile['Absence_Count']}")

# ============================================================================
# EXEMPLE 5: Analyser les matières les plus difficiles
# ============================================================================

print("\n" + "="*70)
print("EXEMPLE 5: Matières les plus difficiles")
print("="*70)

# Taux d'échec par matière
failure_by_subject = df_clean.groupby('Subject').agg({
    'is_fail': ['sum', 'count', 'mean']
}).reset_index()

failure_by_subject.columns = ['Subject', 'Échecs', 'Total', 'Taux_Échec']
failure_by_subject['Taux_Échec'] = failure_by_subject['Taux_Échec'] * 100
failure_by_subject = failure_by_subject.sort_values('Taux_Échec', ascending=False)

print("\nTop 10 des matières avec le plus haut taux d'échec:")
print(failure_by_subject.head(10).to_string(index=False))

print("\n" + "="*70)
print("✅ Exemples terminés!")
print("="*70)
