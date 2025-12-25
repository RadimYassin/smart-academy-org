# Smart Academy - Documentation Architecture

Ce dossier contient la documentation complète de l'architecture du système Smart Academy.

## 📚 Documents Disponibles

### 1. [Smart Academy Architecture](./smart_academy_architecture.md)
**Type**: Documentation Technique Détaillée  
**Contenu**:
- Architecture globale du système
- Design détaillé de 9 modules (LMSConnector, PrepaData, StudentProfiler, PathPredictor, RecoBuilder, TeacherConsole, StudentCoach, User-Management, Course-Management)
- Schémas de bases de données
- API endpoints avec exemples request/response
- Flux d'authentification JWT
- Configuration de sécurité & RBAC
- Architecture de déploiement
- Configuration d'environnement

**Public cible**: Architectes, développeurs backend/frontend, DevOps

---

### 2. [Smart Academy Global View](./smart_academy_global_view.md)
**Type**: Vue d'Ensemble Visuelle (Diagrammes Mermaid)  
**Contenu**:
- **10+ diagrammes interactifs** de haute qualité
- Architecture système complète avec toutes les couches
- Flux de données AI (Moodle → LMSConnector → PrepaData → Profiler → Predictor → RecoBuilder)
- Séquence d'authentification JWT
- Architecture RabbitMQ (publishers, exchanges, queues, consumers)
- ERD des 3 bases de données (User DB, Course DB, LMS DB)
- Architecture de déploiement Docker/Kubernetes
- Diagrammes des couches frontend (React + Flutter)
- Pipeline AI & Analytics

**Public cible**: Tous (présentation visuelle), Product Owners, Chefs de projet

---

## 🎯 Utilisation Recommandée

### Pour les Nouveaux Développeurs
1. Commencez par **Global View** pour comprendre l'architecture visuelle
2. Plongez dans **Architecture** pour les détails d'implémentation de votre module

### Pour les Product Owners / Non-Techniques
- Utilisez **Global View** - les diagrammes Mermaid sont interactifs et auto-explicatifs

### Pour les Architectes / Lead Developers
- **Architecture**: Reference complète pour les décisions techniques
- **Global View**: Diagrammes à inclure dans les présentations

---

## 🔄 Mise à Jour

Ces documents doivent être mis à jour lorsque:
- Nouveaux services sont ajoutés
- Architecture de base de données change
- Nouvelles intégrations externes
- Changements de stack technologique

---

## 📊 Diagrammes Disponibles (Global View)

| Diagramme | Description |
|-----------|-------------|
| **Architecture Système** | Vue d'ensemble complète avec tous les services |
| **Couche Client** | React (Teacher Console) + Flutter (Student Coach) |
| **Couche Backend** | Architecture 3-tiers Spring Boot + NestJS |
| **Pipeline AI** | Flux de données pour les services IA |
| **Flux JWT** | Séquence d'authentification complète |
| **RabbitMQ** | Publishers, Exchanges, Queues & Consumers |
| **ERD User DB** | Structure de la base User Management |
| **ERD Course DB** | Structure de la base Course Management |
| **ERD LMS DB** | Structure de la base LMS Connector |
| **Deployment** | Architecture Docker/Kubernetes avec load balancing |

---

## 🛠️ Technologies Documentées

- **Backend**: Spring Boot 3.2.5, NestJS 11, FastAPI
- **Frontend**: React 18, Flutter 3
- **Databases**: PostgreSQL 15
- **Infrastructure**: MinIO, RabbitMQ, Eureka, Docker
- **AI/ML**: Scikit-learn, XGBoost, BERT, Transformers, MLflow

---

**Dernière mise à jour**: 24 Décembre 2025  
**Mainteneur**: Architecture Team  
**Version**: 1.0
