# 🚀 Guide d'Installation Pas-à-Pas - Infrastructure Complète

## Checklist d'Installation

### Phase 1: Préparation
- [ ] Docker Desktop installé
- [ ] Docker Desktop démarré (icône verte)
- [ ] Dépendances Python installées

### Phase 2: Démarrage Services
- [ ] docker-compose up -d exécuté
- [ ] Services PostgreSQL, MLflow, Airflow en running
- [ ] Ports 5432, 5000, 8080 accessibles

### Phase 3: Configuration
- [ ] Base de données initialisée
- [ ] Fichier .env créé et configuré
- [ ] Clé OpenAI ajoutée

### Phase 4: Vérification
- [ ] Test infrastructure réussi
- [ ] Pipeline exécuté avec succès
- [ ] MLflow UI accessible
- [ ] Airflow UI accessible

---

## Commandes à Exécuter (dans l'ordre)

### 1. Installer les dépendances
```bash
cd c:\Users\PC\Desktop\anti
pip install -r requirements.txt
```
⏱️ Temps: 5-10 minutes

### 2. Démarrer Docker
```bash
docker-compose up -d
```
⏱️ Temps: 2-3 minutes (premier démarrage peut prendre plus)

### 3. Vérifier les services
```bash
docker-compose ps
```
✅ Devrait afficher 3 conteneurs "Up"

### 4. Initialiser la base de données
```bash
python scripts\init_db.py
```
✅ Devrait afficher "Base de données initialisée avec succès!"

### 5. Configurer .env
```bash
copy .env.example .env
notepad .env
```
Modifier:
- `USE_DATABASE=true`
- `OPENAI_API_KEY=sk-...`

### 6. Tester
```bash
python test_infrastructure.py
```

### 7. Exécuter le pipeline
```bash
python run_pipeline.py
```

---

## Interfaces Web

Une fois tout démarré:

- **MLflow**: http://localhost:5000
- **Airflow**: http://localhost:8080 (admin/admin)
- **PostgreSQL**: localhost:5432 (via client SQL)

---

## En cas d'erreur

### Docker n'est pas reconnu
➡️ Installer Docker Desktop: https://www.docker.com/products/docker-desktop

### Port déjà utilisé
```bash
# Vérifier les ports utilisés
netstat -ano | findstr :5432
netstat -ano | findstr :5000
netstat -ano | findstr :8080
```

### Services ne démarrent pas
```bash
# Voir les logs
docker-compose logs postgres
docker-compose logs mlflow
docker-compose logs airflow
```

### Réinitialiser tout
```bash
docker-compose down -v
docker-compose up -d
python scripts\init_db.py
```

---

**Notes**: Gardez ce fichier ouvert et cochez au fur et à mesure ! ✅
