import 'dart:io';
import '../../data/models/ai_chat/ai_chat_response.dart';

/// Repository interface for AI chat operations
abstract class AiChatRepository {
  /// Ask a question to the AI assistant
  Future<AiChatResponse> askQuestion(String question);
  
  /// Check if the AI service is available
  Future<bool> checkHealth();
  
  /// Process audio file: transcribe, get answer, and receive audio response
  Future<Map<String, dynamic>> processAudio(File audioFile, {String? question});
  
  /// Process image file: analyze with Vision API and get answer
  Future<Map<String, dynamic>> processImage(File imageFile, {String? question});
}

