import 'package:get_storage/get_storage.dart';
import '../../core/utils/logger.dart';

class StorageService {
  final _storage = GetStorage();

  // Generic methods
  Future<void> write(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
      Logger.logDebug('Saved: $key');
    } catch (e) {
      Logger.logError('Error saving $key', error: e);
      rethrow;
    }
  }

  T? read<T>(String key) {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      Logger.logError('Error reading $key', error: e);
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _storage.remove(key);
      Logger.logDebug('Removed: $key');
    } catch (e) {
      Logger.logError('Error removing $key', error: e);
    }
  }

  Future<void> clear() async {
    try {
      await _storage.erase();
      Logger.logDebug('Storage cleared');
    } catch (e) {
      Logger.logError('Error clearing storage', error: e);
    }
  }

  bool hasData(String key) {
    return _storage.hasData(key);
  }
}

