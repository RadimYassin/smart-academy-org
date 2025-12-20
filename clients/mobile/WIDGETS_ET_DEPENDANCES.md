# 📦 Widgets et Dépendances du Projet Smart Academy

## 🎨 Widgets Flutter Utilisés

### Widgets de Base (Material Design)

#### **Scaffold**
- **Description** : Structure principale d'un écran, contient AppBar, Body, BottomNavigationBar
- **Utilisation** : Tous les écrans de l'application
- **Exemple** : `Scaffold(appBar: AppBar(...), body: ...)`

#### **AppBar**
- **Description** : Barre d'application en haut de l'écran
- **Utilisation** : Navigation, titre, actions
- **Exemple** : `AppBar(title: Text('Titre'), actions: [...])`

#### **Container**
- **Description** : Widget de mise en page avec padding, margin, décoration
- **Utilisation** : Partout pour structurer et styliser
- **Exemple** : `Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(...))`

#### **Column**
- **Description** : Organise les widgets verticalement
- **Utilisation** : Layouts verticaux
- **Exemple** : `Column(children: [Widget1, Widget2])`

#### **Row**
- **Description** : Organise les widgets horizontalement
- **Utilisation** : Layouts horizontaux
- **Exemple** : `Row(children: [Widget1, Widget2])`

#### **Text**
- **Description** : Affiche du texte
- **Utilisation** : Partout pour afficher du texte
- **Exemple** : `Text('Hello', style: TextStyle(...))`

#### **Icon**
- **Description** : Affiche une icône Material Design
- **Utilisation** : Boutons, listes, navigation
- **Exemple** : `Icon(Icons.home, color: Colors.blue)`

#### **Image**
- **Description** : Affiche une image (locale, réseau, asset)
- **Utilisation** : Logos, avatars, illustrations
- **Exemple** : `Image.asset('assets/images/logo.png')`

#### **TextField**
- **Description** : Champ de saisie de texte
- **Utilisation** : Formulaires, recherche, chat
- **Exemple** : `TextField(controller: controller, decoration: InputDecoration(...))`

#### **Button (ElevatedButton, TextButton, IconButton)**
- **Description** : Boutons interactifs
- **Utilisation** : Actions utilisateur
- **Exemple** : `ElevatedButton(onPressed: () {}, child: Text('Valider'))`

#### **ListView / ListView.builder**
- **Description** : Liste scrollable d'éléments
- **Utilisation** : Listes de cours, messages, notifications
- **Exemple** : `ListView.builder(itemCount: items.length, itemBuilder: ...)`

#### **Card**
- **Description** : Carte avec ombre et coins arrondis
- **Utilisation** : Affichage de contenu structuré
- **Exemple** : `Card(child: ListTile(...))`

#### **SafeArea**
- **Description** : Évite les zones système (notch, barre de statut)
- **Utilisation** : Tous les écrans
- **Exemple** : `SafeArea(child: ...)`

#### **Expanded / Flexible**
- **Description** : Prend l'espace disponible dans un Row/Column
- **Utilisation** : Layouts flexibles
- **Exemple** : `Expanded(child: ...)`

#### **Padding**
- **Description** : Ajoute de l'espace autour d'un widget
- **Utilisation** : Espacement
- **Exemple** : `Padding(padding: EdgeInsets.all(16), child: ...)`

#### **SizedBox**
- **Description** : Espacement fixe ou widget de taille fixe
- **Utilisation** : Espacement entre widgets
- **Exemple** : `SizedBox(height: 16)`

#### **CircularProgressIndicator / LinearProgressIndicator**
- **Description** : Indicateur de chargement
- **Utilisation** : États de chargement
- **Exemple** : `CircularProgressIndicator()`

#### **Dialog / AlertDialog**
- **Description** : Boîte de dialogue modale
- **Utilisation** : Confirmations, erreurs
- **Exemple** : `AlertDialog(title: Text('Confirmer'), actions: [...])`

#### **BottomSheet**
- **Description** : Panneau qui remonte du bas
- **Utilisation** : Options, menus
- **Exemple** : `Get.bottomSheet(...)`

#### **TabBar / TabBarView**
- **Description** : Navigation par onglets
- **Utilisation** : Écrans avec plusieurs sections
- **Exemple** : `TabBar(tabs: [...])`

