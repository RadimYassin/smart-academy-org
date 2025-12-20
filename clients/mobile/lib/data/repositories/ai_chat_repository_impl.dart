import 'dart:io';
import '../../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../models/ai_chat/ai_chat_response.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatRemoteDataSource _remoteDataSource;

  AiChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<AiChatResponse> askQuestion(String question) async {
    return await _remoteDataSource.askQuestion(question);
  }

  @override
  Future<bool> checkHealth() async {
    return await _remoteDataSource.checkHealth();
  }

  @override
  Future<Map<String, dynamic>> processAudio(File audioFile, {String? question}) async {
    return await _remoteDataSource.processAudio(audioFile, question: question);
  }

  @override
  Future<Map<String, dynamic>> processImage(File imageFile, {String? question}) async {
    return await _remoteDataSource.processImage(imageFile, question: question);
  }
}

