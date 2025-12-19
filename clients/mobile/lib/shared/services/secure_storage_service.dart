import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save user credentials securely
  Future<void> saveCredentials(String email, String password) async {
    try {
      await _storage.write(key: AppConstants.secureEmailKey, value: email);
      await _storage.write(key: AppConstants.securePasswordKey, value: password);
      Logger.logInfo('Credentials saved securely');
    } catch (e) {
      Logger.logError('Error saving credentials', error: e);
      rethrow;
    }
  }

  /// Get saved email
  Future<String?> getSavedEmail() async {
    try {
      return await _storage.read(key: AppConstants.secureEmailKey);
    } catch (e) {
      Logger.logError('Error reading saved email', error: e);
      return null;
    }
  }

  /// Get saved password
  Future<String?> getSavedPassword() async {
    try {
      return await _storage.read(key: AppConstants.securePasswordKey);
    } catch (e) {
      Logger.logError('Error reading saved password', error: e);
      return null;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasSavedCredentials() async {
    try {
      final email = await getSavedEmail();
      final password = await getSavedPassword();
      return email != null && password != null && email.isNotEmpty && password.isNotEmpty;
    } catch (e) {
      Logger.logError('Error checking saved credentials', error: e);
      return false;
    }
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: AppConstants.secureEmailKey);
      await _storage.delete(key: AppConstants.securePasswordKey);
      Logger.logInfo('Credentials cleared');
    } catch (e) {
      Logger.logError('Error clearing credentials', error: e);
    }
  }

  /// Save biometric enabled preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      Logger.logInfo('💾 Saving biometric preference: $enabled');
      await _storage.write(
        key: AppConstants.biometricEnabledKey,
        value: enabled.toString(),
      );
      
      // Verify it was saved
      final saved = await _storage.read(key: AppConstants.biometricEnabledKey);
      Logger.logInfo('💾 Biometric preference saved: $saved (expected: ${enabled.toString()})');
      
      if (saved != enabled.toString()) {
        Logger.logError('⚠️ Biometric preference verification failed!');
      }
    } catch (e) {
      Logger.logError('Error saving biometric preference', error: e);
      rethrow;
    }
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: AppConstants.biometricEnabledKey);
      final enabled = value == 'true';
      Logger.logInfo('📖 Reading biometric preference: $value -> $enabled');
      return enabled;
    } catch (e) {
      Logger.logError('Error reading biometric preference', error: e);
      return false;
    }
  }
}

