import 'dart:io';
import '../../data/datasources/ai_services_remote_datasource.dart';
import '../../data/models/ai/ai_models.dart';
import '../../domain/repositories/ai_services_repository.dart';

class AIServicesRepositoryImpl implements AIServicesRepository {
  final AIServicesRemoteDataSource remoteDataSource;

  AIServicesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      return await remoteDataSource.getHealthStatus();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      return await remoteDataSource.getServiceInfo();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PrepDataResponse> cleanData(File csvFile, {double threshold = 50.0}) async {
    try {
      return await remoteDataSource.cleanData(csvFile, threshold: threshold);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AIServiceStatus> getPrepDataStatus() async {
    try {
      return await remoteDataSource.getPrepDataStatus();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileResponse> profileStudents(ProfileRequest request) async {
    try {
      return await remoteDataSource.profileStudents(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AIServiceStatus> getProfilerStatus() async {
    try {
      return await remoteDataSource.getProfilerStatus();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TrainResponse> trainModel(TrainRequest request) async {
    try {
      return await remoteDataSource.trainModel(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PredictionResponse> predictStudentRisk(Map<String, dynamic> studentData) async {
    try {
      return await remoteDataSource.predictStudentRisk(studentData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AIServiceStatus> getPredictorStatus() async {
    try {
      return await remoteDataSource.getPredictorStatus();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RecommendationResponse> generateRecommendations(RecommendationRequest request) async {
    try {
      return await remoteDataSource.generateRecommendations(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AIServiceStatus> getRecommenderStatus() async {
    try {
      return await remoteDataSource.getRecommenderStatus();
    } catch (e) {
      rethrow;
    }
  }
}
