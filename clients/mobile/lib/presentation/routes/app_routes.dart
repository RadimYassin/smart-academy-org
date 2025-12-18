import 'package:get/get.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_pageview.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/phone_number_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/category/category_screen.dart';
import '../screens/course_details/course_details_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/message/message_list_screen.dart';
import '../screens/message/chat_detail_screen.dart';
import '../screens/recommendation/recommendation_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../controllers/bindings/signin_binding.dart';
import '../controllers/bindings/signup_binding.dart';
import '../controllers/bindings/dashboard_binding.dart';
import '../controllers/bindings/course_details_binding.dart';
import '../controllers/bindings/notification_binding.dart';
import '../controllers/bindings/message_list_binding.dart';
import '../controllers/bindings/chat_detail_binding.dart';
import '../controllers/bindings/recommendation_binding.dart';
import '../controllers/bindings/ai_chat_binding.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String emailVerification = '/email-verification';
  static const String phoneNumber = '/phone-number';
  static const String dashboard = '/dashboard';
  static const String category = '/category';
  static const String courseDetails = '/course-details';
  static const String notifications = '/notifications';
  static const String messages = '/messages';
  static const String chatDetail = '/chat-detail';
  static const String recommendations = '/recommendations';
  static const String aiChat = '/ai-chat';
  static const String home = '/home';
  
  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingPageView(),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: signin,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: signup,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: emailVerification,
      page: () => const EmailVerificationScreen(),
    ),
    GetPage(
      name: phoneNumber,
      page: () => const PhoneNumberScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: category,
      page: () => const CategoryScreen(),
    ),
    GetPage(
      name: courseDetails,
      page: () => const CourseDetailsScreen(),
      binding: CourseDetailsBinding(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: messages,
      page: () => const MessageListScreen(),
      binding: MessageListBinding(),
    ),
    GetPage(
      name: chatDetail,
      page: () => const ChatDetailScreen(),
      binding: ChatDetailBinding(),
    ),
    GetPage(
      name: recommendations,
      page: () => const RecommendationScreen(),
      binding: RecommendationBinding(),
    ),
    GetPage(
      name: aiChat,
      page: () => const AiChatScreen(),
      binding: AiChatBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
  ];
}

