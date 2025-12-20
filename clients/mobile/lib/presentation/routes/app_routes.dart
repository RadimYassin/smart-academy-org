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
import '../screens/students/students_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/teacher_courses_screen.dart';
import '../screens/teacher/course_detail_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_explore_screen.dart';
import '../screens/student/student_course_view_screen.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/student/lesson_learning_screen.dart';
import '../screens/student/student_quiz_history_screen.dart';
import '../screens/student/student_quiz_screen.dart';
import '../controllers/bindings/signin_binding.dart';
import '../controllers/bindings/signup_binding.dart';
import '../controllers/bindings/dashboard_binding.dart';
import '../controllers/bindings/course_details_binding.dart';
import '../controllers/bindings/notification_binding.dart';
import '../controllers/bindings/message_list_binding.dart';
import '../controllers/bindings/chat_detail_binding.dart';
import '../controllers/bindings/recommendation_binding.dart';
import '../controllers/bindings/ai_chat_binding.dart';
import '../controllers/bindings/students_binding.dart';
import '../controllers/bindings/courses_binding.dart';
import '../controllers/bindings/teacher_dashboard_binding.dart';
import '../controllers/bindings/student_dashboard_binding.dart';
import '../controllers/bindings/student_navigation_binding.dart';

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
  static const String students = '/students';
  
  // Teacher Routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherCourses = '/teacher/courses';
  static const String teacherCourseDetail = '/teacher/courses/:courseId';
  
  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String studentHome = '/student/home';
  static const String studentExplore = '/student/explore';
  static const String studentCourseView = '/student/courses/:courseId';
  static const String lessonLearning = '/student/lessons/:lessonId';
  static const String studentQuiz = '/student/quizzes/:quizId';
  static const String studentQuizHistory = '/student/quizzes/:quizId/history';
  
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
    GetPage(
      name: students,
      page: () => const StudentsScreen(),
      binding: StudentsBinding(),
    ),
    
    // Teacher Routes
    GetPage(
      name: teacherDashboard,
      page: () => const TeacherDashboardScreen(),
      binding: TeacherDashboardBinding(),
    ),
    GetPage(
      name: teacherCourses,
      page: () => const TeacherCoursesScreen(),
      binding: CoursesBinding(),
    ),
    GetPage(
      name: teacherCourseDetail,
      page: () {
        final courseId = Get.parameters['courseId'] ?? '';
        return CourseDetailScreen(courseId: courseId);
      },
      binding: CoursesBinding(),
    ),
    
    // Student Routes
    GetPage(
      name: studentDashboard,
      page: () => const StudentDashboardScreen(),
      binding: StudentDashboardBinding(),
    ),
    GetPage(
      name: studentHome,
      page: () => const StudentHomeScreen(),
      binding: StudentNavigationBinding(),
    ),
    GetPage(
      name: studentExplore,
      page: () => const StudentExploreScreen(),
      binding: CoursesBinding(),
    ),
    GetPage(
      name: studentCourseView,
      page: () {
        final courseId = Get.parameters['courseId'] ?? '';
        return StudentCourseViewScreen(courseId: courseId);
      },
      binding: CoursesBinding(),
    ),
    GetPage(
      name: lessonLearning,
      page: () {
        final lessonId = Get.parameters['lessonId'] ?? '';
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final courseId = args['courseId'] ?? '';
        final moduleId = args['moduleId'] ?? '';
        final contentIndex = args['contentIndex'] as int?;
        return LessonLearningScreen(
          courseId: courseId,
          lessonId: lessonId,
          moduleId: moduleId,
          initialContentIndex: contentIndex,
        );
      },
      binding: CoursesBinding(),
    ),
    GetPage(
      name: studentQuiz,
      page: () {
        final quizId = Get.parameters['quizId'] ?? '';
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final quizTitle = args['quizTitle'] as String? ?? 'Quiz';
        final quizDescription = args['quizDescription'] as String?;
        return StudentQuizScreen(
          quizId: quizId,
          quizTitle: quizTitle,
          quizDescription: quizDescription,
        );
      },
      binding: CoursesBinding(),
    ),
    GetPage(
      name: studentQuizHistory,
      page: () {
        final quizId = Get.parameters['quizId'] ?? '';
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final quizTitle = args['quizTitle'] as String?;
        return StudentQuizHistoryScreen(
          quizId: quizId,
          quizTitle: quizTitle,
        );
      },
      binding: CoursesBinding(),
    ),
  ];
}

