# Analyse du Projet Flutter - Smart Academy Mobile

## 📱 But Global de l'Application

**Smart Academy** est une application mobile d'apprentissage en ligne (LMS - Learning Management System) qui permet :
- Aux **étudiants** de suivre des cours, passer des quiz, suivre leur progression, et interagir avec un assistant IA
- Aux **enseignants** de créer et gérer des cours, suivre leurs étudiants
- Un système de **crédits** pour récompenser les étudiants (comme une monnaie virtuelle)
- Une **authentification biométrique** (empreinte digitale/Face ID) pour un accès rapide
- Un **chatbot IA** avec support audio et images pour aider les étudiants

---

## 🏗️ Architecture Actuelle

### Architecture en Couches (Clean Architecture)

Le projet suit une **architecture en couches** avec séparation claire des responsabilités :

```
┌─────────────────────────────────────┐
│     PRESENTATION (UI)                │
│  - Screens (écrans)                  │
│  - Controllers (logique UI)          │
│  - Widgets (composants réutilisables) │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     DOMAIN (Logique métier)         │
│  - Repositories (interfaces)        │
│  - Entities (modèles métier)        │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     DATA (Accès aux données)        │
│  - Repositories (implémentations)    │
│  - DataSources (API, local)          │
│  - Models (DTOs)                     │
└─────────────────────────────────────┘
```

### Pattern Utilisé : **Repository Pattern**

Chaque fonctionnalité suit ce pattern :
1. **DataSource** → Appelle l'API (couche réseau)
2. **Repository** → Implémente l'interface du Domain, gère la logique de données
3. **Controller** → Utilise le Repository, gère l'état UI
4. **Screen** → Affiche l'UI, écoute le Controller

---

## 📂 Structure du Dossier `lib/`

```
lib/
├── main.dart                    # Point d'entrée de l'application
│
├── core/                        # Fonctionnalités centrales
│   ├── config/                  # Configuration et injection de dépendances
│   ├── constants/               # Constantes (couleurs, URLs, strings)
│   ├── network/                 # Client API (Dio) et interceptors
│   ├── theme/                   # Thèmes (clair/sombre)
│   └── utils/                   # Utilitaires (logger, JWT, extensions)
│
├── data/                        # Couche d'accès aux données
│   ├── datasources/             # Appels API directs (RemoteDataSource)
│   ├── models/                   # Modèles de données (DTOs)
│   └── repositories/            # Implémentations des repositories
│
├── domain/                      # Couche métier (logique pure)
│   ├── entities/                # Entités métier
│   ├── repositories/            # Interfaces des repositories
│   └── usecases/                # Cas d'usage (vide actuellement)
│
├── presentation/                # Couche présentation (UI)
│   ├── controllers/             # Controllers GetX (logique UI)
│   │   ├── auth/                # Controllers d'authentification
│   │   └── bindings/            # Bindings GetX (injection de dépendances)
│   ├── routes/                  # Configuration des routes
│   ├── screens/                 # Écrans de l'application
│   │   ├── auth/                # Écrans de connexion/inscription
│   │   ├── student/             # Écrans étudiants
│   │   ├── teacher/              # Écrans enseignants
│   │   └── ai_chat/             # Écran du chatbot IA
│   └── widgets/                 # Widgets réutilisables
│
└── shared/                      # Code partagé
    └── services/                # Services partagés
        ├── audio_recording_service.dart
        ├── biometric_service.dart
        ├── secure_storage_service.dart
        ├── speech_to_text_service.dart
        └── token_storage_service.dart
```

### Rôle de Chaque Partie

