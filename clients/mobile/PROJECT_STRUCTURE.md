# 📁 Project Structure

## Overview
This Flutter project follows **Clean Architecture** principles with a clear separation of concerns across three main layers.

```
mobile/
├── lib/                          # Main application code
│   ├── main.dart                 # App entry point
│   │
│   ├── core/                     # Core functionality
│   │   ├── config/
│   │   │   ├── app_config.dart           # Environment configuration
│   │   │   └── dependency_injection.dart # DI setup with GetIt
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Color palette
│   │   │   ├── app_constants.dart        # App-wide constants
│   │   │   └── app_strings.dart          # Static strings
│   │   ├── network/
│   │   │   ├── api_client.dart           # HTTP client (Dio)
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart # Auth token injection
│   │   │       └── error_interceptor.dart # Error handling
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Light/Dark themes
│   │   └── utils/
│   │       ├── extensions.dart           # Utility extensions
│   │       └── logger.dart               # Logging utility
│   │
│   ├── data/                     # Data Layer
│   │   ├── datasources/          # Data sources (API, Local)
│   │   ├── models/
│   │   │   └── base_model.dart   # Base model with JSON serialization
│   │   └── repositories/         # Repository implementations
│   │
│   ├── domain/                   # Domain Layer
│   │   ├── entities/
│   │   │   └── base_entity.dart  # Base entity class
│   │   ├── repositories/         # Repository interfaces
│   │   └── usecases/             # Business logic use cases
│   │
│   ├── presentation/             # Presentation Layer
│   │   ├── controllers/
│   │   │   └── onboarding_controller.dart # GetX controller
│   │   ├── routes/
│   │   │   └── app_routes.dart   # Navigation configuration
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_content.dart      # Data model
│   │   │   │   ├── onboarding_pageview.dart     # PageView wrapper
│   │   │   │   └── onboarding_screen.dart       # Individual page
│   │   │   └── splash/
│   │   │       └── splash_screen.dart
│   │   └── widgets/
│   │       ├── app_card.dart                    # Reusable card widget
│   │       ├── certificate_illustration.dart     # CustomPaint cert
│   │       ├── hourglass_icon.dart               # CustomPaint icon
│   │       └── onboarding_illustration.dart      # CustomPaint books
│   │
│   ├── shared/                   # Shared resources
│   │   ├── models/               # Shared models
│   │   ├── services/
│   │   │   └── storage_service.dart      # Storage utility
│   │   └── widgets/              # Shared widgets
│   │
│   ├── assets/                   # Assets
│   │   ├── fonts/                # Custom fonts
│   │   └── images/               # Images & SVG
│   │
│   └── config/                   # Legacy config (not used)
│
├── assets/                       # Root assets folder
│   └── images/
│
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── windows/                      # Windows platform code
├── linux/                        # Linux platform code
├── macos/                        # macOS platform code
│
├── pubspec.yaml                  # Dependencies & configuration
├── pubspec.lock                  # Locked dependency versions
├── analysis_options.yaml         # Linter configuration
├── README.md                     # Project documentation
├── ARCHITECTURE.md               # Architecture guide
└── PROJECT_STRUCTURE.md          # This file

test/                             # Test files
└── widget_test.dart              # Example widget test
```

## 📂 Layer Details

### 1️⃣ Core (`lib/core/`)
Shared functionality across all layers:
- **Config**: Dependency injection, environment settings
- **Constants**: Colors, strings, app-wide constants
- **Network**: API client, interceptors for auth & errors
- **Theme**: Material design themes (light/dark)
- **Utils**: Extensions, logger, helper functions

### 2️⃣ Data Layer (`lib/data/`)
Handles data fetching and persistence:
- **Data Sources**: Remote API and local storage implementations
- **Models**: Data Transfer Objects (DTOs) with JSON serialization
- **Repositories**: Concrete implementations of domain repositories

### 3️⃣ Domain Layer (`lib/domain/`)
Pure business logic, framework-independent:
- **Entities**: Core business objects
- **Repositories**: Interface definitions
- **Use Cases**: Business logic operations

### 4️⃣ Presentation Layer (`lib/presentation/`)
UI and user interactions:
- **Controllers**: GetX state management
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Routes**: Navigation configuration

### 5️⃣ Shared (`lib/shared/`)
Cross-cutting concerns:
- **Models**: Shared data models
- **Services**: Reusable services (storage, analytics)
- **Widgets**: Shared UI components

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `main.dart` | App entry point, theme setup, dependency injection |
| `app_theme.dart` | Light/dark theme configuration |
| `app_colors.dart` | Color palette with onboarding colors |
| `app_routes.dart` | GetX navigation routes |
| `onboarding_controller.dart` | Manages onboarding state & navigation |
| `api_client.dart` | Centralized HTTP client with Dio |
| `dependency_injection.dart` | GetIt DI setup |

## 🎨 Custom Paint Widgets

Custom illustrations using `CustomPainter`:
1. **HourglassIcon**: App logo in splash screen
2. **OnboardingIllustration**: Books & glasses for pages 1 & 3
3. **CertificateIllustration**: Certificate for page 2

All support light/dark modes using theme colors.

## 🚀 State Management

**GetX** for:
- Reactive state management (`.obs` observables)
- Navigation without context
- Dependency injection
- Route management

Example controller:
```dart
class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  late final PageController pageController;
  
  void goToNextPage() { ... }
  void skipOnboarding() { ... }
}
```

## 📦 Dependencies

Core packages:
- **get** (^4.6.6): State management & navigation
- **dio** (^5.7.0): HTTP client
- **get_it** (^8.0.2): Dependency injection
- **flutter_animate** (^4.5.0): Animations
- **get_storage** (^2.1.1): Local storage
- **shared_preferences** (^2.3.2): Persistent storage

## 🔄 Feature Flow

Adding a new feature follows this flow:
1. Define domain entity → `domain/entities/`
2. Create repository interface → `domain/repositories/`
3. Implement use case → `domain/usecases/`
4. Create data model → `data/models/`
5. Implement data source → `data/datasources/`
6. Implement repository → `data/repositories/`
7. Create controller → `presentation/controllers/`
8. Build screen → `presentation/screens/`
9. Add route → `presentation/routes/`
10. Update DI → `core/config/dependency_injection.dart`

## 🌈 Theme System

- **Light Theme**: White backgrounds, dark text
- **Dark Theme**: Primary color backgrounds, light text
- **System Theme**: Follows device settings
- **Dynamic Colors**: Updates automatically on theme change

Theme switching is handled by `ThemeMode.system` in `main.dart`.

## 📊 Current Screens

1. **Splash Screen**: App logo, auto-navigates to onboarding
2. **Onboarding**: 3 animated pages with custom illustrations
3. **Home Screen**: Main app interface with cards

## 🎭 Animations

Using **flutter_animate** for:
- Page entrance animations
- Staggered element animations
- Progress indicators
- Button interactions
- Illustration movements

## 🔒 Best Practices

- ✅ Clean Architecture separation
- ✅ GetX for reactive state
- ✅ CustomPaint for illustrations
- ✅ Theme-aware components
- ✅ Dependency injection
- ✅ Error handling
- ✅ Logging system
- ✅ Code generation support
- ✅ Linting enabled
- ✅ Type safety

---

**Project**: Overskill - Unlock your potential with us!  
**Architecture**: Clean Architecture  
**State Management**: GetX  
**Theme**: Material Design 3 with Light/Dark support  
**Animations**: flutter_animate