#### **GestureDetector / InkWell**
- **Description** : Détecte les gestes (tap, swipe)
- **Utilisation** : Interactions utilisateur
- **Exemple** : `GestureDetector(onTap: () {}, child: ...)`

#### **ClipRRect**
- **Description** : Arrondit les coins d'un widget
- **Utilisation** : Images, cartes
- **Exemple** : `ClipRRect(borderRadius: BorderRadius.circular(12), child: ...)`

#### **Stack**
- **Description** : Superpose des widgets
- **Utilisation** : Overlays, badges
- **Exemple** : `Stack(children: [background, foreground])`

#### **SingleChildScrollView**
- **Description** : Permet le scroll d'un widget unique
- **Utilisation** : Contenu scrollable
- **Exemple** : `SingleChildScrollView(child: Column(...))`

#### **MediaQuery**
- **Description** : Accède aux informations de l'écran
- **Utilisation** : Responsive design
- **Exemple** : `MediaQuery.of(context).size.width`

#### **Theme / ThemeData**
- **Description** : Gère les thèmes (clair/sombre)
- **Utilisation** : Support du mode sombre
- **Exemple** : `Theme.of(context).brightness`

### Widgets GetX

#### **Obx**
- **Description** : Widget réactif qui se reconstruit quand une variable `.obs` change
- **Utilisation** : Partout pour l'état réactif
- **Exemple** : `Obx(() => Text(controller.count.value.toString()))`

#### **GetView<T>**
- **Description** : Widget qui adget réactif qui se reconstruit quand une variable `.obs` changeccède automatiquement au controller GetX
- **Utilisation** : Écrans avec GetX
- **Exemple** : `class MyScreen extends GetView<MyController>`

#### **GetBuilder**
- **Description** : Widget qui se reconstruit manuellement
- **Utilisation** : Mises à jour manuelles
- **Exemple** : `GetBuilder<Controller>(builder: (controller) => ...)`

### Widgets Personnalisés du Projet

#### **LoadingIndicator**
- **Description** : Indicateur de chargement personnalisé
- **Fichier** : `lib/presentation/widgets/loading_indicator.dart`

#### **AppCard**
- **Description** : Carte personnalisée avec style uniforme
- **Fichier** : `lib/presentation/widgets/app_card.dart`

#### **HourglassIcon**
- **Description** : Icône sablier personnalisée
- **Fichier** : `lib/presentation/widgets/hourglass_icon.dart`

#### **OnboardingIllustration**
- **Description** : Illustration pour l'onboarding
- **Fichier** : `lib/presentation/widgets/onboarding_illustration.dart`

### Widgets de Packages Externes

#### **flutter_animate**
- **Description** : Animations fluides
- **Utilisation** : `widget.animate().fadeIn(duration: 300.ms)`

#### **cached_network_image**
- **Description** : Image réseau avec cache
- **Utilisation** : `CachedNetworkImage(imageUrl: '...')`

#### **shimmer**
- **Description** : Effet de chargement shimmer
- **Utilisation** : `Shimmer(...)`

#### **SvgPicture** (flutter_svg)
- **Description** : Affiche des images SVG
- **Utilisation** : `SvgPicture.asset('assets/icon.svg')`

---

## 📚 Dépendances du Projet

### 🎨 UI & Icons

#### **cupertino_icons** `^1.0.8`
- **Description** : Icônes iOS (Cupertino) pour Flutter
- **Utilisation** : Icônes iOS dans l'application

#### **flutter_svg** `^2.0.10+1`
- **Description** : Affiche des images SVG vectorielles
- **Utilisation** : Logos, icônes vectorielles
- **Avantages** : Scalable, léger, net à toutes les tailles

---

### 🎯 State Management

#### **get** `^4.6.6`
- **Description** : Framework complet pour Flutter (state management, navigation, DI)
- **Fonctionnalités** :
  - Gestion d'état réactive (`.obs`)
  - Navigation (`Get.toNamed()`, `Get.offAllNamed()`)
  - Injection de dépendances (`Get.put()`, `Get.find()`)
  - Dialogs/Snackbars (`Get.snackbar()`, `Get.dialog()`)
- **Utilisation** : Partout dans le projet

---

### 🌐 Networking

