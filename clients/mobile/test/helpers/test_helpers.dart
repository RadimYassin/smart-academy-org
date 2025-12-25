// Test helpers and mock data for Smart Academy tests

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class to create test widgets wrapped in GetMaterialApp
class TestHelpers {
  /// Wrap widget in GetMaterialApp for testing
  static Widget wrapWithApp(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Create a MaterialApp wrapper (without GetX)
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

/// Mock JWT tokens for testing
class MockJwtTokens {
  /// Valid JWT token (header.payload.signature format)
  /// Payload: {"userId": 123, "sub": "test@example.com", "exp": 9999999999}
  static const String validToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEyMywic3ViIjoidGVzdEBleGFtcGxlLmNvbSIsImV4cCI6OTk5OTk5OTk5OX0.dGVzdHNpZ25hdHVyZQ';

  /// Expired JWT token
  /// Payload: {"userId": 123, "sub": "test@example.com", "exp": 1}
  static const String expiredToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEyMywic3ViIjoidGVzdEBleGFtcGxlLmNvbSIsImV4cCI6MX0.dGVzdHNpZ25hdHVyZQ';

  /// Invalid JWT token (not 3 parts)
  static const String invalidToken = 'invalid.token';

  /// Malformed base64 token
  static const String malformedToken = 'header.!!!invalid-base64!!!.signature';
}
