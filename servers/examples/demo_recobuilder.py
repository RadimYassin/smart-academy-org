"""
Démonstration du microservice RecoBuilder
Ce script montre comment générer des recommandations personnalisées pour différents profils d'étudiants.
"""

import pandas as pd
import sys
from src import config
from src.recobuilder import RecoBuilder


def print_section(title):
    """Affiche un titre de section formaté."""
    print("\n" + "="*80)
    print(f"  {title}")
    print("="*80 + "\n")


def display_profile(profile):
    """Affiche un profil étudiant de manière formatée."""
    print(f"🆔 Étudiant: {profile['student_id']}")
    print(f"{profile['risk_emoji']} Niveau de risque: {profile['risk_level']}")
    print(f"📊 Note moyenne: {profile['avg_score']:.1f}/100")
    print(f"❌ Taux d'échec: {profile['failure_rate']*100:.0f}%")
    print(f"📚 Total cours: {profile['total_courses']}")
    
    if profile['cluster'] is not None:
        print(f"👥 Cluster: {profile['cluster']}")
    
    print(f"\n⚠️ Matières en difficulté ({len(profile['weak_subjects'])}):")
    for subject in profile['weak_subjects'][:3]:
        print(f"  - {subject['Subject']}: {subject['Failure_Rate']*100:.0f}% échec (moyenne: {subject['Average_Score']:.1f})")
    
    if len(profile['strong_subjects']) > 0:
        print(f"\n✅ Points forts ({len(profile['strong_subjects'])}):")
        for subject in profile['strong_subjects'][:3]:
            print(f"  - {subject['Subject']}: {subject['Failure_Rate']*100:.0f}% échec (moyenne: {subject['Average_Score']:.1f})")


def display_recommendations(reco):
    """Affiche les recommandations de manière formatée."""
    print(f"\n🎯 RECOMMANDATIONS pour l'étudiant {reco['student_id']}")
    print(f"Niveau de risque: {reco['risk_emoji']} {reco['risk_level']}\n")
    
    for i, subject_reco in enumerate(reco['recommendations'], 1):
        print(f"\n{'─'*80}")
        print(f"📖 Matière {i}: {subject_reco['subject']}")
        print(f"   Taux d'échec actuel: {subject_reco['failure_rate']:.0f}%")
        
        print(f"\n💡 Ressources recommandées:")
        for j, resource in enumerate(subject_reco['resources'], 1):
            print(f"   {j}. [{resource['type']}] {resource['title']}")
            print(f"      {resource['description'][:100]}...")
            print(f"      🔗 {resource['url']}")
        
        print(f"\n📋 PLAN D'ACTION PERSONNALISÉ:")
        print(f"{subject_reco['personalized_plan']}")
    
    if reco['needs_tutoring']:
        tut = reco['tutoring_recommendation']
        print(f"\n{'─'*80}")
        print(f"👨‍🏫 RECOMMANDATION DE TUTORAT")
        print(f"   Urgence: {tut['urgency']}")
        print(f"   Type: {tut['type']}")
        print(f"   Fréquence: {tut['sessions_per_week']} séances/semaine pendant {tut['duration_weeks']} semaines")
        print(f"   Description: {tut['description']}")


