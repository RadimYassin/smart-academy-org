import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/user/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<UserDto> getUserById(int userId);
  Future<UserDto> updateUser(int userId, UpdateUserRequest request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserDto> getUserById(int userId) async {
    try {
      final response = await apiClient.get(
        '${AppConstants.userServicePath}/api/v1/users/$userId',
      );
      Logger.logInfo('Get user by ID response: $response');
      return UserDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.logError('Get user by ID error', error: e);
      rethrow;
    }
  }

  @override
  Future<UserDto> updateUser(int userId, UpdateUserRequest request) async {
    try {
      final response = await apiClient.put(
        '${AppConstants.userServicePath}/api/v1/users/$userId',
        data: request.toJson(),
      );
      Logger.logInfo('Update user response: $response');
      return UserDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.logError('Update user error', error: e);
      rethrow;
    }
  }
}

