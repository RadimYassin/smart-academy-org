import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/user/user_dto.dart';
import '../models/user/credit_balance.dart';

abstract class UserRemoteDataSource {
  Future<UserDto> getUserById(int userId);
  Future<UserDto> updateUser(int userId, UpdateUserRequest request);
  Future<CreditBalance> getCreditBalance();
  Future<CreditBalance> rewardLessonComplete();
  Future<CreditBalance> deductCredits(double amount);
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

  @override
  Future<CreditBalance> getCreditBalance() async {
    try {
      Logger.logInfo('Fetching credit balance from: ${AppConstants.userServicePath}/api/credits/balance');
      final response = await apiClient.get(
        '${AppConstants.userServicePath}/api/credits/balance',
      );
      Logger.logInfo('Get credit balance response status: ${response.statusCode}');
      Logger.logInfo('Get credit balance response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        Logger.logInfo('Parsing credit balance from: $data');
        return CreditBalance.fromJson(data);
      } else {
        throw Exception('Failed to load credit balance: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.logError('Get credit balance DioException', error: e);
      Logger.logError('Response: ${e.response?.data}');
      Logger.logError('Status code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        // Try to extract error message from different possible formats
        String errorMessage = 'Failed to load credit balance';
        if (responseData is Map) {
          errorMessage = responseData['error']?.toString() ?? 
                        responseData['message']?.toString() ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        Logger.logError('Credit balance API error: $errorMessage');
        
        if (statusCode == 400) {
          // Check if it's a database read-only error
          if (errorMessage.contains('read-only') || errorMessage.contains('INSERT')) {
            throw Exception('Credit account initialization failed. Please contact support.');
          } else {
            throw Exception('Invalid request: $errorMessage');
          }
        } else if (statusCode == 404) {
          throw Exception('Credit account not found. It will be created automatically.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw Exception('Unauthorized. Please log in again.');
        } else {
          throw Exception('$errorMessage (Status: $statusCode)');
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected get credit balance error', error: e);
      rethrow;
    }
  }

  @override
  Future<CreditBalance> rewardLessonComplete() async {
    try {
      Logger.logInfo('Rewarding credits for lesson completion');
      final response = await apiClient.post(
        '${AppConstants.userServicePath}/api/credits/reward/lesson-complete',
        data: null,
      );
      Logger.logInfo('Reward lesson complete response status: ${response.statusCode}');
      Logger.logInfo('Reward lesson complete response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        Logger.logInfo('Parsing credit balance from reward: $data');
        return CreditBalance.fromJson(data);
      } else {
        throw Exception('Failed to reward credits: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.logError('Reward lesson complete DioException', error: e);
      Logger.logError('Response: ${e.response?.data}');
      Logger.logError('Status code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? 'Failed to reward credits';
        
        if (statusCode == 401 || statusCode == 403) {
          throw Exception('Unauthorized. Please log in again.');
        } else {
          throw Exception('$message (Status: $statusCode)');
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected reward lesson complete error', error: e);
      rethrow;
    }
  }

  @override
  Future<CreditBalance> deductCredits(double amount) async {
    try {
      Logger.logInfo('Deducting $amount credits');
      final response = await apiClient.post(
        '${AppConstants.userServicePath}/api/credits/deduct',
        data: {'amount': amount},
      );
      Logger.logInfo('Deduct credits response status: ${response.statusCode}');
      Logger.logInfo('Deduct credits response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        Logger.logInfo('Parsing credit balance after deduction: $data');
        return CreditBalance.fromJson(data);
      } else {
        throw Exception('Failed to deduct credits: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.logError('Deduct credits DioException', error: e);
      Logger.logError('Response: ${e.response?.data}');
      Logger.logError('Status code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        String errorMessage = 'Failed to deduct credits';
        if (responseData is Map) {
          errorMessage = responseData['error']?.toString() ?? 
                        responseData['message']?.toString() ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        Logger.logError('Deduct credits API error: $errorMessage');
        
        if (statusCode == 400) {
          if (errorMessage.contains('Insufficient') || errorMessage.contains('balance')) {
            throw Exception('Insufficient credits. You need $amount credits but your balance is too low.');
          } else {
            throw Exception('Invalid request: $errorMessage');
          }
        } else if (statusCode == 401 || statusCode == 403) {
          throw Exception('Unauthorized. Please log in again.');
        } else {
          throw Exception('$errorMessage (Status: $statusCode)');
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected deduct credits error', error: e);
      rethrow;
    }
  }
}

