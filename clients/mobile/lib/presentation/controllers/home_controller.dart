import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class HomeController extends GetxController {
  final _storage = GetStorage();

  // User data observables
  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final userRole = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure data is loaded when screen is ready
    if (userName.value == 'User') {
      Logger.logWarning('User name still default, reloading...');
      _loadUserData();
    }
  }

  /// Load user data from storage
  void _loadUserData() {
    try {
      isLoading.value = true;

      // Get user data from storage
      final userData = _storage.read(AppConstants.userDataKey);

      Logger.logInfo('Reading user data from storage: $userData');
      Logger.logInfo('User data type: ${userData.runtimeType}');

      if (userData != null) {
        // Handle both Map<String, dynamic> and Map<dynamic, dynamic>
        final data = userData is Map ? Map<String, dynamic>.from(userData) : null;
        
        if (data != null) {
          // Extract user information
          final firstName = data['firstName']?.toString() ?? '';
          final lastName = data['lastName']?.toString() ?? '';
          final email = data['email']?.toString() ?? '';
          final role = data['role']?.toString() ?? 'STUDENT';

          Logger.logInfo('Extracted: firstName=$firstName, lastName=$lastName, email=$email');

          // Update observables
          if (firstName.isNotEmpty) {
            userName.value = firstName;
          } else if (email.isNotEmpty) {
            // Extract name from email as fallback
            userName.value = email.split('@')[0];
          } else {
            userName.value = 'User';
          }
          
          userEmail.value = email;
          userRole.value = role;

          Logger.logInfo('User name set to: ${userName.value}');
        } else {
          _tryFallbackLoad();
        }
      } else {
        _tryFallbackLoad();
      }
    } catch (e) {
      Logger.logError('Error loading user data', error: e);
      _tryFallbackLoad();
    } finally {
      isLoading.value = false;
    }
  }

  /// Try loading from alternative storage keys
  void _tryFallbackLoad() {
    try {
      Logger.logInfo('Trying fallback load...');
      final storedEmail = _storage.read<String>(AppConstants.userEmailKey);
      if (storedEmail != null && storedEmail.isNotEmpty) {
        userEmail.value = storedEmail;
        // Extract name from email as fallback
        userName.value = storedEmail.split('@')[0];
        Logger.logInfo('Fallback: userName set to ${userName.value}');
      } else {
        userName.value = 'User';
        Logger.logInfo('No fallback data found, using default "User"');
      }
    } catch (e) {
      Logger.logError('Fallback load error', error: e);
      userName.value = 'User';
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    _loadUserData();
  }

  /// Get welcome message
  String getWelcomeMessage() {
    return 'Welcome ${userName.value}';
  }
}

