"""
RecoBuilder - Composant 4: Moteur de Recommandations Pédagogiques
Utilise OpenAI GPT + Embeddings + FAISS pour générer des recommandations personnalisées.

Auteur: EduPath-MS Pipeline
Date: 2025-12-21
"""

import os
import json
import numpy as np
import pandas as pd
from typing import List, Dict, Any
from dotenv import load_dotenv
import warnings
warnings.filterwarnings('ignore')

# Importer OpenAI et FAISS
try:
    from openai import OpenAI
    import faiss
except ImportError:
    print("⚠️ ATTENTION: Installez les dépendances avec: pip install openai faiss-cpu python-dotenv")
    raise

# Charger les variables d'environnement
load_dotenv()


class RecoBuilder:
    """
    Composant 4: Moteur de Recommandations Pédagogiques Personnalisées
    
    Fonctionnalités:
    - Chargement et indexation de ressources pédagogiques
    - Génération d'embeddings avec OpenAI
    - Recherche sémantique avec FAISS
    - Recommandations intelligentes avec GPT-4
    """
    
    def __init__(self, api_key=None):
        """
        Initialise le RecoBuilder avec l'API OpenAI.
        
        Args:
            api_key: Clé API OpenAI (optionnel, peut être dans .env)
        """
        # Charger la clé API
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError(
                "❌ Clé API OpenAI manquante!\n"
                "Créez un fichier .env avec: OPENAI_API_KEY=sk-..."
            )
        
        # Initialiser le client OpenAI
        self.client = OpenAI(api_key=self.api_key)
        
        # Initialiser les attributs
        self.resources = []
        self.embeddings = None
        self.faiss_index = None
        self.embedding_dim = 1536  # Dimension pour text-embedding-3-small
        
        print("✅ RecoBuilder initialisé avec OpenAI API")
    
    def load_resources(self, resources_path):
        """
        Charge la base de données de ressources pédagogiques.
        
        Args:
            resources_path: Chemin vers le fichier JSON des ressources
        """
        print(f"\n📚 Chargement des ressources depuis {resources_path}...")
        
        with open(resources_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.resources = data['resources']
        
        print(f"✅ {len(self.resources)} ressources chargées")
        
        # Afficher quelques exemples
        print(f"\nExemples de ressources:")
        for i, res in enumerate(self.resources[:3]):
            print(f"  {i+1}. [{res['type']}] {res['title']} - {res['subject']}")
        
        return self
    
    def build_faiss_index(self):
        """
        Construit l'index FAISS avec les embeddings OpenAI des ressources.
        Utilise text-embedding-3-small pour un bon rapport qualité/prix.
        """
        print(f"\n🔧 Construction de l'index FAISS avec embeddings OpenAI...")
        
        if not self.resources:
            raise ValueError("Aucune ressource chargée! Appelez load_resources() d'abord.")
        
        # Créer une description complète pour chaque ressource
        texts = []
        for res in self.resources:
            text = f"{res['title']}. {res['description']} Matière: {res['subject']}. Type: {res['type']}. Niveau: {res['difficulty']}."
            texts.append(text)
        
        # Générer les embeddings en batch
        print(f"  Génération des embeddings pour {len(texts)} ressources...")
        embeddings_list = []
        
        # Traiter par batch de 100 pour respecter les limites de l'API
        batch_size = 100
        for i in range(0, len(texts), batch_size):
            batch = texts[i:i+batch_size]
            response = self.client.embeddings.create(
                model="text-embedding-3-small",
                input=batch
            )
            batch_embeddings = [item.embedding for item in response.data]
            embeddings_list.extend(batch_embeddings)
            print(f"    Batch {i//batch_size + 1}/{(len(texts)-1)//batch_size + 1} traité")
        
        # Convertir en numpy array
        self.embeddings = np.array(embeddings_list, dtype='float32')
        
        # Créer l'index FAISS (L2 distance)
        self.faiss_index = faiss.IndexFlatL2(self.embedding_dim)
        self.faiss_index.add(self.embeddings)
        
        print(f"✅ Index FAISS créé: {self.faiss_index.ntotal} vecteurs indexés")
        
        return self
    
    def search_similar_resources(self, query, k=5, subject_filter=None):
        """
        Recherche les ressources les plus similaires à une requête.
        
        Args:
            query: Texte de recherche (ex: "aide en mathématiques pour algèbre")
            k: Nombre de résultats à retourner
            subject_filter: Filtrer par matière (optionnel)
        
        Returns:
            Liste de dictionnaires avec les ressources trouvées
        """
        if self.faiss_index is None:
            raise ValueError("Index FAISS non construit! Appelez build_faiss_index() d'abord.")
        
        # Générer l'embedding de la requête
        response = self.client.embeddings.create(
            model="text-embedding-3-small",
            input=[query]
        )
        query_embedding = np.array([response.data[0].embedding], dtype='float32')
        
        # Rechercher dans FAISS (on cherche plus que k pour filtrer ensuite)
        search_k = min(k * 3, len(self.resources))
        distances, indices = self.faiss_index.search(query_embedding, search_k)
        
        # Récupérer les ressources
        results = []
        for dist, idx in zip(distances[0], indices[0]):
            resource = self.resources[int(idx)].copy()
            resource['similarity_score'] = float(1 / (1 + dist))  # Score de similarité
            
            # Filtrer par matière si demandé
            if subject_filter and resource['subject'] != subject_filter:
                continue
            
            results.append(resource)
            
            if len(results) >= k:
                break
        
        return results
    
    def analyze_student_profile(self, student_id, df_clean, df_profiles):
        """
        Analyse le profil d'un étudiant pour identifier ses forces et faiblesses.
        
        Args:
            student_id: ID de l'étudiant
            df_clean: DataFrame nettoyé (de PrepaData)
            df_profiles: DataFrame des profils (de StudentProfiler)
        
        Returns:
            Dictionnaire avec l'analyse du profil
        """
        # Récupérer les données de l'étudiant
        student_data = df_clean[df_clean['ID'] == student_id]
        
        if len(student_data) == 0:
            return None
        
        # Récupérer le cluster si disponible
        cluster_info = None
        if df_profiles is not None:
            student_profile = df_profiles[df_profiles['ID'] == student_id]
            if len(student_profile) > 0:
                cluster_info = int(student_profile['Cluster'].iloc[0])
        
        # Analyser les matières
        subject_performance = student_data.groupby('Subject').agg({
            'Total': 'mean',
            'is_fail': 'mean'
        }).reset_index()
        subject_performance.columns = ['Subject', 'Average_Score', 'Failure_Rate']
        subject_performance = subject_performance.sort_values('Failure_Rate', ascending=False)
        
        # Identifier les matières problématiques (échec > 50%)
        weak_subjects = subject_performance[subject_performance['Failure_Rate'] > 0.5]
        
        # Identifier les matières fortes
        strong_subjects = subject_performance[subject_performance['Failure_Rate'] < 0.2]
        
        # Statistiques globales
        avg_score = student_data['Total'].mean()
        failure_rate = student_data['is_fail'].mean()
        
        # Déterminer le niveau de risque
        if failure_rate > 0.7:
            risk_level = "TRÈS ÉLEVÉ"
            risk_emoji = "🔴"
        elif failure_rate > 0.5:
            risk_level = "ÉLEVÉ"
            risk_emoji = "🟠"
        elif failure_rate > 0.3:
            risk_level = "MODÉRÉ"
            risk_emoji = "🟡"
        else:
            risk_level = "FAIBLE"
            risk_emoji = "🟢"
        
        return {
            'student_id': student_id,
            'cluster': cluster_info,
            'avg_score': avg_score,
            'failure_rate': failure_rate,
            'risk_level': risk_level,
            'risk_emoji': risk_emoji,
            'weak_subjects': weak_subjects.to_dict('records'),
            'strong_subjects': strong_subjects.to_dict('records'),
            'total_courses': len(student_data)
        }
    
    def generate_recommendations(self, student_profile):
        """
        Génère des recommandations personnalisées avec GPT-4.
        
        Args:
            student_profile: Dictionnaire du profil étudiant
        
        Returns:
            Dictionnaire avec les recommandations
        """
        print(f"\n🤖 Génération des recommandations pour l'étudiant {student_profile['student_id']}...")
        
        # Construire la requête pour chaque matière faible
        all_recommendations = []
        
        for weak_subject in student_profile['weak_subjects'][:3]:  # Top 3 matières faibles
            subject_name = weak_subject['Subject']
            failure_rate = weak_subject['Failure_Rate'] * 100
            
            # Rechercher des ressources pertinentes
            query = f"aide en {subject_name} pour améliorer compréhension et réussir examens"
            resources = self.search_similar_resources(query, k=3)
            
            # Créer le contexte pour GPT
            resources_text = "\n".join([
                f"- [{r['type']}] {r['title']}: {r['description']}"
                for r in resources
            ])
            
            # Préparer le prompt pour GPT
            prompt = f"""Tu es un conseiller pédagogique expert. Un étudiant a des difficultés en {subject_name} avec un taux d'échec de {failure_rate:.0f}%.

Niveau de risque global: {student_profile['risk_level']}
Note moyenne: {student_profile['avg_score']:.1f}/100

Ressources disponibles:
{resources_text}

Génère un plan d'action personnalisé et motivant incluant:
1. Un diagnostic bienveillant de la situation
2. Les 3 ressources recommandées parmi celles disponibles
3. Un plan d'étude hebdomadaire réaliste (heures par semaine)
4. Des conseils méthodologiques spécifiques
5. Un message d'encouragement

Sois concis (max 300 mots), encourageant et actionnable."""
            
            # Appeler GPT-4
            response = self.client.chat.completions.create(
                model="gpt-4o-mini",  # Rapide et performant
                messages=[
                    {"role": "system", "content": "Tu es un conseiller pédagogique expert et bienveillant."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=500
            )
            
            recommendation = response.choices[0].message.content
            
            all_recommendations.append({
                'subject': subject_name,
                'failure_rate': failure_rate,
                'resources': resources,
                'personalized_plan': recommendation
            })
        
        # Recommandation de tutorat si risque élevé
        needs_tutoring = student_profile['failure_rate'] > 0.6
        
        return {
            'student_id': student_profile['student_id'],
            'risk_level': student_profile['risk_level'],
            'risk_emoji': student_profile['risk_emoji'],
            'recommendations': all_recommendations,
            'needs_tutoring': needs_tutoring,
            'tutoring_recommendation': self._get_tutoring_recommendation(student_profile) if needs_tutoring else None
        }
    
    def _get_tutoring_recommendation(self, student_profile):
        """
        Génère une recommandation de tutorat personnalisée.
        """
        risk_level = student_profile['risk_level']
        
        if risk_level == "TRÈS ÉLEVÉ":
            return {
                'urgency': 'URGENTE',
                'sessions_per_week': 3,
                'duration_weeks': 8,
                'type': 'Tutorat intensif individuel',
                'description': 'Accompagnement rapproché avec suivi hebdomadaire et objectifs personnalisés.'
            }
        elif risk_level == "ÉLEVÉ":
            return {
                'urgency': 'IMPORTANTE',
                'sessions_per_week': 2,
                'duration_weeks': 6,
                'type': 'Tutorat régulier',
                'description': 'Séances de soutien bi-hebdomadaires pour consolider les bases.'
            }
        else:
            return {
                'urgency': 'MODÉRÉE',
                'sessions_per_week': 1,
                'duration_weeks': 4,
                'type': 'Tutorat ponctuel',
                'description': 'Support ciblé sur les points de difficulté identifiés.'
            }
    
    def save_recommendations(self, recommendations_list, output_path):
        """
        Sauvegarde les recommandations dans un fichier CSV.
        
        Args:
            recommendations_list: Liste des recommandations générées
            output_path: Chemin du fichier de sortie
        """
        print(f"\n💾 Sauvegarde des recommandations dans {output_path}...")
        
        # Convertir en DataFrame
        rows = []
        for reco in recommendations_list:
            student_id = reco['student_id']
            risk_level = reco['risk_level']
            
            for subject_reco in reco['recommendations']:
                # Extraire les ressources recommandées
                resource_titles = [r['title'] for r in subject_reco['resources']]
                resource_urls = [r['url'] for r in subject_reco['resources']]
                
                rows.append({
                    'student_id': student_id,
                    'risk_level': risk_level,
                    'subject': subject_reco['subject'],
                    'failure_rate': subject_reco['failure_rate'],
                    'resource_1': resource_titles[0] if len(resource_titles) > 0 else '',
                    'resource_2': resource_titles[1] if len(resource_titles) > 1 else '',
                    'resource_3': resource_titles[2] if len(resource_titles) > 2 else '',
                    'url_1': resource_urls[0] if len(resource_urls) > 0 else '',
                    'url_2': resource_urls[1] if len(resource_urls) > 1 else '',
                    'url_3': resource_urls[2] if len(resource_urls) > 2 else '',
                    'personalized_plan': subject_reco['personalized_plan'],
                    'needs_tutoring': reco['needs_tutoring']
                })
        
        df = pd.DataFrame(rows)
        df.to_csv(output_path, index=False, encoding='utf-8-sig')
        
        print(f"✅ {len(rows)} recommandations sauvegardées")
        
        return df
    
    def run_all(self, resources_path, df_clean, df_profiles=None, sample_students=None):
        """
        Exécute le pipeline complet RecoBuilder.
        
        Args:
            resources_path: Chemin vers les ressources pédagogiques
            df_clean: DataFrame nettoyé
            df_profiles: DataFrame des profils (optionnel)
            sample_students: Liste d'IDs d'étudiants à analyser (None = tous les étudiants à risque)
        
        Returns:
            Liste des recommandations
        """
        print("\n" + "="*70)
        print("🎓 COMPOSANT 4: RecoBuilder - Recommandations Pédagogiques")
        print("="*70)
        
        # Charger et indexer les ressources
        self.load_resources(resources_path)
        self.build_faiss_index()
        
        # Identifier les étudiants à traiter
        if sample_students is None:
            # Prendre les étudiants à risque (taux d'échec > 50%)
            at_risk_students = df_clean.groupby('ID').agg({
                'is_fail': 'mean'
            }).reset_index()
            at_risk_students = at_risk_students[at_risk_students['is_fail'] > 0.5]
            sample_students = at_risk_students['ID'].tolist()[:20]  # Limiter à 20 pour la démo
        
        print(f"\n📊 Génération de recommandations pour {len(sample_students)} étudiants...")
        
        # Générer les recommandations
        all_recommendations = []
        
        for i, student_id in enumerate(sample_students):
            print(f"\n[{i+1}/{len(sample_students)}] Étudiant {student_id}...")
            
            # Analyser le profil
            profile = self.analyze_student_profile(student_id, df_clean, df_profiles)
            
            if profile is None:
                print(f"  ⚠️ Aucune donnée trouvée")
                continue
            
            print(f"  {profile['risk_emoji']} Risque: {profile['risk_level']} (échecs: {profile['failure_rate']*100:.0f}%)")
            print(f"  📚 Matières faibles: {len(profile['weak_subjects'])}")
            
            # Générer les recommandations
            recommendations = self.generate_recommendations(profile)
            all_recommendations.append(recommendations)
        
        print("\n✅ Recommandations générées!")
        
        return all_recommendations


def main():
    """
    Fonction de test pour RecoBuilder
    """
    from src import config
    
    # Charger les données
    print("📂 Chargement des données...")
    df_clean = pd.read_csv(config.CLEANED_DATA)
    
    try:
        df_profiles = pd.read_csv(config.STUDENT_PROFILES)
    except:
        df_profiles = None
    
    # Initialiser RecoBuilder
    recommender = RecoBuilder()
    
    # Tester sur quelques étudiants
    sample_ids = df_clean['ID'].unique()[:5]  # 5 premiers étudiants
    
    recommendations = recommender.run_all(
        resources_path=config.EDUCATIONAL_RESOURCES,
        df_clean=df_clean,
        df_profiles=df_profiles,
        sample_students=sample_ids
    )
    
    # Sauvegarder
    recommender.save_recommendations(recommendations, config.RECOMMENDATIONS_OUTPUT)
    
    print("\n🎉 Test terminé!")


if __name__ == "__main__":
    main()
