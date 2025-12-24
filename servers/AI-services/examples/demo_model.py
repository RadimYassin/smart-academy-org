"""
DÉMONSTRATION DU MODÈLE XGBOOST - EduPath-MS
=============================================

Ce script montre comment le modèle fonctionne avec des exemples concrets.
"""

import pickle
import pandas as pd
import numpy as np
from src.config import *

print("="*70)
print("🎓 DÉMONSTRATION DU MODÈLE EDUPATH-MS")
print("="*70)

# ============================================================================
# 1. CHARGER LE MODÈLE ENTRAÎNÉ
# ============================================================================
print("\n📦 Chargement du modèle XGBoost entraîné...")
with open(XGBOOST_MODEL, 'rb') as f:
    model = pickle.load(f)
print("✓ Modèle chargé avec succès!")

# ============================================================================
# 2. CHARGER LES DONNÉES NETTOYÉES POUR RÉFÉRENCE
# ============================================================================
print("\n📂 Chargement des données pour référence...")
df = pd.read_csv(CLEANED_DATA)

# Encoder Major comme dans le pipeline
from sklearn.preprocessing import LabelEncoder
le_major = LabelEncoder()
df['Major_Encoded'] = le_major.fit_transform(df['Major'].fillna('Unknown'))

print(f"✓ {len(df)} enregistrements chargés")

# Afficher quelques statistiques
print(f"\n📊 Statistiques des données:")
print(f"  - Matières uniques: {df['Subject_Encoded'].nunique()}")
print(f"  - Filières: {df['Major'].nunique()}")
print(f"  - Taux d'échec global: {df['is_fail'].mean()*100:.2f}%")

# ============================================================================
# 3. EXEMPLES DE PRÉDICTION - CAS RÉELS
# ============================================================================
print("\n" + "="*70)
print("🔮 EXEMPLES DE PRÉDICTIONS")
print("="*70)

# Prendre quelques exemples réels du dataset
sample_students = df.sample(n=5, random_state=42)

print("\n📝 Features utilisées par le modèle:")
feature_names = ['Subject_Encoded', 'Semester', 'Practical', 'Theoretical', 'Total', 'MajorYear', 'Major_Encoded']
print(f"  {', '.join(feature_names)}")

print("\n" + "-"*70)
for idx, (i, student) in enumerate(sample_students.iterrows(), 1):
    # Préparer les features
    features = student[feature_names].values.reshape(1, -1)
    
    # Prédiction
    prediction = model.predict(features)[0]
    probability = model.predict_proba(features)[0]
    
    # Réalité
    actual = student['is_fail']
    
    # Afficher
    print(f"\n🎓 ÉTUDIANT {idx}:")
    print(f"  Matière: {student['Subject']}")
    print(f"  Semestre: {int(student['Semester'])}")
    print(f"  Note Pratique: {student['Practical']:.1f}")
    print(f"  Note Théorique: {student['Theoretical']:.1f}")
    print(f"  Total: {student['Total']:.1f}")
    print(f"  Filière: {student['Major']}")
    
    # Prédiction vs Réalité
    pred_label = "❌ ÉCHEC" if prediction == 1 else "✅ RÉUSSITE"
    actual_label = "❌ ÉCHEC" if actual == 1 else "✅ RÉUSSITE"
    correct = "✓ CORRECT" if prediction == actual else "✗ INCORRECT"
    
    print(f"\n  🔮 PRÉDICTION: {pred_label}")
    print(f"     Probabilité d'échec: {probability[1]*100:.2f}%")
    print(f"     Probabilité de réussite: {probability[0]*100:.2f}%")
    print(f"  📊 RÉALITÉ: {actual_label}")
    print(f"  {correct}")
    print("-"*70)

# ============================================================================
# 4. TESTER DIFFÉRENTS SCÉNARIOS
# ============================================================================
print("\n" + "="*70)
print("🧪 TESTS DE SCÉNARIOS HYPOTHÉTIQUES")
print("="*70)

