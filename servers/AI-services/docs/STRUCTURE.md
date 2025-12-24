# EduPath-MS: Structure du Projet

```
edupath-ms/
│
├── 📁 data/                          # Données du projet
│   ├── raw/                          # Données brutes (non modifiées)
│   │   ├── 1- one_clean.csv         # Dataset 1 (année 1 ou train)
│   │   └── 2- two_clean.csv         # Dataset 2 (année 2 ou test)
│   │
│   └── processed/                    # Données traitées
│       ├── data_cleaned.csv         # Données nettoyées et transformées
│       └── student_profiles.csv     # Profils d'étudiants avec clusters
│
├── 📁 src/                           # Code source
│   ├── __init__.py                  # Package Python marker
│   ├── config.py                    # Configuration centralisée (chemins, paramètres)
│   ├── pipeline.py                  # Pipeline principal (3 composants)
│   └── examples.py                  # Exemples d'utilisation
│
├── 📁 outputs/                       # Résultats générés
│   ├── figures/                     # Graphiques et visualisations
│   │   ├── elbow_method.png        # Méthode du coude K-Means
│   │   ├── student_clusters.png    # Visualisation des clusters
│   │   ├── confusion_matrix.png    # Matrice de confusion XGBoost
│   │   └── feature_importance.png  # Importance des features
│   │
│   └── models/                      # Modèles entraînés (sauvegardés)
│       └── xgboost_model.pkl       # Modèle XGBoost sérialisé
│
├── 📁 docs/                          # Documentation
│   └── (fichiers de documentation)
│
├── 📄 run_pipeline.py                # Point d'entrée principal
├── 📄 edupath_pipeline.py            # Script original (legacy)
├── 📄 requirements.txt               # Dépendances Python
└── 📄 README.md                      # Guide d'utilisation
```

## 🎯 Description des Dossiers

### 📁 `data/`
Contient toutes les données du projet, organisées en deux catégories:
- **raw/**: Données brutes non modifiées (CSV originaux)
- **processed/**: Données après nettoyage et transformation

### 📁 `src/`
Code source principal du projet:
- **config.py**: Configuration centralisée (tous les chemins en un seul endroit)
- **pipeline.py**: Les 3 composants (PrepaData, StudentProfiler, PathPredictor)
- **examples.py**: Exemples d'utilisation des composants

### 📁 `outputs/`
Résultats générés par le pipeline:
- **figures/**: Tous les graphiques (PNG)
- **models/**: Modèles ML sauvegardés (PKL)

### 📁 `docs/`
Documentation du projet (guides, notes techniques, etc.)

## 🚀 Utilisation

### Exécution du pipeline complet
```bash
python run_pipeline.py
```

### Exécution du script original (legacy)
```bash
python edupath_pipeline.py
```

### Exemples d'utilisation
```bash
python src/examples.py
```

## 📝 Avantages de cette Structure

✅ **Organisation claire**: Séparation logique code/données/résultats  
✅ **Scalabilité**: Facile d'ajouter de nouveaux composants  
✅ **Maintenance**: Configuration centralisée dans `config.py`  
✅ **Collaboration**: Structure standard reconnue par les data scientists  
✅ **Git-friendly**: Facile d'ignorer les données/outputs avec `.gitignore`

## 🔧 Configuration

Tous les chemins et paramètres sont définis dans `src/config.py`. Pour personnaliser:

```python
# src/config.py
DEFAULT_FAIL_THRESHOLD = 12  # Changer le seuil de réussite
DEFAULT_N_CLUSTERS = 5       # Changer le nombre de clusters
```

## 📦 Fichiers Ignorés (pour Git)

Créer un `.gitignore` avec:
```
data/raw/*.csv
data/processed/*.csv
outputs/figures/*.png
outputs/models/*.pkl
__pycache__/
*.pyc
```

---

**Dernière mise à jour**: 30 Novembre 2025
