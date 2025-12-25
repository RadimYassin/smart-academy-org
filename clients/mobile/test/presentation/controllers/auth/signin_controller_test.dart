// Unit tests for SignInController

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/presentation/controllers/auth/signin_controller.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';
import 'package:mobile/shared/services/biometric_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/data/models/auth/auth_response.dart';
import 'package:mobile/data/models/auth/login_request.dart';
import 'package:flutter/material.dart';

import 'signin_controller_test.mocks.dart';

@GenerateMocks([AuthRepository, BiometricService, SecureStorageService])
void main() {
  late SignInController controller;
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late MockSecureStorageService mockSecureStorageService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    mockSecureStorageService = MockSecureStorageService();

    // Register mocks
    Get.put<AuthRepository>(mockAuthRepository);
    Get.put<BiometricService>(mockBiometricService);
    Get.put<SecureStorageService>(mockSecureStorageService);

    controller = SignInController();
  });

  tearDown(() {
    Get.reset();
  });

  group('SignInController', () {
    test('initial state is correct', () {
      expect(controller.emailController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isPasswordHidden.value, true);
    });

    test('togglePasswordVisibility toggles state', () {
      expect(controller.isPasswordHidden.value, true);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordHidden.value, false);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordHidden.value, true);
    });

    test('validateEmail returns error for empty email', () {
      expect(controller.validateEmail(''), 'Email is required');
      expect(controller.validateEmail(null), 'Email is required');
    });

    test('validateEmail returns error for invalid email', () {
      expect(controller.validateEmail('invalid-email'), 'Please enter a valid email');
    });

    test('validateEmail returns null for valid email', () {
      expect(controller.validateEmail('test@example.com'), null);
    });

    test('validatePassword returns error for short password', () {
      expect(controller.validatePassword('12345'), 'Password must be at least 6 characters');
    });

    test('validatePassword returns null for valid password', () {
      expect(controller.validatePassword('123456'), null);
    });
    
    // --- Login Tests ---
    test('signIn triggers loading state', () async {
      // Setup
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';
      
      when(mockAuthRepository.login(any)).thenAnswer((_) async => 
        AuthResponse(accessToken: 'token', refreshToken: 'refresh', email: 'test@example.com', role: 'student', firstName: 'Test', lastName: 'User', isVerified: true)
      );
      when(mockSecureStorageService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(mockBiometricService.isAvailable()).thenAnswer((_) async => false);

      // Act
      final future = controller.signIn();
      expect(controller.isLoading.value, true);
      await future;
      expect(controller.isLoading.value, false);
    });

    test('signIn success calls repository', () async {
      // Setup
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';
      
      final mockResponse = AuthResponse(
        accessToken: 'token', 
        refreshToken: 'refresh', 
        email: 'test@example.com', 
        role: 'student', 
        firstName: 'Test', 
        lastName: 'User',
        isVerified: true
      );

      when(mockAuthRepository.login(any)).thenAnswer((_) async => mockResponse);
      when(mockSecureStorageService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(mockBiometricService.isAvailable()).thenAnswer((_) async => false);

      // Act
      await controller.signIn();

      // Assert
      verify(mockAuthRepository.login(any)).called(1);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('signIn failure sets error message', () async {
      // Setup
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';
      
      when(mockAuthRepository.login(any)).thenThrow(Exception('Login failed'));

      // Act
      await controller.signIn();

      // Assert
      expect(controller.errorMessage.value, contains('Login failed'));
      expect(controller.isLoading.value, false);
    });
  });
}
