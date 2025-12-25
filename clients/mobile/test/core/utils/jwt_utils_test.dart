// Unit tests for JWT utility functions

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/jwt_utils.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('JwtUtils', () {
    group('decodeToken', () {
      test('successfully decodes valid JWT token', () {
        final claims = JwtUtils.decodeToken(MockJwtTokens.validToken);

        expect(claims, isNotNull);
        expect(claims!['userId'], equals(123));
        expect(claims['sub'], equals('test@example.com'));
        expect(claims['exp'], equals(9999999999));
      });

      test('returns null for invalid token format (not 3 parts)', () {
        final claims = JwtUtils.decodeToken(MockJwtTokens.invalidToken);

        expect(claims, isNull);
      });

      test('returns null for malformed base64', () {
        final claims = JwtUtils.decodeToken(MockJwtTokens.malformedToken);

        expect(claims, isNull);
      });

      test('returns null for empty token', () {
        final claims = JwtUtils.decodeToken('');

        expect(claims, isNull);
      });

      test('handles token with padding requirements', () {
        // This tests the base64 padding logic
        final claims = JwtUtils.decodeToken(MockJwtTokens.validToken);

        expect(claims, isNotNull);
      });
    });

    group('getEmailFromToken', () {
      test('extracts email from valid token', () {
        final email = JwtUtils.getEmailFromToken(MockJwtTokens.validToken);

        expect(email, equals('test@example.com'));
      });

      test('returns null for invalid token', () {
        final email = JwtUtils.getEmailFromToken(MockJwtTokens.invalidToken);

        expect(email, isNull);
      });

      test('returns null for empty token', () {
        final email = JwtUtils.getEmailFromToken('');

        expect(email, isNull);
      });
    });

    group('isTokenExpired', () {
      test('returns false for non-expired token', () {
        // validToken has exp: 9999999999 (far in the future)
        final expired = JwtUtils.isTokenExpired(MockJwtTokens.validToken);

        expect(expired, isFalse);
      });

      test('returns true for expired token', () {
        // expiredToken has exp: 1 (in the past)
        final expired = JwtUtils.isTokenExpired(MockJwtTokens.expiredToken);

        expect(expired, isTrue);
      });

      test('returns true for invalid token', () {
        final expired = JwtUtils.isTokenExpired(MockJwtTokens.invalidToken);

        expect(expired, isTrue);
      });

      test('returns true for empty token', () {
        final expired = JwtUtils.isTokenExpired('');

        expect(expired, isTrue);
      });

      test('returns true for token without exp claim', () {
        // Token without exp claim: {"userId": 123}
        const tokenWithoutExp =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEyM30.dGVzdHNpZ25hdHVyZQ';
        final expired = JwtUtils.isTokenExpired(tokenWithoutExp);

        expect(expired, isTrue);
      });
    });

    // Note: getUserIdFromToken() requires GetStorage initialization and mocking,
    // which is more complex. Skipping for now as it's covered by integration tests.
    group('getUserIdFromToken', () {
      test('returns null when no storage is initialized', () {
        // This test verifies that the method handles missing storage gracefully
        final userId = JwtUtils.getUserIdFromToken();

        // Without proper GetStorage setup, this should return null
        expect(userId, isNull);
      });
    });
  });
}