def demo_scenario_1_brilliant_student():
    """Scénario 1: Étudiant brillant mais avec quelques difficultés."""
    print_section("SCÉNARIO 1: Étudiant Brillant avec Difficultés Ponctuelles")
    
    print("📝 Profil: Amir - Excellent étudiant qui a quelques difficultés en Chimie")
    print("   Note moyenne globale: 85/100")
    print("   Seulement 1 matière problématique\n")
    
    # Charger les données
    df_clean = pd.read_csv(config.CLEANED_DATA)
    
    try:
        df_profiles = pd.read_csv(config.STUDENT_PROFILES)
    except:
        df_profiles = None
    
    # Trouver un étudiant avec profil similaire (note élevée mais quelques échecs)
    student_stats = df_clean.groupby('ID').agg({
        'Total': 'mean',
        'is_fail': 'mean'
    }).reset_index()
    
    # Brillant = moyenne > 70, échec < 30%
    brilliant = student_stats[(student_stats['Total'] > 70) & (student_stats['is_fail'] < 0.3)]
    
    if len(brilliant) > 0:
        student_id = brilliant.iloc[0]['ID']
        
        # Initialiser RecoBuilder
        recommender = RecoBuilder()
        recommender.load_resources(config.EDUCATIONAL_RESOURCES)
        recommender.build_faiss_index()
        
        # Analyser et recommander
        profile = recommender.analyze_student_profile(student_id, df_clean, df_profiles)
        display_profile(profile)
        
        if len(profile['weak_subjects']) > 0:
            reco = recommender.generate_recommendations(profile)
            display_recommendations(reco)
        else:
            print("\n🎉 Excellentes performances! Aucune recommandation spécifique nécessaire.")
            print("💡 Conseil: Continuer sur cette lancée et aider les camarades en difficulté.")
    else:
        print("⚠️ Aucun étudiant correspondant à ce profil trouvé dans les données.")


def demo_scenario_2_struggling_student():
    """Scénario 2: Étudiant en grande difficulté."""
    print_section("SCÉNARIO 2: Étudiant en Grande Difficulté")
    
    print("📝 Profil: Sarah - En difficulté dans plusieurs matières")
    print("   Note moyenne globale: 35/100")
    print("   Taux d'échec élevé\n")
    
    # Charger les données
    df_clean = pd.read_csv(config.CLEANED_DATA)
    
    try:
        df_profiles = pd.read_csv(config.STUDENT_PROFILES)
    except:
        df_profiles = None
    
    # Trouver un étudiant en difficulté (moyenne < 50, échec > 60%)
    student_stats = df_clean.groupby('ID').agg({
        'Total': 'mean',
        'is_fail': 'mean'
    }).reset_index()
    
    struggling = student_stats[(student_stats['Total'] < 50) & (student_stats['is_fail'] > 0.6)]
    
    if len(struggling) > 0:
        student_id = struggling.iloc[0]['ID']
        
        # Initialiser RecoBuilder
        recommender = RecoBuilder()
        recommender.load_resources(config.EDUCATIONAL_RESOURCES)
        recommender.build_faiss_index()
        
        # Analyser et recommander
        profile = recommender.analyze_student_profile(student_id, df_clean, df_profiles)
        display_profile(profile)
        
        reco = recommender.generate_recommendations(profile)
        display_recommendations(reco)
    else:
        print("⚠️ Aucun étudiant correspondant à ce profil trouvé dans les données.")


def demo_scenario_3_moderate_risk():
    """Scénario 3: Étudiant à risque modéré."""
    print_section("SCÉNARIO 3: Étudiant à Risque Modéré")
    
    print("📝 Profil: Karim - Performance moyenne avec quelques matières difficiles")
    print("   Note moyenne globale: 55/100")
    print("   Taux d'échec modéré\n")
    
    # Charger les données
    df_clean = pd.read_csv(config.CLEANED_DATA)
    
    try:
        df_profiles = pd.read_csv(config.STUDENT_PROFILES)
    except:
        df_profiles = None
    
    # Trouver un étudiant à risque modéré (moyenne 50-65, échec 30-60%)
    student_stats = df_clean.groupby('ID').agg({
        'Total': 'mean',
        'is_fail': 'mean'
    }).reset_index()
    
    moderate = student_stats[
        (student_stats['Total'] >= 50) & (student_stats['Total'] < 65) &
        (student_stats['is_fail'] > 0.3) & (student_stats['is_fail'] < 0.6)
    ]
    
    if len(moderate) > 0:
        student_id = moderate.iloc[0]['ID']
        
        # Initialiser RecoBuilder
        recommender = RecoBuilder()
        recommender.load_resources(config.EDUCATIONAL_RESOURCES)
        recommender.build_faiss_index()
        
        # Analyser et recommander
        profile = recommender.analyze_student_profile(student_id, df_clean, df_profiles)
        display_profile(profile)
        
        reco = recommender.generate_recommendations(profile)
        display_recommendations(reco)
    else:
        print("⚠️ Aucun étudiant correspondant à ce profil trouvé dans les données.")


