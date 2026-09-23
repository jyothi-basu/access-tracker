import 'package:go_router/go_router.dart';
import '../../auth/screens/landing_page.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/screens/verify_email_screen.dart';
import '../../auth/screens/forgot_password_screen.dart';
import '../../auth/screens/verify_reset_otp_screen.dart';
import '../../auth/screens/reset_password_screen.dart';
import '../../auth/screens/dashboard_placeholder.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/verify-email', builder: (context, state) => VerifyEmailScreen(email: state.extra as String)),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/forgot-password/verify',
      builder: (context, state) => VerifyResetOtpScreen(email: state.extra as String),
    ),
    GoRoute(
      path: '/forgot-password/reset',
      builder: (context, state) => ResetPasswordScreen(resetToken: state.extra as String),
    ),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPlaceholder()),
  ],
);
