import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../network/api_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/class_remote_datasource.dart';
import '../../data/datasources/student_remote_datasource.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/datasources/enrollment_remote_datasource.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/datasources/ai_chat_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/class_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/enrollment_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../shared/services/token_storage_service.dart';
import '../../shared/services/biometric_service.dart';
import '../../shared/services/secure_storage_service.dart';

/// Initialize all dependencies for the app
class DependencyInjection {
  static Future<void> init() async {
    // Initialize GetStorage
    await GetStorage.init();

    // Core
    final storage = GetStorage();
    Get.put<GetStorage>(storage, permanent: true);
    Get.put<ApiClient>(ApiClient(), permanent: true);

    // Services
    Get.put<TokenStorageService>(
      TokenStorageService(storage),
      permanent: true,
    );

    Get.put<BiometricService>(BiometricService(), permanent: true);
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);

    // Data Sources
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ClassRemoteDataSource>(
      ClassRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<StudentRemoteDataSource>(
      StudentRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<CourseRemoteDataSource>(
      CourseRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<EnrollmentRemoteDataSource>(
      EnrollmentRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ProgressRemoteDataSource>(
      ProgressRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<AiChatRemoteDataSource>(
      AiChatRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<UserRemoteDataSource>(
      UserRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      permanent: true,
    );

    // Repositories
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        Get.find<AuthRemoteDataSource>(),
        Get.find<GetStorage>(),
      ),
      permanent: true,
    );
    Get.put<ClassRepository>(
      ClassRepositoryImpl(Get.find<ClassRemoteDataSource>()),
      permanent: true,
    );
    Get.put<StudentRepository>(
      StudentRepositoryImpl(Get.find<StudentRemoteDataSource>()),
      permanent: true,
    );
    Get.put<CourseRepository>(
      CourseRepositoryImpl(Get.find<CourseRemoteDataSource>()),
      permanent: true,
    );
    Get.put<EnrollmentRepository>(
      EnrollmentRepositoryImpl(Get.find<EnrollmentRemoteDataSource>()),
      permanent: true,
    );
    Get.put<ProgressRepository>(
      ProgressRepositoryImpl(Get.find<ProgressRemoteDataSource>()),
      permanent: true,
    );
    Get.put<AiChatRepository>(
      AiChatRepositoryImpl(Get.find<AiChatRemoteDataSource>()),
      permanent: true,
    );
    Get.put<UserRepository>(
      UserRepositoryImpl(remoteDataSource: Get.find<UserRemoteDataSource>()),
      permanent: true,
    );
  }
}
