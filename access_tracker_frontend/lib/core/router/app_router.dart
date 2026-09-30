import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/screens/forgot_password_screen.dart';
import '../../auth/screens/landing_page.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/screens/reset_password_screen.dart';
import '../../auth/screens/verify_email_screen.dart';
import '../../auth/screens/verify_reset_otp_screen.dart';
import '../../bugs/screens/bug_feed_screen.dart';
import '../../applications/screens/application_picker_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../bugs/screens/bug_details_screen.dart';
import '../../bugs/screens/edit_bug_screen.dart';
import '../../bugs/screens/my_bugs_screen.dart';
import '../../verifications/screens/verifications_screen.dart';
import '../../verifications/screens/my_verifications_screen.dart';
import '../../bugs/models/bug_models.dart';
import '../../developers/screens/developer_dashboard_screen.dart';
import '../../developers/screens/developer_responses_screen.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthState? _authState;

  AuthState? get authState => _authState;

  void update(AuthState authState) {
    if (_authState == authState) {
      return;
    }

    _authState = authState;
    notifyListeners();
  }
}

final authRouterRefresh = AuthRouterRefresh();

final appRouter = GoRouter(
  refreshListenable: authRouterRefresh,
  redirect: (context, state) {
    final authState = authRouterRefresh.authState;

    if (authState == null || authState.isInitializing) {
      return null;
    }

    final requiresAuthentication = state.uri.path == '/home' ||
        state.uri.path == '/my-bugs' ||
        state.uri.path == '/my-verifications' ||
        state.uri.path == '/developer' ||
        state.uri.path == '/developers/responses' ||
        state.uri.path.endsWith('/edit');

    if (requiresAuthentication && !authState.isAuthenticated) {
      return '/';
    }

    if (state.uri.path == '/' && authState.isAuthenticated) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/bugs',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Bug Reports')),
        body: BugFeedScreen(
          guestMode: true,
          applicationName: state.uri.queryParameters['application_name'],
        ),
      ),
    ),
    GoRoute(
      path: '/bugs/:bugId',
      builder: (context, state) => BugDetailsScreen(
        bugId: state.pathParameters['bugId']!,
      ),
    ),
    GoRoute(
      path: '/bugs/:bugId/verifications',
      builder: (context, state) => VerificationsScreen(
        bugId: state.pathParameters['bugId']!,
      ),
    ),
    GoRoute(
      path: '/bugs/:bugId/verify',
      builder: (context, state) => VerificationsScreen(
        bugId: state.pathParameters['bugId']!,
      ),
    ),
    GoRoute(
      path: '/bugs/:bugId/edit',
      builder: (context, state) => EditBugScreen(
        bug: state.extra as BugModel,
      ),
    ),
    GoRoute(
      path: '/application-picker',
      builder: (context, state) => const ApplicationPickerScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => VerifyEmailScreen(email: state.extra as String),
    ),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/forgot-password/verify',
      builder: (context, state) => VerifyResetOtpScreen(email: state.extra as String),
    ),
    GoRoute(
      path: '/forgot-password/reset',
      builder: (context, state) => ResetPasswordScreen(resetToken: state.extra as String),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/my-bugs',
      builder: (context, state) => const MyBugsScreen(),
    ),
    GoRoute(
      path: '/my-verifications',
      builder: (context, state) => const MyVerificationsScreen(),
    ),
    GoRoute(
      path: '/developer',
      builder: (context, state) => const DeveloperDashboardScreen(),
    ),
    GoRoute(
      path: '/developers/responses',
      builder: (context, state) => const MyDeveloperResponsesScreen(),
    ),
    GoRoute(
      path: '/bugs/:bugId/developer-responses',
      builder: (context, state) => DeveloperResponsesForBugScreen(
        bugId: state.pathParameters['bugId']!,
      ),
    ),
  ],
);
