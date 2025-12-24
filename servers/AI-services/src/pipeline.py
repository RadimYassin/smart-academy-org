"""
EduPath-MS: Pipeline Data Science pour Learning Analytics
Auteur: Pipeline automatisé pour analyse éducative
Date: 2025-12-21

Ce script implémente 4 composants principaux:
1. PrepaData: Nettoyage et Feature Engineering
2. StudentProfiler: Clustering K-Means (Non supervisé)
3. PathPredictor: Prédiction XGBoost (Supervisé)
4. RecoBuilder: Recommandations Pédagogiques (Optionnel - nécessite OpenAI API)

Infrastructure:
- PostgreSQL: Stockage des données (mode hybride CSV/PostgreSQL)
- MLflow: Tracking des expériences ML
- Airflow: Orchestration du pipeline (voir airflow/dags/)
"""

# ============================================================================
# IMPORTS
# ============================================================================
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.cluster import KMeans
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report, silhouette_score
import xgboost as xgb
import warnings
warnings.filterwarnings('ignore')

# Configuration centralisée
try:
    from config import *
    from database import save_data, load_data, init_db
    from mlflow_config import init_mlflow, MLflowRun, log_params, log_metrics, log_model
except ImportError:
    from src.config import *
    from src.database import save_data, load_data, init_db
    from src.mlflow_config import init_mlflow, MLflowRun, log_params, log_metrics, log_model

# Configuration du style des graphiques
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['font.size'] = 10

# ============================================================================
# COMPOSANT 1: PrepaData - Nettoyage et Feature Engineering
# ============================================================================

class PrepaData:
    """
    Classe pour le nettoyage et la préparation des données étudiantes.
    
    Fonctionnalités:
    - Recalcul de la colonne Total
    - Encodage des matières (Subject) en arabe
    - Création de la variable cible is_fail
    """
    
    def __init__(self, df):
        """
        Initialise avec un DataFrame
        
        Args:
            df: DataFrame pandas avec les colonnes requises
        """
        self.df = df.copy()
        self.label_encoder = LabelEncoder()
        
    def recalculate_total(self):
        """
        Recalcule la colonne Total = Practical + Theoretical.
        Si les deux sont 0 et Status = "Absent", Total reste 0.
        """
        print("📊 Recalcul de la colonne 'Total'...")
        
        # Créer une nouvelle colonne Total calculée
        self.df['Total_Calculated'] = self.df['Practical'] + self.df['Theoretical']
        
        # Remplacer NaN dans Total par les valeurs calculées
        self.df['Total'] = self.df['Total'].fillna(self.df['Total_Calculated'])
        
        # Supprimer la colonne temporaire
        self.df.drop('Total_Calculated', axis=1, inplace=True)
        
        print(f"✓ Total recalculé. Valeurs NaN restantes: {self.df['Total'].isna().sum()}")
        
        return self
    
    def encode_subject(self):
        """
        Encode la colonne Subject (contenant du texte arabe) en valeurs numériques.
        Utilise LabelEncoder pour transformer chaque matière unique en un entier.
        """
        print("🔤 Encodage de la colonne 'Subject' (texte arabe)...")
        
        # Gérer les valeurs manquantes
        self.df['Subject'] = self.df['Subject'].fillna('Unknown')
        
        # Encoder les matières
        self.df['Subject_Encoded'] = self.label_encoder.fit_transform(self.df['Subject'])
        
        # Afficher quelques exemples de mapping
        unique_subjects = self.df['Subject'].unique()[:5]
        print(f"✓ Encodage terminé. {len(self.df['Subject'].unique())} matières uniques.")
        print("Exemples de mapping:")
        for subject in unique_subjects:
            encoded_val = self.df[self.df['Subject'] == subject]['Subject_Encoded'].iloc[0]
            print(f"  - {subject} → {encoded_val}")
        
        return self
    
    def create_target_variable(self, threshold=10):
        """
        Crée la variable cible binaire 'is_fail'.
        
        is_fail = 1 si:
        - Status est "Withdrawal", "Debarred" ou "Absent"
        - OU Total < threshold (défaut: 10 pour validation minimum)
        
        Args:
            threshold: Seuil de note minimum pour la réussite (défaut: 10)
        """
        print(f"🎯 Création de la variable cible 'is_fail' (seuil: {threshold})...")
        
        # Définir les statuts d'échec
        failure_statuses = ['Withdrawal', 'Debarred', 'Absent']
        
        # Créer la colonne is_fail
        self.df['is_fail'] = 0
        
        # Marquer comme échec si Status dans la liste d'échec
        self.df.loc[self.df['Status'].isin(failure_statuses), 'is_fail'] = 1
        
        # Marquer comme échec si Total < threshold
        self.df.loc[self.df['Total'] < threshold, 'is_fail'] = 1
        
        # Statistiques
        fail_count = self.df['is_fail'].sum()
        total_count = len(self.df)
        fail_rate = (fail_count / total_count) * 100
        
        print(f"✓ Variable cible créée:")
        print(f"  - Échecs (is_fail=1): {fail_count} ({fail_rate:.2f}%)")
        print(f"  - Réussites (is_fail=0): {total_count - fail_count} ({100-fail_rate:.2f}%)")
        
        return self
    
    def get_clean_data(self):
        """
        Retourne le DataFrame nettoyé et préparé.
        """
        return self.df
    
    def run_all(self, threshold=10):
        """
        Exécute toutes les étapes de préparation.
        
        Args:
            threshold: Seuil de note pour is_fail
        
        Returns:
            DataFrame nettoyé
        """
        print("\n" + "="*70)
        print("🔧 COMPOSANT 1: PrepaData - Nettoyage et Feature Engineering")
        print("="*70 + "\n")
        
        self.recalculate_total()
        self.encode_subject()
        self.create_target_variable(threshold)
        
        print("\n✅ Préparation terminée!")
        return self.df