#### **dio** `^5.7.0`
- **Description** : Client HTTP puissant pour Dart/Flutter
- **Fonctionnalités** :
  - Requêtes HTTP (GET, POST, PUT, DELETE)
  - Interceptors (auth, logging, erreurs)
  - Gestion des timeouts
  - Support des uploads multipart
- **Utilisation** : Toutes les communications avec l'API backend

#### **pretty_dio_logger** `^1.4.0`
- **Description** : Logger élégant pour Dio
- **Fonctionnalités** : Affiche les requêtes/réponses HTTP de manière lisible
- **Utilisation** : Développement uniquement (désactivé en production)

---

### 💾 Local Storage

#### **shared_preferences** `^2.3.2`
- **Description** : Stockage simple de données clé-valeur
- **Utilisation** : Préférences utilisateur, données non sensibles
- **Limitations** : Pas sécurisé pour données sensibles

#### **get_storage** `^2.1.1`
- **Description** : Stockage rapide et léger (alternative à shared_preferences)
- **Avantages** : Plus rapide, moins de code
- **Utilisation** : Stockage de tokens, préférences

---

### 🔧 Dependency Injection

#### **get_it** `^8.0.2`
- **Description** : Service locator pour l'injection de dépendances
- **Note** : Déclaré mais principalement GetX est utilisé pour la DI

#### **injectable** `^2.5.0`
- **Description** : Code generator pour get_it
- **Note** : Déclaré mais non utilisé activement (GetX est préféré)

---

### 🛠️ Utils

#### **equatable** `^2.0.5`
- **Description** : Simplifie la comparaison d'objets
- **Utilisation** : Comparaisons d'égalité dans les modèles

#### **flutter_animate** `^4.5.0`
- **Description** : Bibliothèque d'animations déclaratives
- **Fonctionnalités** :
  - Animations fluides (fadeIn, slide, scale)
  - Syntaxe simple : `widget.animate().fadeIn(duration: 300.ms)`
- **Utilisation** : Animations dans les écrans

#### **shimmer** `^3.0.0`
- **Description** : Effet shimmer (brillance) pour les placeholders
- **Utilisation** : Indicateurs de chargement élégants

#### **cached_network_image** `^3.4.1`
- **Description** : Image réseau avec cache automatique
- **Avantages** :
  - Cache les images téléchargées
  - Placeholder pendant le chargement
  - Gestion d'erreur automatique
- **Utilisation** : Images de cours, avatars

#### **country_picker** `^2.0.27`
- **Description** : Sélecteur de pays avec drapeaux
- **Utilisation** : Sélection de pays dans les formulaires

---

### 📝 Code Generation

#### **json_annotation** `^4.9.0`
- **Description** : Annotations pour la sérialisation JSON
- **Utilisation** : Modèles de données (DTOs)

#### **pinput** `^5.0.2`
- **Description** : Champ de saisie pour codes PIN/OTP
- **Utilisation** : Vérification d'email (code OTP)

---

### 🔐 Biometric Authentication

#### **local_auth** `^2.3.0`
- **Description** : Authentification biométrique (empreinte, Face ID)
- **Fonctionnalités** :
  - Détection de la disponibilité biométrique
  - Authentification avec empreinte/Face ID
  - Support Android et iOS
- **Utilisation** : Connexion rapide avec biométrie

#### **flutter_secure_storage** `^9.2.2`
- **Description** : Stockage sécurisé pour données sensibles
- **Fonctionnalités** :
  - Chiffrement des données
  - Stockage sécurisé des credentials
  - Support Keychain (iOS) et Keystore (Android)
- **Utilisation** : Stockage des identifiants pour biométrie

---

### 🔗 URL Launcher

#### **url_launcher** `^6.3.1`
- **Description** : Ouvre des URLs dans des applications externes
- **Fonctionnalités** :
  - Ouvrir des liens web
  - Ouvrir des PDFs
  - Ouvrir YouTube, etc.
- **Utilisation** : Ouvrir les PDFs et vidéos YouTube dans des apps externes

---

### 🎤 Audio Recording

#### **record** `^5.1.2`
- **Description** : Enregistrement audio
- **Fonctionnalités** :
  - Enregistrer depuis le microphone
  - Formats audio (M4A, WAV, etc.)
  - Contrôle de l'enregistrement (start/stop)
- **Utilisation** : Messages vocaux dans le chatbot IA

