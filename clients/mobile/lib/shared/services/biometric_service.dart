import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available
  Future<bool> isAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      Logger.logInfo('Biometric available: $isAvailable, Device supported: $isDeviceSupported');
      
      return isAvailable || isDeviceSupported;
    } catch (e) {
      Logger.logError('Error checking biometric availability', error: e);
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      Logger.logError('Error getting available biometrics', error: e);
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      
      if (!isAvailable) {
        Logger.logWarning('Biometric authentication not available');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow device PIN/password as fallback
        ),
      );

      if (didAuthenticate) {
        Logger.logInfo('Biometric authentication successful');
      } else {
        Logger.logWarning('Biometric authentication failed or was cancelled');
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      Logger.logError('Platform exception during biometric auth', error: e);
      return false;
    } catch (e) {
      Logger.logError('Error during biometric authentication', error: e);
      return false;
    }
  }

  /// Stop authentication (if in progress)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      Logger.logError('Error stopping authentication', error: e);
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong';
      case BiometricType.weak:
        return 'Weak';
    }
  }

  /// Get the primary biometric type for display
  Future<String> getPrimaryBiometricType() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return 'Biometric';
      }

      // Prefer Face ID, then fingerprint
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else {
        return getBiometricTypeName(availableBiometrics.first);
      }
    } catch (e) {
      Logger.logError('Error getting primary biometric type', error: e);
      return 'Biometric';
    }
  }
}