# ============================================================================
# COMPOSANT 2: StudentProfiler - Clustering K-Means
# ============================================================================

class StudentProfiler:
    """
    Classe pour créer des profils d'étudiants via clustering K-Means.
    
    Fonctionnalités:
    - Agrégation des données par étudiant (ID)
    - Normalisation avec StandardScaler
    - Méthode du coude pour trouver K optimal
    - Clustering K-Means
    """
    
    def __init__(self, df):
        """
        Initialise avec un DataFrame préparé
        
        Args:
            df: DataFrame après PrepaData
        """
        self.df = df.copy()
        self.scaler = StandardScaler()
        self.student_features = None
        self.scaled_features = None
        self.kmeans = None
        
    def aggregate_by_student(self):
        """
        Agrège les données par ID étudiant pour créer des statistiques globales:
        - Moyenne générale
        - Nombre d'absences
        - Taux d'échec par semestre
        """
        print("📈 Agrégation des données par étudiant...")
        
        # Convertir ID en numérique et supprimer les valeurs invalides
        self.df['ID'] = pd.to_numeric(self.df['ID'], errors='coerce')
        self.df = self.df.dropna(subset=['ID'])
        self.df['ID'] = self.df['ID'].astype(int)
        
        # Grouper par ID
        student_agg = self.df.groupby('ID').agg({
            'Total': 'mean',                    # Moyenne générale
            'is_fail': 'sum',                   # Nombre total d'échecs
            'Semester': 'count',                # Nombre de cours suivis
            'Practical': 'mean',                # Moyenne pratique
            'Theoretical': 'mean'               # Moyenne théorique
        }).reset_index()
        
        # Renommer les colonnes
        student_agg.columns = ['ID', 'Average_Grade', 'Total_Failures', 
                                'Total_Courses', 'Avg_Practical', 'Avg_Theoretical']
        
        # Calculer le taux d'échec
        student_agg['Failure_Rate'] = (student_agg['Total_Failures'] / 
                                        student_agg['Total_Courses']) * 100
        
        # Compter les absences (statut="Absent")
        absence_count = self.df[self.df['Status'] == 'Absent'].groupby('ID').size()
        student_agg['Absence_Count'] = student_agg['ID'].map(absence_count).fillna(0)
        
        self.student_features = student_agg
        
        print(f"✓ Agrégation terminée. {len(student_agg)} étudiants uniques.")
        print(f"\nStatistiques par étudiant:")
        print(student_agg.describe())
        
        return self
    
    def normalize_features(self):
        """
        Normalise les features numériques avec StandardScaler.
        """
        print("\n🔄 Normalisation des features...")
        
        # Sélectionner les features numériques (exclure ID)
        feature_cols = ['Average_Grade', 'Total_Failures', 'Total_Courses', 
                        'Avg_Practical', 'Avg_Theoretical', 'Failure_Rate', 'Absence_Count']
        
        X = self.student_features[feature_cols]
        
        # Normaliser
        self.scaled_features = self.scaler.fit_transform(X)
        
        print(f"✓ Normalisation terminée. Shape: {self.scaled_features.shape}")
        
        return self
    
    def find_optimal_k(self, k_range=range(2, 8)):
        """
        Utilise la méthode du coude (Elbow Method) pour trouver le K optimal.
        
        Args:
            k_range: Range de valeurs K à tester (défaut: 2 à 7)
        """
        print(f"\n📊 Recherche du K optimal (méthode du coude)...")
        
        inertias = []
        silhouette_scores = []
        
        for k in k_range:
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            kmeans.fit(self.scaled_features)
            inertias.append(kmeans.inertia_)
            
            # Calculer le silhouette score
            score = silhouette_score(self.scaled_features, kmeans.labels_)
            silhouette_scores.append(score)
        
        # Visualisation
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
        
        # Elbow curve
        ax1.plot(k_range, inertias, marker='o', linewidth=2, markersize=8)
        ax1.set_xlabel('Nombre de clusters (K)', fontsize=12)
        ax1.set_ylabel('Inertie (Within-cluster sum of squares)', fontsize=12)
        ax1.set_title('Méthode du Coude pour K optimal', fontsize=14, fontweight='bold')
        ax1.grid(True, alpha=0.3)
        
        # Silhouette scores
        ax2.plot(k_range, silhouette_scores, marker='s', linewidth=2, markersize=8, color='orange')
        ax2.set_xlabel('Nombre de clusters (K)', fontsize=12)
        ax2.set_ylabel('Silhouette Score', fontsize=12)
        ax2.set_title('Silhouette Score par K', fontsize=14, fontweight='bold')
        ax2.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(ELBOW_PLOT, dpi=150, bbox_inches='tight')
        plt.close()
        
        print(f"✓ Graphique sauvegardé: elbow_method.png")
        print(f"\nSilhouette Scores:")
        for k, score in zip(k_range, silhouette_scores):
            print(f"  K={k}: {score:.4f}")
        
        return self
    
    def cluster_students(self, n_clusters=4):
        """
        Applique K-Means clustering avec K clusters.
        
        Args:
            n_clusters: Nombre de clusters (défaut: 4)
        """
        print(f"\n🎯 Application de K-Means avec K={n_clusters}...")
        
        # Appliquer K-Means
        self.kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        clusters = self.kmeans.fit_predict(self.scaled_features)
        
        # Ajouter les clusters au DataFrame
        self.student_features['Cluster'] = clusters
        
        # Analyser les clusters
        print(f"\n✓ Clustering terminé. Distribution des clusters:")
        print(self.student_features['Cluster'].value_counts().sort_index())
        
        # Profil de chaque cluster
        print(f"\n📋 Profil moyen par cluster:")
        cluster_profiles = self.student_features.groupby('Cluster').mean()
        print(cluster_profiles)
        
        # Interpréter les clusters
        self._interpret_clusters()
        
        return self
    
    def _interpret_clusters(self):
        """
        Interprète les clusters en leur donnant des labels significatifs.
        """
        print(f"\n🏷️ Interprétation des clusters:")
        
        for cluster_id in sorted(self.student_features['Cluster'].unique()):
            cluster_data = self.student_features[self.student_features['Cluster'] == cluster_id]
            
            avg_grade = cluster_data['Average_Grade'].mean()
            failure_rate = cluster_data['Failure_Rate'].mean()
            absence_count = cluster_data['Absence_Count'].mean()
            
            # Déterminer le profil
            if failure_rate > 60 or absence_count > 5:
                profile = "🔴 En grande difficulté / Décrocheurs"
            elif failure_rate > 30:
                profile = "🟠 En difficulté"
            elif avg_grade > 14:
                profile = "🟢 Excellents"
            else:
                profile = "🟡 Moyens / Stables"
            
            print(f"\n  Cluster {cluster_id} - {profile}")
            print(f"    - Moyenne générale: {avg_grade:.2f}")
            print(f"    - Taux d'échec: {failure_rate:.2f}%")
            print(f"    - Absences moyennes: {absence_count:.2f}")
            print(f"    - Nombre d'étudiants: {len(cluster_data)}")
    
    def visualize_clusters(self):
        """
        Visualise les clusters en 2D (PCA ou features principales).
        """
        from sklearn.decomposition import PCA
        
        print(f"\n📊 Visualisation des clusters...")
        
        # Réduction à 2D avec PCA
        pca = PCA(n_components=2)
        features_2d = pca.fit_transform(self.scaled_features)
        
        plt.figure(figsize=(10, 7))
        scatter = plt.scatter(features_2d[:, 0], features_2d[:, 1], 
                            c=self.student_features['Cluster'], 
                            cmap='viridis', s=50, alpha=0.6, edgecolors='black')
        plt.colorbar(scatter, label='Cluster')
        plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]*100:.1f}% variance)', fontsize=12)
        plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]*100:.1f}% variance)', fontsize=12)
        plt.title('Profils d\'étudiants - Clustering K-Means (PCA)', fontsize=14, fontweight='bold')
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig(CLUSTERS_PLOT, dpi=150, bbox_inches='tight')
        plt.close()
        
        print(f"✓ Graphique sauvegardé: student_clusters.png")
        
        return self
    
    def get_student_profiles(self):
        """
        Retourne le DataFrame avec les profils étudiants et clusters.
        """
        return self.student_features
    
    def run_all(self, n_clusters=4):
        """
        Exécute toutes les étapes de profiling.
        
        Args:
            n_clusters: Nombre de clusters à créer
        
        Returns:
            DataFrame avec profils étudiants
        """
        print("\n" + "="*70)
        print("👥 COMPOSANT 2: StudentProfiler - Clustering K-Means")
        print("="*70 + "\n")
        
        self.aggregate_by_student()
        self.normalize_features()
        self.find_optimal_k()
        self.cluster_students(n_clusters)
        self.visualize_clusters()
        
        print("\n✅ Profiling terminé!")
        return self.student_features