#### **path_provider** `^2.1.4`
- **Description** : Accès aux chemins système (temp, documents)
- **Utilisation** : Sauvegarder les fichiers audio temporaires

#### **permission_handler** `^11.3.1`
- **Description** : Gestion des permissions (microphone, caméra, stockage)
- **Fonctionnalités** :
  - Demander des permissions
  - Vérifier le statut des permissions
  - Gérer les permissions Android/iOS
- **Utilisation** : Permissions microphone, caméra, galerie

#### **audioplayers** `^6.1.0`
- **Description** : Lecture de fichiers audio
- **Fonctionnalités** :
  - Lire des fichiers audio locaux
  - Lire des fichiers audio réseau
  - Contrôle (play, pause, stop)
- **Utilisation** : Lecture des messages audio dans le chat

#### **speech_to_text** `^7.0.0`
- **Description** : Reconnaissance vocale (speech-to-text)
- **Fonctionnalités** :
  - Transcription en temps réel
  - Support de plusieurs langues
  - Transcription continue
- **Utilisation** : Transcription en temps réel pendant l'enregistrement audio

#### **flutter_tts** `^4.0.2`
- **Description** : Synthèse vocale (text-to-speech)
- **Fonctionnalités** :
  - Convertir texte en parole
  - Support de plusieurs langues
  - Contrôle de la vitesse, volume, pitch
- **Utilisation** : Lire les réponses de l'IA à voix haute

---

### 📷 Image Picker

#### **image_picker** `^1.0.7`
- **Description** : Sélection d'images depuis la galerie ou la caméra
- **Fonctionnalités** :
  - Prendre une photo avec la caméra
  - Choisir depuis la galerie
  - Compression d'image
- **Utilisation** : Envoyer des images au chatbot IA

---

### 🧪 Dev Dependencies

#### **flutter_test** (SDK)
- **Description** : Framework de test Flutter
- **Utilisation** : Tests unitaires et d'intégration

#### **flutter_lints** `^5.0.0`
- **Description** : Règles de linting pour Flutter
- **Utilisation** : Qualité de code, détection d'erreurs

#### **build_runner** `^2.4.12`
- **Description** : Outil pour générer du code
- **Utilisation** : Génération de code (JSON serialization, etc.)

#### **injectable_generator** `^2.6.2`
- **Description** : Générateur de code pour injectable
- **Note** : Déclaré mais non utilisé activement

#### **json_serializable** `^6.8.0`
- **Description** : Générateur de code pour la sérialisation JSON
- **Utilisation** : Génération automatique de `fromJson` / `toJson`

---

### 🔄 Dependency Overrides

#### **record_linux** `^1.2.1`
- **Description** : Support Linux pour le package `record`
- **Utilisation** : Permet l'enregistrement audio sur Linux (développement)

---

## 📊 Résumé des Catégories

### Par Fonctionnalité

| Catégorie | Dépendances |
|-----------|-------------|
| **State Management** | get |
| **Networking** | dio, pretty_dio_logger |
| **Storage** | shared_preferences, get_storage, flutter_secure_storage |
| **UI/Animations** | flutter_animate, shimmer, cached_network_image, flutter_svg |
| **Audio** | record, audioplayers, speech_to_text, flutter_tts |
| **Images** | image_picker, cached_network_image |
| **Auth** | local_auth, flutter_secure_storage |
| **Permissions** | permission_handler |
| **Navigation** | url_launcher |
| **Code Generation** | json_annotation, json_serializable, build_runner |

### Par Fréquence d'Utilisation

| Très Utilisé | Moyennement Utilisé | Peu Utilisé |
|--------------|---------------------|-------------|
| get, dio, flutter_animate | shared_preferences, get_storage, cached_network_image | get_it, injectable, equatable |

---

## 🎯 Widgets les Plus Utilisés

1. **Scaffold** - Structure de base de tous les écrans
2. **Obx** - Réactivité GetX partout
3. **Container** - Mise en page et styling
4. **Column/Row** - Layouts
5. **Text** - Affichage de texte
6. **ListView.builder** - Listes dynamiques
7. **TextField** - Saisie utilisateur
8. **Button** - Actions utilisateur
9. **Image/CachedNetworkImage** - Affichage d'images
10. **Card** - Conteneurs stylisés

---

*Document généré à partir de l'analyse du code existant du projet Smart Academy Mobile.*

