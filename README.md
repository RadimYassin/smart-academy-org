# 🎓 Smart Academy Platform

Le projet **Smart Academy Platform** vise à fournir une solution **modulaire, scalable et intelligente** pour le suivi pédagogique, la prédiction de réussite et la recommandation personnalisée de ressources d'apprentissage pour les étudiants.

Il répond aux défis de la fragmentation des données entre les plateformes d'apprentissage (LMS), de la détection tardive des étudiants à risque, et du manque de recommandations personnalisées.

---

## ✨ Objectifs du Projet

Les principaux objectifs de cette plateforme sont de:

* **Centraliser** les données pédagogiques issues des LMS[cite: 24].
* Fournir des **prédictions de risque d'échec** et des **recommandations personnalisées**.
* Offrir une **interface claire** pour les enseignants et un **coach mobile** pour les étudiants.
* Concevoir une **architecture évolutive et maintenable**.

---

## 🏗 Architecture Technique

L'architecture est organisée en couches (Frontend, Mobile, Gateway, Microservices, Data) et utilise une approche microservices pour garantir l'évolutivité[cite: 49].

### Vue d'ensemble (Couches Logiques)

| Couche | Technologies Clés | Rôle |
| :--- | :--- | :--- |
| **Frontend** | React, Next.js, TailwindCSS  | Tableau de bord pour les enseignants. |
| **Mobile** | Flutter, Firebase (FCM)  | Application coach mobile pour les étudiants. |
| **Microservices** | NestJS, **Spring Boot**, FastAPI | Logique métier, API Gateway, services d'IA. |
| **Data/IA** | Airflow, MLflow, XGBoost | ETL robuste, entraînement, versionnement et déploiement des modèles de prédiction et de recommandation. |
| **Bases de données** | PostgreSQL, MongoDB, Redis  | Stockage transactionnel, documentaire et cache. |

### Microservices Principaux (Chapitre 4)

| Module | Responsabilités Clés |
| :--- | :--- |
| **Auth Service** | Gestion des comptes, JWT, rafraîchissement de token, RBAC[cite: 78]. |
| **LMS Connector** | Synchronisation via OAuth2, normalisation des logs LMS[cite: 80]. |
| **Prepa-Data** | DAG Airflow pour ingestions, nettoyage, validation (Great Expectations). |
| **Path Predictor** | Entraînement et déploiement des modèles (XGBoost), stockage des versions via MLflow. |

---

## 🛠 Technologies et Choix d'Implémentation

Le projet s'appuie sur une stack technologique moderne et robuste:

* **Backend & API:** **NestJS**, **Spring Boot**, **FastAPI**, **RabbitMQ**
* **Conteneurisation & Orchestration:** **Docker**, **Kubernetes**, **Terraform**
* **Data Science:** **scikit-learn**, **XGBoost**, **Transformers**, **MLflow**
* **Data Pipeline:** **Airflow**, **Pandas**, **MinIO**
* **CI/CD:** **GitHub Actions**, **ArgoCD**

---

## 🔒 Sécurité et Vie Privée

* **Authentification:** Utilisation de **JWT** (JSON Web Tokens) + refresh tokens, stockage des secrets dans un gestionnaire (Vault / KMS).
* **Confidentialité:** Conformité **RGPD** (droit à l’oubli, consentement), minimisation des données personnelles, et anonymisation des exports.

---

