# 🎓 Smart Academy Platform

[cite_start]Le projet **Smart Academy Platform** vise à fournir une solution **modulaire, scalable et intelligente** pour le suivi pédagogique, la prédiction de réussite et la recommandation personnalisée de ressources d'apprentissage pour les étudiants[cite: 18].

[cite_start]Il répond aux défis de la fragmentation des données entre les plateformes d'apprentissage (LMS), de la détection tardive des étudiants à risque, et du manque de recommandations personnalisées[cite: 29].

---

## ✨ Objectifs du Projet

Les principaux objectifs de cette plateforme sont de:

* [cite_start]**Centraliser** les données pédagogiques issues des LMS[cite: 24].
* [cite_start]Fournir des **prédictions de risque d'échec** et des **recommandations personnalisées**[cite: 25].
* [cite_start]Offrir une **interface claire** pour les enseignants et un **coach mobile** pour les étudiants[cite: 26].
* [cite_start]Concevoir une **architecture évolutive et maintenable**[cite: 27].

---

## 🏗 Architecture Technique

[cite_start]L'architecture est organisée en couches (Frontend, Mobile, Gateway, Microservices, Data) et utilise une approche microservices pour garantir l'évolutivité[cite: 49].

### Vue d'ensemble (Couches Logiques)

| Couche | Technologies Clés | Rôle |
| :--- | :--- | :--- |
| **Frontend** | [cite_start]React, Next.js, TailwindCSS  | Tableau de bord pour les enseignants. |
| **Mobile** | [cite_start]Flutter, Firebase (FCM)  | Application coach mobile pour les étudiants. |
| **Microservices** | NestJS, **Spring Boot**, FastAPI | Logique métier, API Gateway, services d'IA. |
| **Data/IA** | Airflow, MLflow, XGBoost | ETL robuste, entraînement, versionnement et déploiement des modèles de prédiction et de recommandation. |
| **Bases de données** | [cite_start]PostgreSQL, MongoDB, Redis  | Stockage transactionnel, documentaire et cache. |

### Microservices Principaux (Chapitre 4)

| Module | Responsabilités Clés |
| :--- | :--- |
| **Auth Service** | [cite_start]Gestion des comptes, JWT, rafraîchissement de token, RBAC[cite: 78]. |
| **LMS Connector** | [cite_start]Synchronisation via OAuth2, normalisation des logs LMS[cite: 80]. |
| **Prepa-Data** | [cite_start]DAG Airflow pour ingestions, nettoyage, validation (Great Expectations)[cite: 82]. |
| **Path Predictor** | [cite_start]Entraînement et déploiement des modèles (XGBoost), stockage des versions via MLflow[cite: 84, 85]. |

---

## 🛠 Technologies et Choix d'Implémentation

[cite_start]Le projet s'appuie sur une stack technologique moderne et robuste:

* **Backend & API:** **NestJS**, **Spring Boot**, **FastAPI**, **RabbitMQ**
* **Conteneurisation & Orchestration:** **Docker**, **Kubernetes**, **Terraform**
* **Data Science:** **scikit-learn**, **XGBoost**, **Transformers**, **MLflow**
* **Data Pipeline:** **Airflow**, **Pandas**, **MinIO**
* **CI/CD:** **GitHub Actions**, **ArgoCD**

---

## 🔒 Sécurité et Vie Privée

* [cite_start]**Authentification:** Utilisation de **JWT** (JSON Web Tokens) + refresh tokens, stockage des secrets dans un gestionnaire (Vault / KMS)[cite: 90].
* [cite_start]**Confidentialité:** Conformité **RGPD** (droit à l’oubli, consentement), minimisation des données personnelles, et anonymisation des exports[cite: 91].

---

Aimeriez-vous que j'ajoute un lien dans ce `README` vers le rapport complet ou un guide de contribution ?
