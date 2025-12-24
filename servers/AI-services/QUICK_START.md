# 🎓 EduPath-MS - Guide de Démarrage Rapide

**Pour vos amis développeurs - 5 minutes pour commencer !**

---

## ⚡ Installation Express (Mode Simple - CSV)

### Étape 1: Cloner et Installer (2 min)

```bash
# 1. Télécharger le projet
git clone <url-du-repo>
cd EduPath-MS

# 2. Installer Python si nécessaire
python --version  # Doit être 3.8+

# 3. Installer les dépendances minimales
pip install pandas numpy matplotlib seaborn scikit-learn xgboost
```

### Étape 2: Préparer vos Données (1 min)

Placez vos fichiers CSV dans `data/raw/`:

**Format attendu**:
```csv
ID,Subject,Practical,Theoretical,Total,Status,Semester,Major,MajorYear
101,Math,40,35,75,Success,1,CS,1
101,Physics,25,20,45,Fail,1,CS,1
```

### Étape 3: Exécuter (30 sec)

```bash
python run_pipeline.py
```

✅ **C'est tout !** Les résultats sont dans `outputs/`

---

## 🚀 Pour les Recommandations (RecoBuilder)

### Ajouter OpenAI (optionnel)

```bash
# 1. Installer dépendances supplémentaires
pip install openai faiss-cpu python-dotenv

# 2. Créer fichier .env
echo "OPENAI_API_KEY=sk-votre-cle" > .env

# 3. Exécuter
python demo_recobuilder.py
```

---

## 💡 Cas d'Usage Réels

### Cas 1: Identifier les étudiants à risque

```bash
python run_pipeline.py
```

Résultat dans `outputs/`:
- `student_profiles.csv` → Voir colonne `Cluster`
  - Cluster 0 = Décrocheurs 🔴
  - Cluster 1 = En difficulté 🟠
  - Cluster 2 = Moyens 🟡
  - Cluster 3 = Excellents 🟢

### Cas 2: Prédire les échecs

Le modèle XGBoost prédit pour chaque étudiant:
- Probabilité d'échec
- Matières à risque

Voir `confusion_matrix.png` et `feature_importance.png`

### Cas 3: Recommandations personnalisées

```bash
python demo_recobuilder.py
```

Résultat dans `outputs/recommendations.csv`:
- Ressources adaptées par matière
- Plan d'étude personnalisé
- Besoin de tutorat (oui/non)

---

## 📦 Structure Minimale Requise

Si vous voulez **seulement** certains microservices:

### Seulement PrepaData + StudentProfiler

```python
from src.pipeline import PrepaData, StudentProfiler
import pandas as pd

df = pd.read_csv('mes_donnees.csv')
preparer = PrepaData(df)
df_clean = preparer.run_all()

profiler = StudentProfiler(df_clean)
profiles = profiler.run_all(n_clusters=4)

# Résultat dans profiles
```

### Seulement PathPredictor

```python
from src.pipeline import PrepaData, PathPredictor
import pandas as pd

df = pd.read_csv('mes_donnees.csv')
preparer = PrepaData(df)
df_clean = preparer.run_all()

predictor = PathPredictor(df_clean)
model = predictor.run_all()

# Modèle dans outputs/models/xgboost_model.pkl
```

---

## 🔌 Intégration à Votre Plateforme

### Option 1: API REST (Recommandé)

Créez `api.py`:

```python
from flask import Flask, jsonify
from src.recobuilder import RecoBuilder
import pandas as pd

app = Flask(__name__)

@app.route('/api/recommendations/<int:student_id>')
def get_recommendations(student_id):
    # Charger données
    df_clean = pd.read_csv('data/processed/data_cleaned.csv')
    df_profiles = pd.read_csv('data/processed/student_profiles.csv')
    
    # Générer recommandations
    recommender = RecoBuilder()
    recommender.load_resources('data/resources/educational_resources.json')
    recommender.build_faiss_index()
    
    profile = recommender.analyze_student_profile(student_id, df_clean, df_profiles)
    reco = recommender.generate_recommendations(profile)
    
    return jsonify(reco)

if __name__ == '__main__':
    app.run(port=5001)
```

Démarrer:
```bash
pip install flask
python api.py
```

Tester:
```bash
curl http://localhost:5001/api/recommendations/12345
```

### Option 2: Export CSV

```python
# Les résultats sont déjà en CSV
outputs/recommendations.csv  # Importez dans votre LMS
```

---

## 🎯 Configuration pour Votre Système

### Adapter les Seuils

Dans `src/config.py`:

```python
# Seuil de note minimale (10/20 par défaut)
DEFAULT_FAIL_THRESHOLD = 10  # Changer à 50/100 si système sur 100

# Nombre de profils différents
DEFAULT_N_CLUSTERS = 4  # 3 à 6 recommandé
```

### Ajouter Vos Ressources

Dans `data/resources/educational_resources.json`:

```json
{
  "resources": [
    {
      "resource_id": "mon_cours_001",
      "title": "Cours de Mathématiques - Niveau 1",
      "subject": "Mathématiques",
      "type": "video",
      "difficulty": "facile",
      "description": "Introduction aux mathématiques",
      "url": "https://mon-lms.com/cours/math1",
      "duration_min": 45,
      "tags": ["débutant", "mathématiques", "algèbre"]
    }
  ]
}
```

---

## 🆘 Dépannage Rapide

### Erreur: "No module named 'src'"

```bash
# Mauvais dossier
cd EduPath-MS  # Assurez-vous d'être à la racine
```

### Erreur: "FileNotFoundError"

```bash
# Créer les dossiers manquants
mkdir -p data/raw data/processed outputs/figures outputs/models
```

### Erreur: "KeyError: 'ID'"

```bash
# Vos données n'ont pas la colonne ID
# Renommez votre colonne d'identifiant étudiant en 'ID'
```

### Performance lente

```bash
# Limitez le nombre d'étudiants pour tester
df = df.head(100)  # Seulement 100 premiers
```

---

## 📊 Résultats Attendus

Après exécution de `python run_pipeline.py`:

```
outputs/
├── figures/
│   ├── elbow_method.png           # Courbe du coude K-Means
│   ├── student_clusters.png       # Visualisation PCA
│   ├── confusion_matrix.png       # Performance modèle
│   └── feature_importance.png     # Variables importantes
├── models/
│   └── xgboost_model.pkl         # Modèle prédictif
└── recommendations.csv            # Recommandations (si RecoBuilder)

data/processed/
├── data_cleaned.csv               # Données nettoyées
└── student_profiles.csv           # Profils avec clusters
```

---

## 🎓 Support et Questions

### Documentation Complète

- `README.md` - Vue d'ensemble
- `docs/IMPLEMENTATION_GUIDE.md` - Guide développeur
- `docs/ARCHITECTURE.md` - Architecture technique
- `docs/INFRASTRUCTURE_SETUP.md` - Setup avancé

### Besoin d'aide ?

1. Vérifiez la documentation
2. Regardez les exemples dans `demo_*.py`
3. Contactez le mainteneur

---

## ✅ Checklist pour Commencer

- [ ] Python 3.8+ installé
- [ ] Dépendances installées (`pip install ...`)
- [ ] Données CSV dans `data/raw/`
- [ ] Colonnes requises présentes (ID, Subject, Total, etc.)
- [ ] Exécuté `python run_pipeline.py`
- [ ] Résultats dans `outputs/`

---

**Temps total: ~5 minutes** ⏱️

**Bonne implémentation ! 🚀**
