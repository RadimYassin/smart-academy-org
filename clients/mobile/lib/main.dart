import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/config/app_config.dart';
import 'core/config/app_config.dart' as config;
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for local storage
  await GetStorage.init();

  // Initialize app configuration
  _initializeAppConfig();

  // Setup system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  Logger.logInfo('App initialized successfully');

  runApp(const MyApp());
}

void _initializeAppConfig() {
  // Configure based on environment
  const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  Environment env;
  String apiUrl;

  switch (environment.toLowerCase()) {
    case 'production':
      env = Environment.production;
      apiUrl = 'https://api.production.com';
      break;
    case 'staging':
      env = Environment.staging;
      apiUrl = 'https://api.staging.com';
      break;
    default:
      env = Environment.development;
      apiUrl = 'https://api.example.com';
  }

  config.AppConfig.initialize(
    environment: env,
    apiUrl: apiUrl,
    enableLogging: env != Environment.production,
  );

  Logger.logInfo('App config initialized: $environment');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mobile App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
