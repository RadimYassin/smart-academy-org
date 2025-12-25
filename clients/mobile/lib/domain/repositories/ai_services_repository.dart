import 'dart:io';
import '../models/ai/ai_models.dart';

abstract class AIServicesRepository {
  // Health & Info
  Future<Map<String, dynamic>> getHealthStatus();
  Future<Map<String, dynamic>> getServiceInfo();

  // PrepaData
  Future<PrepDataResponse> cleanData(File csvFile, {double threshold});
  Future<AIServiceStatus> getPrepDataStatus();

  // StudentProfiler
  Future<ProfileResponse> profileStudents(ProfileRequest request);
  Future<AIServiceStatus> getProfilerStatus();

  // PathPredictor
  Future<TrainResponse> trainModel(TrainRequest request);
  Future<PredictionResponse> predictStudentRisk(Map<String, dynamic> studentData);
  Future<AIServiceStatus> getPredictorStatus();

  // RecoBuilder
  Future<RecommendationResponse> generateRecommendations(RecommendationRequest request);
  Future<AIServiceStatus> getRecommenderStatus();
}
