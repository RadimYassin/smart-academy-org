# Architecture Guide

This document describes the architecture and design patterns used in the Mobile Flutter application.

## Overview

The app follows **Clean Architecture** principles with clear separation of concerns across three main layers:

1. **Presentation Layer**: UI components, screens, controllers
2. **Domain Layer**: Business logic, entities, use cases
3. **Data Layer**: Data sources, repositories, models

## Layer Responsibilities

### 📱 Presentation Layer (`lib/presentation/`)

**Purpose**: Handles all UI-related code and user interactions.

**Components**:
- **Screens**: Full-page UI components (e.g., `home_screen.dart`)
- **Widgets**: Reusable UI components (e.g., `app_card.dart`)
- **Controllers**: GetX controllers for state management
- **Routes**: Navigation configuration

**Key Principles**:
- Controllers should be lightweight and delegate business logic to use cases
- Widgets should be stateless when possible
- Use GetX for reactive state management

### 🧠 Domain Layer (`lib/domain/`)

**Purpose**: Contains pure business logic, independent of frameworks.

**Components**:
- **Entities**: Core business objects (e.g., `User`, `Product`)
- **Repositories**: Interface definitions for data operations
- **Use Cases**: Business logic operations

**Key Principles**:
- No dependencies on external packages (except utilities)
- Pure Dart code
- Easily testable

### 💾 Data Layer (`lib/data/`)

**Purpose**: Handles data fetching and persistence.

**Components**:
- **Data Sources**: Remote (API) and local (storage) implementations
- **Models**: Data transfer objects (DTOs)
- **Repositories**: Concrete implementations of domain repositories

**Key Principles**:
- Models extend `BaseModel` for JSON serialization
- Repositories implement domain repository interfaces
- Handle error mapping between data and domain layers

## Core Components

### 🔧 Core Package (`lib/core/`)

Shared functionality used across all layers:

- **Config**: App configuration and environment management
- **Constants**: App-wide constants (colors, strings, etc.)
- **Network**: HTTP client with interceptors
- **Theme**: Material theme configuration
- **Utils**: Utilities, extensions, and logger

### 🤝 Shared Package (`lib/shared/`)

Cross-cutting concerns shared between layers:

- **Models**: Shared data models
- **Services**: Reusable services (e.g., storage, analytics)
- **Widgets**: Shared UI components

## State Management

**GetX** is used for state management:
- Reactive programming with observables
- Navigation without context
- Dependency injection
- Route management

### Example Controller Pattern:

```dart
class HomeController extends GetxController {
  final _repository = Get.find<SomeRepository>();
  
  final isLoading = false.obs;
  final items = <Item>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      items.value = await _repository.getItems();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
```

## Network Architecture

### API Client (`ApiClient`)

- Centralized HTTP client using Dio
- Automatic request/response logging (development only)
- Auth token injection
- Error handling

### Interceptors

1. **AuthInterceptor**: Adds authentication tokens to requests
2. **ErrorInterceptor**: Centralized error handling and logging

## Dependency Injection

Using **GetIt** for dependency injection:

```dart
// Setup in dependency_injection.dart
final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt()));
  getIt.registerFactory(() => HomeController(getIt()));
}
```

## Error Handling

### Strategy:
1. Catch errors at the data source level
2. Map to domain exceptions
3. Handle in presentation layer
4. Show user-friendly messages

### Example:

```dart
try {
  // API call
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Handle unauthorized
  }
} catch (e) {
  // Handle generic error
}
```

## Testing Strategy

### Unit Tests
- Domain layer (use cases, entities)
- Data layer (repositories, models)
- Core utilities

### Widget Tests
- Individual UI components
- Screen widgets
- Custom widgets

### Integration Tests
- Complete user flows
- API integration
- Navigation flows

## Code Organization

### Naming Conventions

- **Files**: snake_case (e.g., `home_screen.dart`)
- **Classes**: PascalCase (e.g., `HomeScreen`)
- **Variables**: camelCase (e.g., `userName`)
- **Constants**: camelCase with `k` prefix (e.g., `kApiTimeout`)

### File Structure

```
feature_name/
  ├── screens/
  │   └── feature_screen.dart
  ├── widgets/
  │   └── feature_widget.dart
  ├── controllers/
  │   └── feature_controller.dart
  └── models/
      └── feature_model.dart
```

## Best Practices

1. **Separation of Concerns**: Each layer has a single responsibility
2. **DRY**: Don't Repeat Yourself - reuse code
3. **KISS**: Keep It Simple, Stupid
4. **SOLID Principles**: Especially Single Responsibility
5. **Immutable State**: Use immutable data structures
6. **Error Handling**: Always handle errors gracefully
7. **Logging**: Use the Logger utility for debugging
8. **Documentation**: Comment complex logic

## Adding New Features

### Step-by-Step Process:

1. **Define Domain Entity** (`lib/domain/entities/`)
2. **Create Repository Interface** (`lib/domain/repositories/`)
3. **Implement Use Case** (`lib/domain/usecases/`)
4. **Create Data Model** (`lib/data/models/`)
5. **Implement Data Source** (`lib/data/datasources/`)
6. **Implement Repository** (`lib/data/repositories/`)
7. **Create Controller** (`lib/presentation/controllers/`)
8. **Build Screen** (`lib/presentation/screens/`)
9. **Add Route** (`lib/presentation/routes/`)
10. **Update DI** (`lib/core/config/dependency_injection.dart`)

## Environment Configuration

Environments are configured in `main.dart`:
- Development: Mock data, verbose logging
- Staging: Staging API, moderate logging
- Production: Production API, minimal logging

Run with different environments:
```bash
flutter run --dart-define=ENV=development
```

## Performance Considerations

- Use `const` constructors where possible
- Implement lazy loading for lists
- Cache images with `cached_network_image`
- Optimize rebuilds with GetX observables
- Profile with DevTools regularly

## Security

- Store sensitive data securely
- Use HTTPS for all API calls
- Implement proper authentication
- Sanitize user inputs
- Never commit secrets to version control

## Resources

- [Flutter Clean Architecture](https://resocoder.com/category/tutorials/flutter/flutter-clean-architecture/)
- [GetX Documentation](https://pub.dev/packages/get)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://flutter.dev/docs/development/ui/widgets)

---

**Remember**: Good architecture is about making the right decisions easy and the wrong decisions hard.