# ============================================================================
# COMPOSANT 3: PathPredictor - Prédiction XGBoost
# ============================================================================

class PathPredictor:
    """
    Classe pour prédire la réussite/échec avec XGBoost.
    
    Fonctionnalités:
    - Préparation des features (X) et target (y)
    - Entraînement XGBoost avec gestion du déséquilibre
    - Évaluation (confusion matrix, feature importance)
    """
    
    def __init__(self, df):
        """
        Initialise avec un DataFrame préparé
        
        Args:
            df: DataFrame après PrepaData
        """
        self.df = df.copy()
        self.model = None
        self.X_train = None
        self.X_test = None
        self.y_train = None
        self.y_test = None
        self.feature_names = None
        
    def prepare_features(self):
        """
        Prépare les features (X) et la target (y = is_fail) avec feature engineering avancé.
        """
        print("🔧 Préparation des features avec feature engineering avancé...")
        
        # Features de base
        feature_cols = ['Subject_Encoded', 'Semester', 'Practical', 
                        'Theoretical', 'Total', 'MajorYear']
        
        # Encoder Major si nécessaire
        if self.df['Major'].dtype == 'object':
            le_major = LabelEncoder()
            self.df['Major_Encoded'] = le_major.fit_transform(self.df['Major'].fillna('Unknown'))
            feature_cols.append('Major_Encoded')
        
        # === FEATURE ENGINEERING AVANCÉ ===
        
        # 1. Ratio Pratique/Théorique
        self.df['Practical_Theoretical_Ratio'] = self.df['Practical'] / (self.df['Theoretical'] + 1e-5)
        feature_cols.append('Practical_Theoretical_Ratio')
        
        # 2. Écart à la moyenne
        self.df['Total_Deviation'] = self.df['Total'] - self.df['Total'].mean()
        feature_cols.append('Total_Deviation')
        
        # 3. Performance relative par matière
        subject_means = self.df.groupby('Subject_Encoded')['Total'].transform('mean')
        self.df['Subject_Relative_Performance'] = self.df['Total'] - subject_means
        feature_cols.append('Subject_Relative_Performance')
        
        # 4. Interaction Semester x Subject (difficulté croissante)
        self.df['Semester_Subject_Interaction'] = self.df['Semester'] * self.df['Subject_Encoded']
        feature_cols.append('Semester_Subject_Interaction')
        
        # 5. Indicateur de très faible note
        self.df['Very_Low_Score'] = (self.df['Total'] < 5).astype(int)
        feature_cols.append('Very_Low_Score')
        
        # 6. Progression (différence avec semestre précédent par étudiant)
        if 'ID' in self.df.columns:
            self.df = self.df.sort_values(['ID', 'Semester'])
            self.df['Previous_Total'] = self.df.groupby('ID')['Total'].shift(1)
            self.df['Score_Progression'] = self.df['Total'] - self.df['Previous_Total']
            self.df['Score_Progression'] = self.df['Score_Progression'].fillna(0)
            feature_cols.append('Score_Progression')
        
        # Gérer les valeurs manquantes et infinies
        self.df[feature_cols] = self.df[feature_cols].fillna(0)
        self.df[feature_cols] = self.df[feature_cols].replace([np.inf, -np.inf], 0)
        
        # X et y
        X = self.df[feature_cols]
        y = self.df['is_fail']
        
        # Split train/test (80% train, 20% test)
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        self.feature_names = feature_cols
        
        print(f"✓ Features préparées (avec engineering):")
        print(f"  - Train: {self.X_train.shape}")
        print(f"  - Test: {self.X_test.shape}")
        print(f"  - Features totales: {len(feature_cols)} ({len(feature_cols) - 6} nouvelles)")
        print(f"  - Nouvelles features: Ratios, Déviations, Interactions, Progression")
        
        # Distribution de la target
        print(f"\n  Distribution de la target:")
        print(f"    - Train: Échecs={self.y_train.sum()}, Réussites={len(self.y_train)-self.y_train.sum()}")
        print(f"    - Test: Échecs={self.y_test.sum()}, Réussites={len(self.y_test)-self.y_test.sum()}")
        
        return self
    
    def train_model(self, use_grid_search=True):
        """
        Entraîne le modèle XGBoost avec hyperparameter tuning pour atteindre 90%+ accuracy.
        
        Args:
            use_grid_search: Si True, utilise GridSearchCV pour optimiser (plus lent mais meilleur)
        """
        print(f"\n🚀 Entraînement du modèle XGBoost avec optimisation...")
        
        # Calculer scale_pos_weight pour gérer le déséquilibre
        negative_count = (self.y_train == 0).sum()
        positive_count = (self.y_train == 1).sum()
        scale_pos_weight = negative_count / positive_count
        
        print(f"  - Déséquilibre détecté: Ratio={negative_count}/{positive_count}")
        print(f"  - scale_pos_weight={scale_pos_weight:.2f}")
        
        if use_grid_search:
            print(f"  - Mode: Hyperparameter Tuning (GridSearchCV)")
            print(f"  - Cela peut prendre 2-3 minutes...")
            
            from sklearn.model_selection import GridSearchCV
            
            # Modèle de base
            base_model = xgb.XGBClassifier(
                scale_pos_weight=scale_pos_weight,
                random_state=42,
                eval_metric='logloss'
            )
            
            # Grille d'hyperparamètres optimisée pour 90%+
            param_grid = {
                'max_depth': [5, 6, 7, 8],
                'learning_rate': [0.05, 0.1, 0.15],
                'n_estimators': [100, 150, 200],
                'min_child_weight': [1, 3, 5],
                'subsample': [0.8, 0.9, 1.0],
                'colsample_bytree': [0.8, 0.9, 1.0]
            }
            
            # GridSearchCV avec cross-validation
            grid_search = GridSearchCV(
                base_model,
                param_grid,
                cv=5,
                scoring='accuracy',
                n_jobs=-1,
                verbose=1
            )
            
            grid_search.fit(self.X_train, self.y_train)
            
            self.model = grid_search.best_estimator_
            
            print(f"\n  ✓ Meilleurs hyperparamètres trouvés:")
            for param, value in grid_search.best_params_.items():
                print(f"    - {param}: {value}")
            print(f"  ✓ Meilleur score CV: {grid_search.best_score_*100:.2f}%")
            
        else:
            # Configuration optimisée manuellement
            print(f"  - Mode: Configuration optimisée")
            
            self.model = xgb.XGBClassifier(
                max_depth=7,
                learning_rate=0.1,
                n_estimators=150,
                min_child_weight=3,
                subsample=0.9,
                colsample_bytree=0.9,
                scale_pos_weight=scale_pos_weight,
                random_state=42,
                eval_metric='logloss'
            )
            
            self.model.fit(self.X_train, self.y_train)
        
        print(f"\n✓ Modèle XGBoost optimisé entraîné!")
        
        return self
    
    def evaluate_model(self):
        """
        Évalue le modèle sur le set de test.
        Affiche la confusion matrix et le classification report.
        """
        print(f"\n📊 Évaluation du modèle...")
        
        # Prédictions
        y_pred_train = self.model.predict(self.X_train)
        y_pred_test = self.model.predict(self.X_test)
        
        # Accuracies
        train_acc = (y_pred_train == self.y_train).mean()
        test_acc = (y_pred_test == self.y_test).mean()
        
        print(f"\n  Accuracy:")
        print(f"    - Train: {train_acc*100:.2f}%")
        print(f"    - Test: {test_acc*100:.2f}%")
        
        # Confusion Matrix
        cm = confusion_matrix(self.y_test, y_pred_test)
        
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                    xticklabels=['Réussite', 'Échec'],
                    yticklabels=['Réussite', 'Échec'], cbar=True, annot_kws={"size": 14})
        plt.xlabel('Prédiction', fontsize=12)
        plt.ylabel('Réalité', fontsize=12)
        plt.title('Matrice de Confusion - Prédiction Réussite/Échec', 
                  fontsize=14, fontweight='bold')
        plt.tight_layout()
        plt.savefig(CONFUSION_MATRIX_PLOT, dpi=150, bbox_inches='tight')
        plt.close()
        
        print(f"\n✓ Matrice de confusion sauvegardée: confusion_matrix.png")
        
        # Classification Report
        print(f"\n  Classification Report:")
        print(classification_report(self.y_test, y_pred_test, 
                                    target_names=['Réussite', 'Échec']))
        
        return self
    
    def plot_feature_importance(self):
        """
        Affiche l'importance des features pour comprendre les facteurs d'échec.
        """
        print(f"\n📈 Importance des features...")
        
        # Récupérer les importances
        importances = self.model.feature_importances_
        
        # Créer un DataFrame pour faciliter la visualisation
        feature_importance_df = pd.DataFrame({
            'Feature': self.feature_names,
            'Importance': importances
        }).sort_values('Importance', ascending=False)
        
        print(feature_importance_df)
        
        # Visualisation
        plt.figure(figsize=(10, 6))
        plt.barh(feature_importance_df['Feature'], feature_importance_df['Importance'], 
                 color='steelblue', edgecolor='black')
        plt.xlabel('Importance', fontsize=12)
        plt.ylabel('Features', fontsize=12)
        plt.title('Importance des Features - Prédiction d\'Échec', 
                  fontsize=14, fontweight='bold')
        plt.gca().invert_yaxis()
        plt.grid(axis='x', alpha=0.3)
        plt.tight_layout()
        plt.savefig(FEATURE_IMPORTANCE_PLOT, dpi=150, bbox_inches='tight')
        plt.close()
        
        print(f"✓ Graphique sauvegardé: feature_importance.png")
        
        return self
    
    def run_all(self, use_grid_search=True):
        """
        Exécute toutes les étapes de prédiction.
        
        Args:
            use_grid_search: Si True, utilise GridSearchCV (défaut: True)
        
        Returns:
            Modèle entraîné
        """
        print("\n" + "="*70)
        print("🎯 COMPOSANT 3: PathPredictor - Prédiction XGBoost")
        print("="*70 + "\n")
        
        self.prepare_features()
        self.train_model(use_grid_search=use_grid_search)  # GridSearch par défaut
        self.evaluate_model()
        self.plot_feature_importance()
        
        print("\n✅ Prédiction terminée!")
        return self.model


