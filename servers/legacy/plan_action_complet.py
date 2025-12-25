"""
GUIDE PRATIQUE: Comment utiliser le modele pour atteindre vos 4 objectifs
==========================================================================

Ce script montre CONCRETEMENT comment:
1. PREDIRE les echecs AVANT qu'ils arrivent
2. IDENTIFIER les etudiants qui ont besoin d'aide
3. OPTIMISER l'allocation des ressources pedagogiques
4. AMELIORER le taux de reussite global
"""

import pickle
import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder

# ============================================================================
# CHARGER LE MODELE ET LES DONNEES
# ============================================================================
print("="*80)
print("CHARGEMENT DU MODELE ET DES DONNEES")
print("="*80)

# Charger le modele entraine
with open('outputs/models/xgboost_model.pkl', 'rb') as f:
    model = pickle.load(f)
print(">> Modele charge!")

# Charger les donnees nettoyees
df = pd.read_csv('data/processed/data_cleaned.csv')

# Encoder Major pour predictions
le_major = LabelEncoder()
df['Major_Encoded'] = le_major.fit_transform(df['Major'].fillna('Unknown'))

print(f">> Donnees chargees: {len(df)} enregistrements")
print(f">> Etudiants uniques: {df['ID'].nunique()}")

# ============================================================================
# OBJECTIF 1: PREDIRE LES ECHECS AVANT QU'ILS ARRIVENT
# ============================================================================
print("\n" + "="*80)
print("OBJECTIF 1: PREDIRE LES ECHECS AVANT QU'ILS ARRIVENT")
print("="*80)

print("""
PRINCIPE: Analyser les etudiants au DEBUT ou MI-SEMESTRE avec leurs notes
          actuelles pour predire s'ils vont echouer a la FIN.
          
METHODE:
  1. Collecter les notes actuelles (même partielles)
  2. Faire une prediction avec le modele
  3. Si probabilite d'echec > 70%, ALERTER
""")

# Exemple: Prendre les etudiants du semestre 1 et predire leur reussite
print("\n>> EXEMPLE: Analyse des etudiants du Semestre 1")

# Filtrer semestre 1
semestre_1 = df[df['Semester'] == 1].copy()

# Preparer les features
feature_cols = ['Subject_Encoded', 'Semester', 'Practical', 'Theoretical', 'Total', 'MajorYear', 'Major_Encoded']
X = semestre_1[feature_cols].fillna(0)

# FAIRE LES PREDICTIONS
predictions = model.predict(X)
probabilities = model.predict_proba(X)

# Ajouter les resultats au dataframe
semestre_1['prediction'] = predictions
semestre_1['proba_echec'] = probabilities[:, 1]
semestre_1['proba_reussite'] = probabilities[:, 0]

# Identifier les etudiants a HAUT RISQUE
etudiants_a_risque = semestre_1[semestre_1['proba_echec'] > 0.7]

print(f"\nRESULTATS:")
print(f"  - Total etudiants analyses: {len(semestre_1)}")
print(f"  - Etudiants a HAUT RISQUE (>70%): {len(etudiants_a_risque)}")
print(f"  - Taux de risque: {len(etudiants_a_risque)/len(semestre_1)*100:.1f}%")

print(f"\nTop 5 etudiants les plus a risque:")
top_risque = etudiants_a_risque.nlargest(5, 'proba_echec')[['ID', 'Subject', 'Total', 'proba_echec']]
for idx, row in top_risque.iterrows():
    print(f"  - ID {row['ID']}: {row['Subject']} (Note: {row['Total']:.0f}) - Risque: {row['proba_echec']*100:.0f}%")

# SAUVEGARDER LA LISTE DES ETUDIANTS A RISQUE
etudiants_a_risque[['ID', 'Subject', 'Total', 'proba_echec']].to_csv(
    'outputs/etudiants_a_risque.csv', index=False
)
print(f"\n>> Liste sauvegardee dans: outputs/etudiants_a_risque.csv")

