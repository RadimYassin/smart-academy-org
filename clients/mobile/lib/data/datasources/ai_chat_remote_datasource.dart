import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/ai_chat/ai_chat_response.dart';

class AiChatRemoteDataSource {
  final ApiClient _apiClient;

  AiChatRemoteDataSource(this._apiClient);

  /// Ask a question to the Chatbot-edu AI assistant
  Future<AiChatResponse> askQuestion(String question) async {
    try {
      Logger.logInfo('Sending question to Chatbot-edu: $question');
      final response = await _apiClient.post(
        '${AppConstants.chatbotServicePath}/chat/ask',
        data: {'question': question},
        options: Options(
          receiveTimeout: AppConstants.chatbotTimeout,
          sendTimeout: AppConstants.chatbotTimeout,
        ),
      );
      
      if (response.statusCode == 200) {
        Logger.logInfo('Received answer from Chatbot-edu');
        return AiChatResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get AI response');
      }
    } on DioException catch (e) {
      Logger.logError('AI chat error', error: e);
      
      // Handle timeout specifically
      if (e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('The request is taking longer than expected. The AI is processing your question, please try again in a moment.');
      }
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['detail'] ?? 
                       'Failed to get AI response';
        throw Exception(message);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to the AI service. Please check your internet connection.');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Check Chatbot-edu service health
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get('${AppConstants.chatbotServicePath}/health');
      return response.statusCode == 200;
    } catch (e) {
      Logger.logWarning('Chatbot-edu health check failed: $e');
      return false;
    }
  }

  /// Process audio file: transcribe, get answer, and receive audio response
  Future<Map<String, dynamic>> processAudio(File audioFile, {String? question}) async {
    try {
      Logger.logInfo('Processing audio file: ${audioFile.path}');
      
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio.m4a',
        ),
        if (question != null && question.isNotEmpty) 'question': question,
      });

      final response = await _apiClient.post(
        '${AppConstants.chatbotServicePath}/chat/audio',
        data: formData,
        options: Options(
          receiveTimeout: AppConstants.chatbotTimeout,
          sendTimeout: AppConstants.chatbotTimeout,
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        Logger.logInfo('Audio processed successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to process audio');
      }
    } on DioException catch (e) {
      Logger.logError('Audio processing error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['detail'] ?? 
                       'Failed to process audio';
        throw Exception(message);
      } else if (e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.connectionTimeout) {
        throw Exception('The audio processing is taking longer than expected. Please try again.');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Process image file: analyze with Vision API and get answer
  Future<Map<String, dynamic>> processImage(File imageFile, {String? question}) async {
    try {
      Logger.logInfo('Processing image file: ${imageFile.path}');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.jpg',
        ),
        if (question != null && question.isNotEmpty) 'question': question,
      });

      final response = await _apiClient.post(
        '${AppConstants.chatbotServicePath}/chat/image',
        data: formData,
        options: Options(
          receiveTimeout: AppConstants.chatbotTimeout,
          sendTimeout: AppConstants.chatbotTimeout,
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        Logger.logInfo('Image processed successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to process image');
      }
    } on DioException catch (e) {
      Logger.logError('Image processing error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['detail'] ?? 
                       'Failed to process image';
        throw Exception(message);
      } else if (e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.connectionTimeout) {
        throw Exception('The image processing is taking longer than expected. Please try again.');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

