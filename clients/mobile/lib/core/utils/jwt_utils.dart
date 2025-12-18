import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

/// Utility class for JWT token operations
class JwtUtils {
  /// Decode JWT token and extract claims
  /// Returns null if token is invalid or cannot be decoded
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      // JWT has 3 parts: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        Logger.logWarning('Invalid JWT token format');
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed (base64url may not have padding)
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      // Decode base64
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      
      // Parse JSON
      final claims = json.decode(decodedString) as Map<String, dynamic>;
      
      return claims;
    } catch (e) {
      Logger.logError('Error decoding JWT token', error: e);
      return null;
    }
  }

  /// Extract userId from JWT token stored in GetStorage
  /// Returns null if userId is not found
  static int? getUserIdFromToken() {
    try {
      final storage = GetStorage();
      final accessToken = storage.read<String>(AppConstants.accessTokenKey);

      if (accessToken == null || accessToken.isEmpty) {
        Logger.logWarning('Access token not found in storage.');
        return null;
      }

      final claims = decodeToken(accessToken);
      if (claims == null) return null;

      // userId might be stored as int or String
      final userId = claims['userId'];
      if (userId == null) return null;

      if (userId is int) {
        return userId;
      } else if (userId is String) {
        return int.tryParse(userId);
      } else if (userId is num) {
        return userId.toInt();
      }

      return null;
    } catch (e) {
      Logger.logError('Error extracting userId from token', error: e);
      return null;
    }
  }

  /// Extract email from JWT token (subject claim)
  static String? getEmailFromToken(String token) {
    try {
      final claims = decodeToken(token);
      return claims?['sub'] as String?;
    } catch (e) {
      Logger.logError('Error extracting email from token', error: e);
      return null;
    }
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final claims = decodeToken(token);
      if (claims == null) return true;

      final exp = claims['exp'];
      if (exp == null) return true;

      // exp is in seconds since epoch
      final expirationTime = exp is int ? exp : (exp as num).toInt();
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return currentTime >= expirationTime;
    } catch (e) {
      Logger.logError('Error checking token expiration', error: e);
      return true;
    }
  }
}

