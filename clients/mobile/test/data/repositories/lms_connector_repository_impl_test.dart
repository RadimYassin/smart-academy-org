// Unit tests for LMSConnectorRepositoryImpl

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/data/repositories/lms_connector_repository_impl.dart';
import 'package:mobile/data/datasources/lms_connector_remote_datasource.dart';
import 'package:mobile/data/models/lms/lms_models.dart';

import 'lms_connector_repository_impl_test.mocks.dart';

@GenerateMocks([LMSConnectorRemoteDataSource])
void main() {
  late LMSConnectorRepositoryImpl repository;
  late MockLMSConnectorRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockLMSConnectorRemoteDataSource();
    repository = LMSConnectorRepositoryImpl(mockRemoteDataSource);
  });

  group('LMSConnectorRepositoryImpl', () {
    test('healthCheck returns map when successful', () async {
      final tResponse = {'status': 'ok'};
      when(mockRemoteDataSource.healthCheck()).thenAnswer((_) async => tResponse);
      
      final result = await repository.healthCheck();
      
      expect(result, equals(tResponse));
      verify(mockRemoteDataSource.healthCheck());
    });

    test('healthCheck throws exception when fails', () async {
      when(mockRemoteDataSource.healthCheck()).thenThrow(Exception());
      expect(() => repository.healthCheck(), throwsException);
    });

    test('pullDataFromMoodle returns LMSDataResponse', () async {
      final tResponse = LMSDataResponse(
        totalCourses: 1,
        totalStudents: 1,
        syncTime: DateTime.now(),
        status: 'ok',
        details: []
      );
      when(mockRemoteDataSource.pullDataFromMoodle()).thenAnswer((_) async => tResponse);
      
      final result = await repository.pullDataFromMoodle();
      
      expect(result, equals(tResponse));
    });

    test('getStats returns LMSStats', () async {
      final tStats = LMSStats(
        totalCourses: 10,
        totalStudents: 100,
        activeStudents: 50,
        lastSync: DateTime.now(),
      );
      when(mockRemoteDataSource.getStats()).thenAnswer((_) async => tStats);
      
      final result = await repository.getStats();
      
      expect(result, equals(tStats));
    });
  });
}
