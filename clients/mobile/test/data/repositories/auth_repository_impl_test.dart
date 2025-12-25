// Unit tests for AuthRepositoryImpl

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/data/repositories/auth_repository_impl.dart';
import 'package:mobile/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/data/models/auth/login_request.dart';
import 'package:mobile/data/models/auth/register_request.dart';
import 'package:mobile/data/models/auth/refresh_token_request.dart';
import 'package:mobile/data/models/auth/auth_response.dart';
import 'package:mobile/core/constants/app_constants.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, GetStorage])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockGetStorage mockStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockStorage = MockGetStorage();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockStorage);
  });

  group('AuthRepositoryImpl', () {
    final tAuthResponse = AuthResponse(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      role: 'STUDENT',
      isVerified: true,
    );

    group('login', () {
      final tLoginRequest = LoginRequest(email: 'test@example.com', password: 'password');

      test('should return AuthResponse when login is successful', () async {
        // Arrange
        when(mockRemoteDataSource.login(any)).thenAnswer((_) async => tAuthResponse);
        when(mockStorage.write(any, any)).thenAnswer((_) async => null);
        when(mockStorage.read(AppConstants.accessTokenKey)).thenReturn('access_token');
        when(mockStorage.read(AppConstants.refreshTokenKey)).thenReturn('refresh_token');

        // Act
        final result = await repository.login(tLoginRequest);

        // Assert
        expect(result, equals(tAuthResponse));
        verify(mockRemoteDataSource.login(tLoginRequest));
        verify(mockStorage.write(AppConstants.accessTokenKey, 'access_token')).called(1);
        verify(mockStorage.write(AppConstants.isLoggedInKey, true)).called(1);
      });

      test('should throw exception when login fails', () async {
        // Arrange
        when(mockRemoteDataSource.login(any)).thenThrow(Exception('Login failed'));

        // Act & Assert
        expect(() => repository.login(tLoginRequest), throwsException);
        verify(mockRemoteDataSource.login(tLoginRequest));
        verifyNever(mockStorage.write(any, any));
      });
    });

    group('register', () {
      final tRegisterRequest = RegisterRequest(
        email: 'test@example.com',
        password: 'password',
        firstName: 'John',
        lastName: 'Doe',
      );

      test('should return AuthResponse when registration is successful', () async {
        // Arrange
        when(mockRemoteDataSource.register(any)).thenAnswer((_) async => tAuthResponse);
        when(mockStorage.write(any, any)).thenAnswer((_) async => null);
        when(mockStorage.read(any)).thenReturn(null);

        // Act
        final result = await repository.register(tRegisterRequest);

        // Assert
        expect(result, equals(tAuthResponse));
        verify(mockRemoteDataSource.register(tRegisterRequest));
        verify(mockStorage.write(AppConstants.accessTokenKey, 'access_token')).called(1);
      });
    });

    group('logout', () {
      test('should clear tokens and user data', () async {
        // Arrange
        when(mockStorage.remove(any)).thenAnswer((_) async => null);
        when(mockStorage.write(any, any)).thenAnswer((_) async => null);

        // Act
        await repository.logout();

        // Assert
        verify(mockStorage.remove(AppConstants.accessTokenKey)).called(1);
        verify(mockStorage.remove(AppConstants.refreshTokenKey)).called(1);
        verify(mockStorage.remove(AppConstants.userDataKey)).called(1);
        verify(mockStorage.write(AppConstants.isLoggedInKey, false)).called(1);
      });
    });

    group('isLoggedIn', () {
      test('should return true when logged in and token exists', () async {
        // Arrange
        when(mockStorage.read(AppConstants.isLoggedInKey)).thenReturn(true);
        when(mockStorage.read(AppConstants.accessTokenKey)).thenReturn('token');

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when not logged in', () async {
        // Arrange
        when(mockStorage.read(AppConstants.isLoggedInKey)).thenReturn(false);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when token is missing', () async {
        // Arrange
        when(mockStorage.read(AppConstants.isLoggedInKey)).thenReturn(true);
        when(mockStorage.read(AppConstants.accessTokenKey)).thenReturn(null);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