#### `core/`
- **config/** : Initialise l'injection de dépendances (GetX) et la configuration
- **constants/** : Toutes les constantes (URLs API, clés de stockage, couleurs, textes)
- **network/** : Client HTTP (Dio) avec interceptors pour auth et erreurs
- **theme/** : Définition des thèmes clair/sombre
- **utils/** : Outils (logger, parsing JWT, extensions)

#### `data/`
- **datasources/** : Appels directs à l'API (GET, POST, PUT, DELETE)
- **models/** : Modèles de données (JSON serialization)
- **repositories/** : Implémentations concrètes des repositories

#### `domain/`
- **repositories/** : Interfaces (contrats) que les repositories doivent respecter
- **entities/** : Entités métier (peu utilisées actuellement)

#### `presentation/`
- **controllers/** : Logique UI avec GetX (état, actions)
- **screens/** : Écrans Flutter (UI pure)
- **routes/** : Définition des routes de navigation
- **widgets/** : Composants UI réutilisables

#### `shared/`
- **services/** : Services transversaux (audio, biométrie, stockage sécurisé)

---

## 🎯 Gestion d'État : **GetX**

### GetX est utilisé pour :
1. **État réactif** : Variables observables (`.obs`)
2. **Navigation** : `Get.to()`, `Get.offAllNamed()`, etc.
3. **Injection de dépendances** : `Get.find<T>()`, `Get.put<T>()`
4. **Dialogs/Snackbars** : `Get.snackbar()`, `Get.dialog()`

### Exemple dans un Controller :

```dart
class CoursesController extends GetxController {
  // Variables observables (état réactif)
  final courses = <Course>[].obs;           // Liste observable
  final isLoadingCourses = false.obs;      // Bool observable
  final errorMessage = ''.obs;             // String observable
  
  // Repository injecté via GetX
  late final CourseRepository _courseRepository;
  
  @override
  void onInit() {
    super.onInit();
    // Récupère le repository depuis GetX DI
    _courseRepository = Get.find<CourseRepository>();
    loadCourses();
  }
  
  Future<void> loadCourses() async {
    isLoadingCourses.value = true;  // Met à jour l'état
    try {
      final loadedCourses = await _courseRepository.getAllCourses();
      courses.value = loadedCourses;  // Met à jour la liste
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingCourses.value = false;
    }
  }
}
```

### Dans l'UI (Screen) :

```dart
// Écoute les changements d'état
Obx(() {
  if (controller.isLoadingCourses.value) {
    return LoadingIndicator();
  }
  return ListView.builder(
    itemCount: controller.courses.length,
    itemBuilder: (context, index) => CourseCard(controller.courses[index]),
  );
})
```

---

## 🚀 Point d'Entrée : `main.dart`

### Cycle de Vie de l'App

1. **`main()`** est appelé au démarrage
2. **Initialisation** :
   - `WidgetsFlutterBinding.ensureInitialized()` → Initialise Flutter
   - `DependencyInjection.init()` → Configure GetX et enregistre toutes les dépendances
   - `AppConfig.initialize()` → Configure l'environnement (dev/prod)
3. **`runApp(MyApp())`** → Lance l'application
4. **`GetMaterialApp`** → Widget racine avec GetX
   - `initialRoute: AppRoutes.splash` → Commence par l'écran Splash
   - `getPages: AppRoutes.routes` → Liste de toutes les routes

### Flux de Navigation Initial

```
main.dart
  ↓
MyApp (GetMaterialApp)
  ↓
SplashScreen (écran initial)
  ↓
  ├─ Si connecté → Dashboard (selon rôle)
  └─ Si non connecté → Onboarding → Welcome → SignIn/SignUp
```

---

## 🧭 Navigation Entre les Écrans

### Système de Navigation : **GetX Navigation**

Toutes les routes sont définies dans `app_routes.dart` :

```dart
// Définition d'une route
GetPage(
  name: AppRoutes.signin,
  page: () => const SignInScreen(),
  binding: SignInBinding(),  // Injecte le controller
)
```

### Méthodes de Navigation Utilisées

1. **`Get.toNamed('/route')`** → Navigue vers un nouvel écran (empile)
2. **`Get.offNamed('/route')`** → Remplace l'écran actuel
3. **`Get.offAllNamed('/route')`** → Remplace toute la pile de navigation
4. **`Get.back()`** → Retour en arrière
5. **`Get.to(() => Screen())`** → Navigation directe sans route nommée

### Exemple de Navigation avec Paramètres

```dart
// Navigation avec paramètres
Get.toNamed(
  AppRoutes.lessonLearning,
  arguments: {
    'courseId': courseId,
    'moduleId': moduleId,
    'contentIndex': 0,
  },
);

// Dans l'écran de destination
final args = Get.arguments as Map<String, dynamic>? ?? {};
final courseId = args['courseId'] ?? '';
```

---

## 💼 Logique Métier Principale

### Flux de Données Typique

```
UI (Screen)
  ↓ Appelle une action
Controller (GetX)
  ↓ Utilise
Repository (Interface)
  ↓ Implémenté par
RepositoryImpl
  ↓ Utilise
RemoteDataSource
  ↓ Appelle
ApiClient (Dio)
  ↓ Fait requête HTTP
Backend API
  ↓ Retourne réponse
ApiClient
  ↓ Parse JSON
RemoteDataSource
  ↓ Retourne Model
RepositoryImpl
  ↓ Retourne Model
Controller
  ↓ Met à jour l'état (.obs)
UI (Obx)
  ↓ Se met à jour automatiquement
```

### Exemple Concret : Charger les Cours

1. **Screen** : L'utilisateur ouvre l'écran "Explore"
2. **Controller** : `CoursesController.loadCourses()` est appelé
3. **Repository** : `_courseRepository.getAllCourses()`
4. **RepositoryImpl** : Appelle `_remoteDataSource.getAllCourses()`
5. **DataSource** : Fait `GET /course-service/api/courses` via `ApiClient`
6. **ApiClient** : Envoie la requête HTTP avec le token JWT (via `AuthInterceptor`)
7. **Backend** : Retourne la liste des cours en JSON
8. **DataSource** : Parse le JSON → `List<Course>`
9. **Repository** : Retourne la liste
10. **Controller** : `courses.value = loadedCourses` (met à jour l'état)
11. **UI** : `Obx()` détecte le changement et reconstruit la liste

---

## 🌐 Connexion aux APIs

### Configuration API

**Base URL** : `http://192.168.11.131:8888` (API Gateway)

**Services** :
- `/user-management-service` → Gestion utilisateurs, auth, crédits
- `/course-service` → Cours, leçons, quiz
- `/chatbot-edu-service` → Chatbot IA avec Whisper et Vision API
- `/lmsconnector` → Connecteur LMS

### Client API : `ApiClient`

Utilise **Dio** comme client HTTP :

```dart
ApiClient()
  ├─ BaseOptions (URL, timeout, headers)
  └─ Interceptors
      ├─ AuthInterceptor → Ajoute le token JWT automatiquement
      ├─ ErrorInterceptor → Log les erreurs
      └─ PrettyDioLogger → Log les requêtes (dev uniquement)
```

### Interceptors

#### `AuthInterceptor`
- **`onRequest`** : Ajoute `Authorization: Bearer <token>` à chaque requête
- **`onError`** : Si 401 (token expiré), tente de rafraîchir le token automatiquement

#### `ErrorInterceptor`
- Log toutes les erreurs réseau
- Catégorise les erreurs (timeout, bad response, etc.)

### Gestion des Erreurs

Les erreurs sont gérées à plusieurs niveaux :

1. **DataSource** : Capture `DioException`, extrait le message d'erreur
2. **Repository** : Log l'erreur, la propage
3. **Controller** : Capture l'erreur, met à jour `errorMessage.value`
4. **UI** : Affiche l'erreur via `Get.snackbar()` ou dans l'UI

```dart
// Exemple dans un DataSource
try {
  final response = await _apiClient.post(endpoint, data: data);
  return Model.fromJson(response.data);
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    throw Exception('Invalid credentials');
  } else if (e.response?.statusCode == 404) {
    throw Exception('Not found');
  } else {
    throw Exception(e.response?.data?['message'] ?? 'Error');
  }
}
```

---

## ⏳ Gestion du Loading

Le loading est géré via des variables observables dans les Controllers :

```dart
// Dans le Controller
final isLoading = false.obs;

Future<void> loadData() async {
  isLoading.value = true;  // Démarre le loading
  try {
    // Chargement des données
  } finally {
    isLoading.value = false;  // Arrête le loading
  }
}

// Dans l'UI
Obx(() {
  if (controller.isLoading.value) {
    return LoadingIndicator();
  }
  return DataWidget();
})
```

### Widget de Loading

Un widget réutilisable `LoadingIndicator` est disponible dans `presentation/widgets/`.

---

## 🔐 Authentification

### Flux d'Authentification

1. **Connexion** :
   - L'utilisateur saisit email/password
   - `SignInController.signIn()` appelle `AuthRepository.login()`
   - Le backend retourne `accessToken` et `refreshToken`
   - Les tokens sont sauvegardés dans `GetStorage` (local)
   - L'utilisateur est redirigé selon son rôle

2. **Stockage des Tokens** :
   - `TokenStorageService` gère le stockage sécurisé
   - Tokens sauvegardés dans `GetStorage` avec vérification

3. **Utilisation des Tokens** :
   - `AuthInterceptor` ajoute automatiquement le token à chaque requête
   - Format : `Authorization: Bearer <accessToken>`

4. **Rafraîchissement Automatique** :
   - Si une requête retourne 401 (token expiré)
   - `AuthInterceptor` utilise le `refreshToken` pour obtenir un nouveau `accessToken`
   - La requête originale est réessayée avec le nouveau token

5. **Déconnexion** :
   - `AuthRepository.logout()` efface tous les tokens et données utilisateur

### Authentification Biométrique

- **Service** : `BiometricService` (utilise `local_auth`)
- **Stockage** : `SecureStorageService` (utilise `flutter_secure_storage`)
- **Flux** :
  1. L'utilisateur active la biométrie dans les paramètres
  2. Les identifiants sont sauvegardés de manière sécurisée
  3. Au prochain démarrage, si la biométrie est activée, une authentification automatique est tentée
  4. Si réussie, connexion automatique avec les identifiants sauvegardés

### Vérification de Session

Le `SplashScreen` vérifie si l'utilisateur est connecté :
- Lit `isLoggedInKey` depuis `GetStorage`
- Si connecté, redirige vers le dashboard approprié (Student/Teacher)
- Sinon, redirige vers l'onboarding

---

## 📊 Résumé du Fonctionnement Global

### Démarrage de l'App

1. **Initialisation** (`main.dart`)
   - Configure GetX et l'injection de dépendances
   - Enregistre tous les repositories, datasources, services
   - Lance l'app avec `GetMaterialApp`

2. **Splash Screen**
   - Affiche le logo pendant 3 secondes
   - Vérifie si l'utilisateur est connecté
   - Redirige vers le bon écran

3. **Navigation Initiale**
   - Si connecté → Dashboard (Student ou Teacher)
   - Si non connecté → Onboarding → Welcome → SignIn

### Flux Utilisateur Typique (Étudiant)

1. **Connexion** → SignIn → Vérification biométrique (si activée)
2. **Home** → Liste des cours suivis
3. **Explore** → Découvrir de nouveaux cours
4. **AI Chat** → Poser des questions (texte, audio, image)
5. **Profile** → Voir les statistiques, crédits, paramètres

### Flux Utilisateur Typique (Enseignant)

1. **Connexion** → SignIn
2. **Dashboard** → Vue d'ensemble des cours créés
3. **Courses** → Gérer les cours (créer, modifier, supprimer)
4. **Students** → Voir et gérer les étudiants

### Gestion des Données

- **API Calls** : Toutes les données viennent du backend via API REST
- **Caching** : Pas de cache persistant actuellement (toujours appel API)
- **État Local** : Tokens et préférences utilisateur dans `GetStorage`
- **État Réactif** : GetX observables pour mettre à jour l'UI automatiquement

### Fonctionnalités Spéciales

1. **Système de Crédits** :
   - Les étudiants gagnent 5 crédits en complétant une leçon
   - Les quiz supplémentaires (après 3 tentatives) coûtent 5 crédits
   - Le solde est affiché dans le profil

2. **Chatbot IA** :
   - Support texte, audio (Whisper), et images (Vision API)
   - Transcription audio en temps réel
   - Lecture vocale de la transcription (TTS)
   - Réponses basées sur les documents de cours (RAG)

3. **Quiz** :
   - Affichage question par question
   - Historique des tentatives
   - Système de paiement pour tentatives supplémentaires

---

## 🔑 Points Clés à Retenir

1. **GetX** est utilisé partout : état, navigation, DI
2. **Architecture en couches** : Presentation → Domain → Data
3. **Repository Pattern** : Abstraction de l'accès aux données
4. **Injection de Dépendances** : GetX DI dans `dependency_injection.dart`
5. **Authentification JWT** : Tokens gérés automatiquement par `AuthInterceptor`
6. **État Réactif** : Variables `.obs` qui mettent à jour l'UI automatiquement
7. **Pas de base de données locale** : Tout vient de l'API
8. **Gestion d'erreurs** : À chaque niveau (DataSource → Repository → Controller → UI)

---

## 📝 Notes Techniques

- **Flutter SDK** : ^3.9.2
- **State Management** : GetX 4.6.6
- **HTTP Client** : Dio 5.7.0
- **Storage** : GetStorage (local), FlutterSecureStorage (données sensibles)
- **Navigation** : GetX Navigation (pas de Navigator classique)
- **Thème** : Support clair/sombre avec `ThemeMode.system`

---

*Cette analyse est basée uniquement sur le code existant du projet.*

