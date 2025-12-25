import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/credit/credit_balance.dart';

class CreditRemoteDataSource {
  final ApiClient _apiClient;

  CreditRemoteDataSource(this._apiClient);

  /// Get current user's credit balance
  Future<CreditBalance> getMyBalance() async {
    try {
      Logger.logInfo('Fetching credit balance');
      
      final response = await _apiClient.get(
        '${AppConstants.userServicePath}/api/credits/balance',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Credit balance fetched successfully');
        return CreditBalance.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch credit balance');
      }
    } on DioException catch (e) {
      Logger.logError('Get credit balance error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch credit balance';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Get student credit balance (Teacher/Admin)
  Future<CreditBalance> getStudentBalance(int studentId) async {
    try {
      Logger.logInfo('Fetching credit balance for student: $studentId');
      
      final response = await _apiClient.get(
        '${AppConstants.userServicePath}/api/credits/student/$studentId',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Student credit balance fetched successfully');
        return CreditBalance.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch student credit balance');
      }
    } on DioException catch (e) {
      Logger.logError('Get student credit balance error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch credit balance';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update student credits (Teacher/Admin)
  Future<void> updateCredits(int studentId, double amount) async {
    try {
      Logger.logInfo('Updating credits for student: $studentId, amount: $amount');
      
      final response = await _apiClient.post(
        '${AppConstants.userServicePath}/api/credits/update',
        data: UpdateCreditRequest(
          studentId: studentId,
          amount: amount,
        ).toJson(),
      );

      if (response.statusCode == 200) {
        Logger.logInfo('Credits updated successfully');
      } else {
        throw Exception('Failed to update credits');
      }
    } on DioException catch (e) {
      Logger.logError('Update credits error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update credits';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Reward credits for completing lesson
  Future<CreditBalance> rewardLessonComplete() async {
    try {
      Logger.logInfo('Rewarding credits for lesson completion');
      
      final response = await _apiClient.post(
        '${AppConstants.userServicePath}/api/credits/reward/lesson-complete',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Credits rewarded successfully +5 credits');
        return CreditBalance.fromJson(response.data);
      } else {
        throw Exception('Failed to reward credits');
      }
    } on DioException catch (e) {
      Logger.logError('Reward credits error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to reward credits';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Deduct credits from account
  Future<CreditBalance> deductCredits(double amount) async {
    try {
      Logger.logInfo('Deducting credits: $amount');
      
      final response = await _apiClient.post(
        '${AppConstants.userServicePath}/api/credits/deduct',
        data: DeductCreditRequest(amount: amount).toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Credits deducted successfully');
        return CreditBalance.fromJson(response.data);
      } else {
        throw Exception('Failed to deduct credits');
      }
    } on DioException catch (e) {
      Logger.logError('Deduct credits error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to deduct credits';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}
