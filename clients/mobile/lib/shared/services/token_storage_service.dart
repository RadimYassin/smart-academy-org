import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Service for managing JWT token storage and retrieval
class TokenStorageService {
  final GetStorage _storage;

  TokenStorageService(this._storage);

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    try {
      await _storage.write(AppConstants.accessTokenKey, token);
      Logger.logInfo('Access token saved successfully');
      
      // Verify it was saved
      final saved = await getAccessToken();
      if (saved == token) {
        Logger.logInfo('Access token verified in storage');
        return true;
      } else {
        Logger.logError('Access token verification failed');
        return false;
      }
    } catch (e) {
      Logger.logError('Error saving access token', error: e);
      return false;
    }
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    try {
      await _storage.write(AppConstants.refreshTokenKey, token);
      Logger.logInfo('Refresh token saved successfully');
      
      // Verify it was saved
      final saved = await getRefreshToken();
      if (saved == token) {
        Logger.logInfo('Refresh token verified in storage');
        return true;
      } else {
        Logger.logError('Refresh token verification failed');
        return false;
      }
    } catch (e) {
      Logger.logError('Error saving refresh token', error: e);
      return false;
    }
  }

  /// Save both tokens
  Future<bool> saveTokens(String accessToken, String refreshToken) async {
    try {
      final accessSaved = await saveAccessToken(accessToken);
      final refreshSaved = await saveRefreshToken(refreshToken);
      
      if (accessSaved && refreshSaved) {
        Logger.logInfo('Both tokens saved and verified successfully');
        return true;
      } else {
        Logger.logWarning('Token save verification failed');
        return false;
      }
    } catch (e) {
      Logger.logError('Error saving tokens', error: e);
      return false;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = _storage.read<String>(AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        Logger.logInfo('Access token retrieved from storage');
        return token;
      } else {
        Logger.logWarning('Access token not found in storage');
        return null;
      }
    } catch (e) {
      Logger.logError('Error retrieving access token', error: e);
      return null;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = _storage.read<String>(AppConstants.refreshTokenKey);
      if (token != null && token.isNotEmpty) {
        Logger.logInfo('Refresh token retrieved from storage');
        return token;
      } else {
        Logger.logWarning('Refresh token not found in storage');
        return null;
      }
    } catch (e) {
      Logger.logError('Error retrieving refresh token', error: e);
      return null;
    }
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      final hasBoth = accessToken != null && refreshToken != null;
      Logger.logInfo('Token check: hasAccess=${accessToken != null}, hasRefresh=${refreshToken != null}');
      
      return hasBoth;
    } catch (e) {
      Logger.logError('Error checking tokens', error: e);
      return false;
    }
  }

  /// Clear all tokens
  Future<bool> clearTokens() async {
    try {
      await _storage.remove(AppConstants.accessTokenKey);
      await _storage.remove(AppConstants.refreshTokenKey);
      
      // Verify they were removed
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      if (accessToken == null && refreshToken == null) {
        Logger.logInfo('All tokens cleared successfully');
        return true;
      } else {
        Logger.logWarning('Token clear verification failed');
        return false;
      }
    } catch (e) {
      Logger.logError('Error clearing tokens', error: e);
      return false;
    }
  }

  /// Get token info for debugging
  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      return {
        'hasAccessToken': accessToken != null,
        'accessTokenLength': accessToken?.length ?? 0,
        'accessTokenPreview': accessToken != null 
            ? '${accessToken.substring(0, 20)}...' 
            : null,
        'hasRefreshToken': refreshToken != null,
        'refreshTokenLength': refreshToken?.length ?? 0,
        'refreshTokenPreview': refreshToken != null 
            ? '${refreshToken.substring(0, 20)}...' 
            : null,
      };
    } catch (e) {
      Logger.logError('Error getting token info', error: e);
      return {'error': e.toString()};
    }
  }

  /// Verify tokens are stored correctly
  Future<bool> verifyTokenStorage() async {
    try {
      Logger.logInfo('=== Verifying Token Storage ===');
      
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      final hasAccess = accessToken != null && accessToken.isNotEmpty;
      final hasRefresh = refreshToken != null && refreshToken.isNotEmpty;
      
      Logger.logInfo('Access Token: ${hasAccess ? "✓ Stored" : "✗ Missing"}');
      Logger.logInfo('Refresh Token: ${hasRefresh ? "✓ Stored" : "✗ Missing"}');
      
      if (hasAccess && hasRefresh) {
        Logger.logInfo('Token storage verification: SUCCESS');
        return true;
      } else {
        Logger.logWarning('Token storage verification: FAILED');
        return false;
      }
    } catch (e) {
      Logger.logError('Error verifying token storage', error: e);
      return false;
    }
  }
}

