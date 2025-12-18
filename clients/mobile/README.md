# Mobile Flutter App

A professional Flutter application built with clean architecture principles and modern best practices.

## 🏗️ Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration & DI
│   ├── constants/          # App constants, colors, strings
│   ├── network/            # API client, interceptors
│   ├── theme/              # Theme configuration
│   └── utils/              # Utilities, extensions, logger
├── data/                    # Data layer
│   ├── datasources/        # Remote & local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/           # Domain entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
├── presentation/            # Presentation layer
│   ├── controllers/        # GetX controllers
│   ├── screens/            # App screens
│   ├── routes/             # App routing
│   └── widgets/            # Reusable widgets
├── shared/                  # Shared resources
│   ├── models/             # Shared models
│   ├── services/           # Shared services
│   └── widgets/            # Shared widgets
└── assets/                  # Assets
    ├── images/             # Images
    └── fonts/              # Custom fonts
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation (if needed):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 📦 Key Dependencies

- **GetX**: State management, navigation, and dependency injection
- **Dio**: HTTP client for API calls
- **GetStorage**: Lightweight local storage
- **GetIt**: Dependency injection
- **Flutter Animate**: Beautiful animations
- **Cached Network Image**: Efficient image loading

## 🎨 Features

- ✅ Clean Architecture (Data-Domain-Presentation)
- ✅ GetX for state management
- ✅ Professional theme system (Light/Dark mode)
- ✅ API client with interceptors
- ✅ Local storage integration
- ✅ Error handling
- ✅ Logging system
- ✅ Responsive design
- ✅ Modern UI/UX
- ✅ Code generation support

## 🔧 Configuration

### Environment Setup

Configure environments in `main.dart`:

```dart
flutter run --dart-define=ENV=development
flutter run --dart-define=ENV=staging
flutter run --dart-define=ENV=production
```

### API Configuration

Update `AppConstants` class with your API endpoints:

```dart
static const String baseUrl = 'https://your-api.com';
```

## 📝 Code Style

This project follows Flutter and Dart best practices:

- Use meaningful variable names
- Follow SOLID principles
- Write clean, maintainable code
- Add comments for complex logic
- Keep widgets small and reusable

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Development

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