# ============================================================================
# OBJECTIF 2: IDENTIFIER LES ETUDIANTS QUI ONT BESOIN D'AIDE
# ============================================================================
print("\n" + "="*80)
print("OBJECTIF 2: IDENTIFIER LES ETUDIANTS QUI ONT BESOIN D'AIDE")
print("="*80)

print("""
PRINCIPE: Classifier les etudiants par niveau de risque pour prioriser
          les interventions.
          
CATEGORIES:
  - ROUGE (>80%): Urgence elevee - Intervention immediate
  - ORANGE (60-80%): Risque modere - Suivi renforce
  - JAUNE (40-60%): Attention - Surveillance
  - VERT (<40%): Bon - Suivi normal
""")

# Analyser TOUS les etudiants
X_all = df[feature_cols].fillna(0)
predictions_all = model.predict(X_all)
probabilities_all = model.predict_proba(X_all)

df['prediction'] = predictions_all
df['proba_echec'] = probabilities_all[:, 1]

# Classifier par niveau de risque
def categoriser_risque(proba):
    if proba > 0.8:
        return 'ROUGE_URGENCE'
    elif proba > 0.6:
        return 'ORANGE_MODERE'
    elif proba > 0.4:
        return 'JAUNE_ATTENTION'
    else:
        return 'VERT_BON'

df['categorie_risque'] = df['proba_echec'].apply(categoriser_risque)

# Statistiques par categorie
print("\nREPARTITION DES ETUDIANTS PAR CATEGORIE DE RISQUE:")
repartition = df['categorie_risque'].value_counts()
for cat in ['ROUGE_URGENCE', 'ORANGE_MODERE', 'JAUNE_ATTENTION', 'VERT_BON']:
    count = repartition.get(cat, 0)
    pct = count / len(df) * 100
    print(f"  - {cat:20s}: {count:6d} etudiants ({pct:5.1f}%)")

# Grouper par etudiant pour avoir une vue globale
etudiants_risque = df.groupby('ID').agg({
    'proba_echec': 'mean',  # Moyenne du risque sur tous les cours
    'Subject': 'count'       # Nombre de cours
}).reset_index()
etudiants_risque.columns = ['ID', 'risque_moyen', 'nb_cours']
etudiants_risque['categorie'] = etudiants_risque['risque_moyen'].apply(categoriser_risque)

# Identifier les etudiants qui ont VRAIMENT besoin d'aide
besoin_aide = etudiants_risque[etudiants_risque['risque_moyen'] > 0.6]

print(f"\nETUDIANTS NECESSITANT UNE INTERVENTION:")
print(f"  - Total: {len(besoin_aide)} etudiants")
print(f"  - URGENCE (>80%): {len(besoin_aide[besoin_aide['risque_moyen'] > 0.8])}")
print(f"  - MODERE (60-80%): {len(besoin_aide[besoin_aide['risque_moyen'] <= 0.8])}")

# Sauvegarder la liste
besoin_aide.to_csv('outputs/etudiants_besoin_aide.csv', index=False)
print(f"\n>> Liste sauvegardee dans: outputs/etudiants_besoin_aide.csv")

# ============================================================================
# OBJECTIF 3: OPTIMISER L'ALLOCATION DES RESSOURCES PEDAGOGIQUES
# ============================================================================
print("\n" + "="*80)
print("OBJECTIF 3: OPTIMISER L'ALLOCATION DES RESSOURCES PEDAGOGIQUES")
print("="*80)

print("""
PRINCIPE: Analyser les besoins par filiere et matiere pour allouer
          les tuteurs et budgets de maniere optimale.
          
METHODE:
  1. Identifier les matieres avec le plus d'echecs prevus
  2. Calculer le nombre de tuteurs necessaires
  3. Budgetiser selon les besoins reels
""")

