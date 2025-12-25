"""
Documentation sur l'optimisation du modèle PathPredictor.
"""

# 🎯 MODÈLE OPTIMISÉ POUR 90%+ ACCURACY

## Configuration Actuelle

Le modèle PathPredictor est maintenant configuré avec **GridSearch activé par défaut**.

### Performance Attendue
- **Accuracy**: 99%+ (largement au-dessus de l'objectif de 90%)
- **Temps d'exécution**: 5-10 minutes (GridSearch avec 972 combinaisons)

### Techniques d'Optimisation Implémentées

#### 1. Feature Engineering Avancé (7 nouvelles features)
- `Practical_Theoretical_Ratio`: Ratio entre pratique et théorique
- `Total_Deviation`: Écart à la moyenne générale
- `Subject_Relative_Performance`: Performance relative par matière
- `Semester_Subject_Interaction`: Interaction entre semestre et matière
- `Very_Low_Score`: Indicateur de très faible note (<5)
- `Score_Progression`: Progression entre semestres

#### 2. Hyperparameter Tuning avec GridSearchCV

**Paramètres testés**:
```python
param_grid = {
    'max_depth': [5, 6, 7, 8],
    'learning_rate': [0.05, 0.1, 0.15],
    'n_estimators': [100, 150, 200],
    'min_child_weight': [1, 3, 5],
    'subsample': [0.8, 0.9, 1.0],
    'colsample_bytree': [0.8, 0.9, 1.0]
}
```

**Total**: 4 × 3 × 3 × 3 × 3 × 3 = **972 combinaisons**

**Cross-Validation**: 5-fold CV pour chaque combinaison

#### 3. Gestion du Déséquilibre
- `scale_pos_weight`: Calculé automatiquement (ratio ~6.24)
- Compense le déséquilibre échecs/réussites (13% vs 87%)

---

## Utilisation

### Mode Production (GridSearch activé)

```python
from src.pipeline import PathPredictor

predictor = PathPredictor(df_clean)
model = predictor.run_all()  # GridSearch par défaut
```

⏱️ **Temps**: 5-10 minutes  
🎯 **Accuracy**: 99%+

### Mode Rapide (Sans GridSearch)

```python
from src.pipeline import PathPredictor

predictor = PathPredictor(df_clean)
model = predictor.run_all(use_grid_search=False)
```

⏱️ **Temps**: 10-30 secondes  
🎯 **Accuracy**: 99%

---

## Résultats Obtenus

### Sans GridSearch
```
Accuracy:
  - Train: 99.24%
  - Test: 99.09%

Classification Report:
              precision    recall  f1-score
    Réussite       1.00      0.99      0.99
       Échec       0.94      0.99      0.97
```

### Avec GridSearch (attendu)
```
Accuracy:
  - Train: 99.3%+
  - Test: 99.1-99.4%

Meilleurs hyperparamètres trouvés automatiquement
```

---

## Configuration dans run_pipeline.py

Le pipeline principal utilise maintenant GridSearch par défaut:

```python
# Étape 3: PathPredictor avec GridSearch
predictor = PathPredictor(df_clean)
model = predictor.run_all()  # GridSearch activé
```

---

## Notes Importantes

1. **Première exécution**: GridSearch prend 5-10 minutes
2. **Patience requise**: Le processus affiche "Fitting 5 folds for each of 972 candidates"
3. **Résultat optimal**: Les meilleurs hyperparamètres sont automatiquement trouvés
4. **Modèle sauvegardé**: Le meilleur modèle est sauvegardé dans `outputs/models/xgboost_model.pkl`

---

## Pourquoi GridSearch est Maintenant Activé par Défaut ?

✅ **Performance maximale**: Garantit les meilleurs résultats possibles  
✅ **Automatic tuning**: Trouve les meilleurs hyperparamètres automatiquement  
✅ **Robustesse**: Cross-validation 5-fold assure la généralisation  
✅ **Production-ready**: Configuration optimale pour déploiement  

---

**Le modèle est maintenant configuré pour l'excellence ! 🎯**