def demo_batch_recommendations():
    """Génère des recommandations en batch pour les étudiants à risque."""
    print_section("GÉNÉRATION BATCH: Top 10 Étudiants à Risque")
    
    print("🔄 Génération de recommandations pour les 10 étudiants à plus haut risque...\n")
    
    # Charger les données
    df_clean = pd.read_csv(config.CLEANED_DATA)
    
    try:
        df_profiles = pd.read_csv(config.STUDENT_PROFILES)
    except:
        df_profiles = None
    
    # Identifier les 10 plus à risque
    student_stats = df_clean.groupby('ID').agg({
        'Total': 'mean',
        'is_fail': 'mean'
    }).reset_index()
    
    top_risk = student_stats.nlargest(10, 'is_fail')
    student_ids = top_risk['ID'].tolist()
    
    # Initialiser RecoBuilder
    recommender = RecoBuilder()
    
    # Générer les recommandations
    recommendations = recommender.run_all(
        resources_path=config.EDUCATIONAL_RESOURCES,
        df_clean=df_clean,
        df_profiles=df_profiles,
        sample_students=student_ids
    )
    
    # Sauvegarder
    df_reco = recommender.save_recommendations(recommendations, config.RECOMMENDATIONS_OUTPUT)
    
    print(f"\n📊 RÉSUMÉ:")
    print(f"   Étudiants traités: {len(recommendations)}")
    print(f"   Recommandations générées: {len(df_reco)}")
    print(f"   Fichier créé: {config.RECOMMENDATIONS_OUTPUT}")
    
    # Afficher quelques statistiques
    risk_counts = df_reco.groupby('risk_level').size()
    print(f"\n   Répartition par niveau de risque:")
    for risk, count in risk_counts.items():
        print(f"     {risk}: {count} recommandations")


def main():
    """Menu principal de démo."""
    print("\n" + "="*80)
    print("  🎓 DÉMONSTRATION RecoBuilder - Recommandations Pédagogiques")
    print("="*80)
    
    print("\nChoisissez un scénario de démonstration:")
    print("  1. Étudiant brillant avec difficultés ponctuelles")
    print("  2. Étudiant en grande difficulté")
    print("  3. Étudiant à risque modéré")
    print("  4. Génération batch (Top 10 à risque)")
    print("  5. Tous les scénarios")
    print("  0. Quitter")
    
    choice = input("\nVotre choix (0-5): ").strip()
    
    if choice == "1":
        demo_scenario_1_brilliant_student()
    elif choice == "2":
        demo_scenario_2_struggling_student()
    elif choice == "3":
        demo_scenario_3_moderate_risk()
    elif choice == "4":
        demo_batch_recommendations()
    elif choice == "5":
        demo_scenario_1_brilliant_student()
        demo_scenario_2_struggling_student()
        demo_scenario_3_moderate_risk()
        demo_batch_recommendations()
    elif choice == "0":
        print("\n👋 Au revoir!")
        return
    else:
        print("\n❌ Choix invalide!")
        return
    
    print("\n" + "="*80)
    print("  ✅ DÉMONSTRATION TERMINÉE")
    print("="*80)
    print("\nPour utiliser RecoBuilder dans votre pipeline:")
    print("  1. Assurez-vous d'avoir votre clé OpenAI dans .env")
    print("  2. Importez: from src.recobuilder import RecoBuilder")
    print("  3. Utilisez run_all() pour générer les recommandations")
    print("\n")


if __name__ == "__main__":
    main()