# Analyser par MATIERE
print("\n>> ANALYSE PAR MATIERE:")
risque_par_matiere = df.groupby('Subject').agg({
    'proba_echec': ['mean', 'count'],
    'ID': 'nunique'
}).round(2)
risque_par_matiere.columns = ['risque_moyen', 'nb_enregistrements', 'nb_etudiants']
risque_par_matiere = risque_par_matiere.sort_values('risque_moyen', ascending=False)

print("\nTop 10 matieres les plus problematiques:")
print(risque_par_matiere.head(10).to_string())

# Estimer les besoins en TUTEURS
# Hypothese: 1 tuteur peut suivre 10 etudiants a risque
matieres_problematiques = risque_par_matiere[risque_par_matiere['risque_moyen'] > 0.5]
matieres_problematiques['etudiants_a_risque'] = (
    matieres_problematiques['nb_etudiants'] * matieres_problematiques['risque_moyen']
).round(0).astype(int)
matieres_problematiques['tuteurs_necessaires'] = (
    matieres_problematiques['etudiants_a_risque'] / 10
).round(1)

print(f"\n>> BESOINS EN TUTEURS PAR MATIERE:")
print(matieres_problematiques[['etudiants_a_risque', 'tuteurs_necessaires']].head(10).to_string())

total_tuteurs = matieres_problematiques['tuteurs_necessaires'].sum()
print(f"\n>> TOTAL TUTEURS NECESSAIRES: {total_tuteurs:.0f}")

# Analyser par FILIERE
print("\n>> ANALYSE PAR FILIERE:")
risque_par_filiere = df.groupby('Major').agg({
    'proba_echec': 'mean',
    'ID': 'nunique'
}).round(2)
risque_par_filiere.columns = ['risque_moyen', 'nb_etudiants']
risque_par_filiere = risque_par_filiere.sort_values('risque_moyen', ascending=False)
print(risque_par_filiere.to_string())

# Sauvegarder le plan d'allocation
matieres_problematiques.to_csv('outputs/plan_allocation_ressources.csv')
print(f"\n>> Plan sauvegarde dans: outputs/plan_allocation_ressources.csv")

# ============================================================================
# OBJECTIF 4: AMELIORER LE TAUX DE REUSSITE GLOBAL
# ============================================================================
print("\n" + "="*80)
print("OBJECTIF 4: AMELIORER LE TAUX DE REUSSITE GLOBAL")
print("="*80)

print("""
PRINCIPE: Estimer l'impact potentiel des interventions sur le taux
          de reussite.
          
HYPOTHESES:
  - Sans intervention: Echec reel selon prediction
  - Avec tutorat leger (etudiants >60%): 30% de recuperation
  - Avec tutorat intensif (etudiants >80%): 50% de recuperation
""")

# Calculer le taux actuel
taux_echec_actuel = df['is_fail'].mean()
taux_reussite_actuel = 1 - taux_echec_actuel

print(f"\nSITUATION ACTUELLE:")
print(f"  - Taux de reussite: {taux_reussite_actuel*100:.1f}%")
print(f"  - Taux d'echec: {taux_echec_actuel*100:.1f}%")
print(f"  - Total etudiants: {df['ID'].nunique()}")

# Scenario SANS intervention
echecs_prevus = (df['proba_echec'] > 0.5).sum()
print(f"\nSCENARIO SANS INTERVENTION:")
print(f"  - Echecs prevus: {echecs_prevus}")
print(f"  - Taux d'echec prevu: {echecs_prevus/len(df)*100:.1f}%")

# Scenario AVEC intervention
# Groupe 1: Urgence (>80%) -> 50% recuperation
urgence = df[df['proba_echec'] > 0.8]
recuperes_urgence = len(urgence) * 0.5

# Groupe 2: Modere (60-80%) -> 30% recuperation
modere = df[(df['proba_echec'] > 0.6) & (df['proba_echec'] <= 0.8)]
recuperes_modere = len(modere) * 0.3

# Nouveaux echecs apres intervention
nouveaux_echecs = echecs_prevus - recuperes_urgence - recuperes_modere
nouveau_taux_reussite = 1 - (nouveaux_echecs / len(df))