# ============================================================================
# PIPELINE PRINCIPAL
# ============================================================================

def main():
    """
    Fonction principale qui exécute le pipeline complet.
    """
    print("\n" + "="*70)
    print("🎓 EDUPATH-MS: Pipeline Data Science - Learning Analytics")
    print("="*70 + "\n")
    
    # Charger les données
    print("📂 Chargement des données...")
    df1 = pd.read_csv(DATASET_1)
    df2 = pd.read_csv(DATASET_2)
    
    print(f"  - Dataset 1: {df1.shape}")
    print(f"  - Dataset 2: {df2.shape}")
    
    # Combiner les datasets (ou travailler séparément)
    df_combined = pd.concat([df1, df2], ignore_index=True)
    print(f"  - Dataset combiné: {df_combined.shape}")
    
    # ========================================================================
    # ÉTAPE 1: PrepaData
    # ========================================================================
    preparer = PrepaData(df_combined)
    df_clean = preparer.run_all(threshold=DEFAULT_FAIL_THRESHOLD)
    
    # Sauvegarder les données nettoyées (PostgreSQL ou CSV selon config)
    save_data(df_clean, 'cleaned_data', CLEANED_DATA)
    print(f"\n💾 Données nettoyées sauvegardées")
    
    # ========================================================================
    # ÉTAPE 2: StudentProfiler
    # ========================================================================
    profiler = StudentProfiler(df_clean)
    student_profiles = profiler.run_all(n_clusters=DEFAULT_N_CLUSTERS)
    
    # Sauvegarder les profils (PostgreSQL ou CSV selon config)
    save_data(student_profiles, 'student_profiles', STUDENT_PROFILES)
    print(f"\n💾 Profils étudiants sauvegardés")
    
    # ========================================================================
    # ÉTAPE 3: PathPredictor (avec MLflow tracking)
    # ========================================================================
    
    # Initialiser MLflow si disponible
    mlflow_available = init_mlflow()
    
    if mlflow_available:
        # Avec MLflow tracking
        with MLflowRun("path_predictor_run"):
            predictor = PathPredictor(df_clean)
            model = predictor.run_all()
            
            # Logger le modèle dans MLflow
            log_model(model, "xgboost_model")
    else:
        # Sans MLflow
        predictor = PathPredictor(df_clean)
        model = predictor.run_all()
    
    # Sauvegarder le modèle (fallback pickle)
    import pickle
    with open(XGBOOST_MODEL, 'wb') as f:
        pickle.dump(model, f)
    print(f"\n💾 Modèle XGBoost sauvegardé: {XGBOOST_MODEL}")
    
    # ========================================================================
    # ÉTAPE 4 (OPTIONNELLE): RecoBuilder
    # ========================================================================
    # Pour activer le composant RecoBuilder:
    # 1. Créez un fichier .env avec votre clé OpenAI: OPENAI_API_KEY=sk-...
    # 2. Décommentez le code ci-dessous
    
    # try:
    #     from recobuilder import RecoBuilder
    #     recommender = RecoBuilder()
    #     recommendations = recommender.run_all(
    #         resources_path=EDUCATIONAL_RESOURCES,
    #         df_clean=df_clean,
    #         df_profiles=student_profiles
    #     )
    #     recommender.save_recommendations(recommendations, RECOMMENDATIONS_OUTPUT)
    #     print(f"\n💾 Recommandations sauvegardées: {RECOMMENDATIONS_OUTPUT}")
    # except Exception as e:
    #     print(f"\n⚠️ RecoBuilder désactivé: {e}")
    #     print("   Pour activer, ajoutez votre clé OpenAI dans .env")
    
    # ========================================================================
    # RÉSUMÉ FINAL
    # ========================================================================
    print("\n" + "="*70)
    print("✅ PIPELINE COMPLET TERMINÉ!")
    print("="*70)
    print("\n📁 Fichiers générés:")
    print(f"  1. {CLEANED_DATA}")
    print(f"  2. {STUDENT_PROFILES}")
    print(f"  3. {ELBOW_PLOT}")
    print(f"  4. {CLUSTERS_PLOT}")
    print(f"  5. {CONFUSION_MATRIX_PLOT}")
    print(f"  6. {FEATURE_IMPORTANCE_PLOT}")
    print(f"  7. {XGBOOST_MODEL}")
    print("\n💡 Pour générer des recommandations personnalisées:")
    print("   python demo_recobuilder.py")
    print("\n🎉 Tous les composants ont été exécutés avec succès!")
    print("="*70 + "\n")


if __name__ == "__main__":
    main()
