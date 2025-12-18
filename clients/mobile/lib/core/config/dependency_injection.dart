import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Network
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt()));
  
  // UseCases
  // getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  
  // Controllers
  // getIt.registerFactory(() => LoginController(getIt()));
}

