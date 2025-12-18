/// Repository interface for AI chat operations
abstract class AiChatRepository {
  /// Ask a question to the AI assistant
  Future<String> askQuestion(String question);
  
  /// Check if the AI service is available
  Future<bool> checkHealth();
}

