import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class AiChatRemoteDataSource {
  final ApiClient _apiClient;

  AiChatRemoteDataSource(this._apiClient);

  /// Ask a question to the EduBot AI assistant
  Future<String> askQuestion(String question) async {
    try {
      Logger.logInfo('Sending question to EduBot: $question');
      final response = await _apiClient.post(
        '/edubot-service/chat/ask',
        data: {'question': question},
      );
      
      if (response.statusCode == 200) {
        final answer = response.data['answer'] as String? ?? 
                      response.data['response'] as String? ?? 
                      'I apologize, but I couldn\'t generate a response.';
        Logger.logInfo('Received answer from EduBot');
        return answer;
      } else {
        throw Exception('Failed to get AI response');
      }
    } on DioException catch (e) {
      Logger.logError('AI chat error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['detail'] ?? 
                       'Failed to get AI response';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Check EduBot service health
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get('/edubot-service/health');
      return response.statusCode == 200;
    } catch (e) {
      Logger.logWarning('EduBot health check failed: $e');
      return false;
    }
  }
}