# Encoder une filière pour le test (prenons la moyenne)
avg_major_encoded = df['Major_Encoded'].mean()

scenarios = [
    {
        'nom': "Étudiant Excellent",
        'features': [10, 2, 28, 65, 93, 1, avg_major_encoded],
        'description': "Notes élevées (Pratique: 28/30, Théorique: 65/70)"
    },
    {
        'nom': "Étudiant Moyen",
        'features': [15, 2, 15, 45, 60, 1, avg_major_encoded],
        'description': "Notes moyennes (Pratique: 15/30, Théorique: 45/70)"
    },
    {
        'nom': "Étudiant en Difficulté",
        'features': [20, 2, 8, 20, 28, 1, avg_major_encoded],
        'description': "Notes faibles (Pratique: 8/30, Théorique: 20/70)"
    },
    {
        'nom': "Étudiant Absent",
        'features': [5, 1, 0, 0, 0, 1, avg_major_encoded],
        'description': "Absence totale (toutes les notes à 0)"
    }
]

for scenario in scenarios:
    features = np.array(scenario['features']).reshape(1, -1)
    prediction = model.predict(features)[0]
    probability = model.predict_proba(features)[0]
    
    pred_label = "❌ ÉCHEC" if prediction == 1 else "✅ RÉUSSITE"
    
    print(f"\n📚 Scénario: {scenario['nom']}")
    print(f"   {scenario['description']}")
    print(f"   🔮 Prédiction: {pred_label}")
    print(f"   📊 Probabilité d'échec: {probability[1]*100:.2f}%")
    print(f"   📊 Probabilité de réussite: {probability[0]*100:.2f}%")

# ============================================================================
# 5. IMPORTANCE DES FEATURES
# ============================================================================
print("\n" + "="*70)
print("📊 IMPORTANCE DES FACTEURS DE PRÉDICTION")
print("="*70)

feature_importance = model.feature_importances_
importance_df = pd.DataFrame({
    'Feature': feature_names,
    'Importance': feature_importance
}).sort_values('Importance', ascending=False)

print("\nFacteurs classés par importance (du plus au moins important):")
for idx, row in importance_df.iterrows():
    bar_length = int(row['Importance'] * 50)
    bar = '█' * bar_length
    print(f"  {row['Feature']:20s} | {bar} {row['Importance']:.4f}")

# ============================================================================
# 6. STATISTIQUES DU MODÈLE
# ============================================================================
print("\n" + "="*70)
print("📈 STATISTIQUES DU MODÈLE")
print("="*70)

# Faire des prédictions sur l'ensemble du dataset
all_features = df[feature_names].fillna(0)
all_predictions = model.predict(all_features)
all_actuals = df['is_fail']

# Calculer l'accuracy
accuracy = (all_predictions == all_actuals).mean()
correct_failures = ((all_predictions == 1) & (all_actuals == 1)).sum()
total_failures = (all_actuals == 1).sum()
recall_failure = correct_failures / total_failures if total_failures > 0 else 0

print(f"\n🎯 Performance globale:")
print(f"  - Accuracy: {accuracy*100:.2f}%")
print(f"  - Échecs correctement détectés: {correct_failures}/{total_failures} ({recall_failure*100:.2f}%)")
print(f"  - Total de prédictions: {len(all_predictions):,}")

# ============================================================================
# 7. CONCLUSION
# ============================================================================
print("\n" + "="*70)
print("✅ DÉMONSTRATION TERMINÉE")
print("="*70)
print("\n💡 Points clés:")
print("  1. Le modèle prend en compte 7 features (matière, notes, semestre, etc.)")
print("  2. Il prédit ÉCHEC ou RÉUSSITE avec une probabilité associée")
print(f"  3. Accuracy globale: {accuracy*100:.2f}%")
print("  4. Le facteur le plus important est probablement la note 'Total'")
print("\n🚀 Le modèle est prêt à être utilisé en production!")
print("="*70 + "\n")
