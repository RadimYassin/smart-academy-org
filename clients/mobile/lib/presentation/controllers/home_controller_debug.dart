import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// DEBUG VERSION of HomeController with extensive logging
/// Replace regular HomeController with this to debug issues
class HomeControllerDebug extends GetxController {
  final _storage = GetStorage();

  // User data observables
  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final userRole = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    debugAllStorage();
    _loadUserData();
  }

  @override
  void onReady() {
    super.onReady();
    Logger.logInfo('=== ON READY ===');
    if (userName.value == 'User') {
      Logger.logWarning('User name still default, reloading...');
      _loadUserData();
    }
  }

  /// DEBUG: Print entire storage contents
  void debugAllStorage() {
    Logger.logInfo('========= STORAGE DEBUG START =========');
    
    try {
      // Get all keys
      final keys = _storage.getKeys();
      Logger.logInfo('All storage keys: $keys');
      
      // Check each important key
      Logger.logInfo('--- Checking important keys ---');
      
      final accessToken = _storage.read(AppConstants.accessTokenKey);
      Logger.logInfo('accessToken exists: ${accessToken != null}');
      Logger.logInfo('accessToken length: ${accessToken?.toString().length ?? 0}');
      
      final refreshToken = _storage.read(AppConstants.refreshTokenKey);
      Logger.logInfo('refreshToken exists: ${refreshToken != null}');
      
      final isLoggedIn = _storage.read(AppConstants.isLoggedInKey);
      Logger.logInfo('isLoggedIn: $isLoggedIn');
      
      final userEmail = _storage.read(AppConstants.userEmailKey);
      Logger.logInfo('userEmail: $userEmail');
      
      final userRole = _storage.read(AppConstants.userRoleKey);
      Logger.logInfo('userRole: $userRole');
      
      // THE IMPORTANT ONE
      final userData = _storage.read(AppConstants.userDataKey);
      Logger.logInfo('--- USER DATA ---');
      Logger.logInfo('userData exists: ${userData != null}');
      Logger.logInfo('userData type: ${userData.runtimeType}');
      Logger.logInfo('userData content: $userData');
      
      if (userData != null && userData is Map) {
        Logger.logInfo('--- Parsing userData Map ---');
        userData.forEach((key, value) {
          Logger.logInfo('  $key: $value (${value.runtimeType})');
        });
      }
      
    } catch (e, stackTrace) {
      Logger.logError('Error in debugAllStorage', error: e);
      Logger.logError('Stack trace: $stackTrace');
    }
    
    Logger.logInfo('========= STORAGE DEBUG END =========');
  }

  /// Load user data from storage
  void _loadUserData() {
    try {
      isLoading.value = true;
      Logger.logInfo('>>> _loadUserData() START');

      // Get user data from storage
      final userData = _storage.read(AppConstants.userDataKey);

      Logger.logInfo('Step 1: Read userData from storage');
      Logger.logInfo('  userData: $userData');
      Logger.logInfo('  type: ${userData.runtimeType}');
      Logger.logInfo('  is null: ${userData == null}');
      Logger.logInfo('  is Map: ${userData is Map}');

      if (userData != null) {
        Logger.logInfo('Step 2: userData is not null, processing...');
        
        // Handle both Map<String, dynamic> and Map<dynamic, dynamic>
        Logger.logInfo('Step 3: Converting to Map<String, dynamic>');
        final data = userData is Map ? Map<String, dynamic>.from(userData) : null;
        
        Logger.logInfo('  converted data: $data');
        Logger.logInfo('  is null: ${data == null}');
        
        if (data != null) {
          Logger.logInfo('Step 4: Extracting fields...');
          
          // Extract with detailed logging
          final firstName = data['firstName'];
          final lastName = data['lastName'];
          final email = data['email'];
          final role = data['role'];
          
          Logger.logInfo('  Raw firstName: $firstName (${firstName.runtimeType})');
          Logger.logInfo('  Raw lastName: $lastName (${lastName.runtimeType})');
          Logger.logInfo('  Raw email: $email (${email.runtimeType})');
          Logger.logInfo('  Raw role: $role (${role.runtimeType})');
          
          // Convert to strings
          final firstNameStr = firstName?.toString() ?? '';
          final lastNameStr = lastName?.toString() ?? '';
          final emailStr = email?.toString() ?? '';
          final roleStr = role?.toString() ?? 'STUDENT';
          
          Logger.logInfo('Step 5: Converted to strings:');
          Logger.logInfo('  firstName: "$firstNameStr"');
          Logger.logInfo('  lastName: "$lastNameStr"');
          Logger.logInfo('  email: "$emailStr"');
          Logger.logInfo('  role: "$roleStr"');
          
          Logger.logInfo('Step 6: Setting userName...');
          if (firstNameStr.isNotEmpty) {
            userName.value = firstNameStr;
            Logger.logInfo('  Set userName from firstName: "${userName.value}"');
          } else if (emailStr.isNotEmpty) {
            userName.value = emailStr.split('@')[0];
            Logger.logInfo('  Set userName from email: "${userName.value}"');
          } else {
            userName.value = 'User';
            Logger.logInfo('  Set userName to default: "${userName.value}"');
          }
          
          userEmail.value = emailStr;
          userRole.value = roleStr;
          
          Logger.logInfo('Step 7: FINAL VALUES:');
          Logger.logInfo('  userName: "${userName.value}"');
          Logger.logInfo('  userEmail: "${userEmail.value}"');
          Logger.logInfo('  userRole: "${userRole.value}"');
        } else {
          Logger.logWarning('Step 4: data is null after conversion');
          _tryFallbackLoad();
        }
      } else {
        Logger.logWarning('Step 2: userData is null, trying fallback');
        _tryFallbackLoad();
      }
      
      Logger.logInfo('<<< _loadUserData() END');
    } catch (e, stackTrace) {
      Logger.logError('ERROR in _loadUserData', error: e);
      Logger.logError('Stack trace: $stackTrace');
      _tryFallbackLoad();
    } finally {
      isLoading.value = false;
    }
  }

  /// Try loading from alternative storage keys
  void _tryFallbackLoad() {
    try {
      Logger.logInfo('>>> _tryFallbackLoad() START');
      
      final storedEmail = _storage.read<String>(AppConstants.userEmailKey);
      Logger.logInfo('  storedEmail: $storedEmail');
      
      if (storedEmail != null && storedEmail.isNotEmpty) {
        userEmail.value = storedEmail;
        userName.value = storedEmail.split('@')[0];
        Logger.logInfo('  Fallback userName set to: "${userName.value}"');
      } else {
        userName.value = 'User';
        Logger.logInfo('  No fallback data, using default "User"');
      }
      
      Logger.logInfo('<<< _tryFallbackLoad() END');
    } catch (e, stackTrace) {
      Logger.logError('ERROR in _tryFallbackLoad', error: e);
      Logger.logError('Stack trace: $stackTrace');
      userName.value = 'User';
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    Logger.logInfo('=== refreshUserData() called ===');
    debugAllStorage();
    _loadUserData();
  }

  /// Get welcome message
  String getWelcomeMessage() {
    final message = 'Welcome ${userName.value}';
    Logger.logInfo('getWelcomeMessage() returning: "$message"');
    return message;
  }
}

