import '../../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_remote_datasource.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatRemoteDataSource _remoteDataSource;

  AiChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> askQuestion(String question) async {
    return await _remoteDataSource.askQuestion(question);
  }

  @override
  Future<bool> checkHealth() async {
    return await _remoteDataSource.checkHealth();
  }
}