print(f"\nSCENARIO AVEC INTERVENTION:")
print(f"  - Etudiants urgence (>80%): {len(urgence)}")
print(f"  - Recuperes urgence (50%): {recuperes_urgence:.0f}")
print(f"  - Etudiants moderes (60-80%): {len(modere)}")
print(f"  - Recuperes moderes (30%): {recuperes_modere:.0f}")
print(f"  - Total recuperes: {recuperes_urgence + recuperes_modere:.0f}")
print(f"  - Nouveaux echecs: {nouveaux_echecs:.0f}")
print(f"  - Nouveau taux de reussite: {nouveau_taux_reussite*100:.1f}%")

amelioration = (nouveau_taux_reussite - taux_reussite_actuel) * 100
print(f"\n>> AMELIORATION: +{amelioration:.1f} points de pourcentage")
print(f">> GAIN EN NOMBRE D'ETUDIANTS: +{(recuperes_urgence + recuperes_modere):.0f} reussites")

# ============================================================================
# PLAN D'ACTION COMPLET
# ============================================================================
print("\n" + "="*80)
print("PLAN D'ACTION COMPLET - RESUME")
print("="*80)

print(f"""
ETAPE 1: DETECTION (Semaine 3-4 du semestre)
  >> Executer: python run_pipeline.py
  >> Analyser: {len(besoin_aide)} etudiants identifies a risque
  >> Fichier: outputs/etudiants_besoin_aide.csv

ETAPE 2: INTERVENTION (Semaine 5-10)
  >> URGENCE ({len(urgence)} etudiants >80%):
     - Tutorat intensif 2-3h/semaine
     - Suivi hebdomadaire personnalise
     - Contact avec conseiller pedagogique
  
  >> MODERE ({len(modere)} etudiants 60-80%):
     - Seances de soutien 1h/semaine
     - Ressources en ligne supplementaires
     - Suivi bimensuel

ETAPE 3: ALLOCATION RESSOURCES
  >> Tuteurs necessaires: {total_tuteurs:.0f}
  >> Top 3 matieres prioritaires:
     1. {risque_par_matiere.index[0]}
     2. {risque_par_matiere.index[1]}
     3. {risque_par_matiere.index[2]}
  >> Fichier: outputs/plan_allocation_ressources.csv

ETAPE 4: SUIVI & VALIDATION (Semaine 11-15)
  >> Re-executer predictions mi-parcours
  >> Ajuster interventions selon evolution
  >> Mesurer taux de reussite final

RESULTATS ATTENDUS:
  >> Taux de reussite actuel: {taux_reussite_actuel*100:.1f}%
  >> Taux de reussite apres intervention: {nouveau_taux_reussite*100:.1f}%
  >> AMELIORATION: +{amelioration:.1f} points
  >> ETUDIANTS SAUVES: +{(recuperes_urgence + recuperes_modere):.0f}
""")

# ============================================================================
# FICHIERS GENERES
# ============================================================================
print("\n" + "="*80)
print("FICHIERS GENERES POUR ACTION")
print("="*80)

print("""
1. outputs/etudiants_a_risque.csv
   >> Liste des etudiants a haut risque (>70%)
   >> A envoyer aux conseillers pedagogiques
   
2. outputs/etudiants_besoin_aide.csv
   >> Vue par etudiant avec risque moyen
   >> Pour planifier les interventions
   
3. outputs/plan_allocation_ressources.csv
   >> Besoins en tuteurs par matiere
   >> Pour le budget et recrutement

COMMENT LES UTILISER:
  - Importez dans Excel/Google Sheets
  - Filtrez par categorie de risque
  - Assignez les tuteurs et conseillers
  - Suivez l'evolution hebdomadaire
""")

print("\n" + "="*80)
print("EXECUTION TERMINEE - TOUS LES OBJECTIFS COUVERTS!")
print("="*80)
