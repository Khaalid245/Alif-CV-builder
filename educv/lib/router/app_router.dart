import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/layout/improved_app_layout.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/local_auth_screen.dart';
import '../features/auth/presentation/providers/local_auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/cv/presentation/screens/improved_onboarding_screen.dart';
import '../features/cv/presentation/screens/cv_dashboard_screen.dart';
import '../features/cv/presentation/screens/cv_sections_screen.dart';
import '../features/cv/presentation/screens/cv_downloads_screen.dart';
import '../features/account/presentation/screens/account_screen.dart';
import '../features/account/presentation/screens/change_password_screen.dart';
import '../features/cv/presentation/screens/improved_cv_form_screen.dart';
import '../features/cv/presentation/screens/cv_preview_screen.dart';
import '../features/cv_intelligence/presentation/screens/cv_intelligence_screen.dart';
import '../features/pdf/presentation/screens/pdf_result_screen.dart';
import '../features/pdf/presentation/screens/pdf_preview_screen.dart';
import '../features/version_history/presentation/screens/version_history_screen.dart';
import '../features/notifications/presentation/screens/notification_center_screen.dart';
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../features/template_engine/presentation/screens/template_catalog_screen.dart';
import '../features/template_engine/presentation/screens/template_detail_screen.dart';
import '../features/admin/presentation/screens/admin_shell.dart';
import '../features/admin/presentation/screens/student_detail_screen.dart'
    as admin_screens;
import '../features/public/presentation/screens/home_screen.dart';
import '../features/public/presentation/screens/about_screen.dart';
import '../features/public/presentation/screens/contact_screen.dart';
import '../features/public/presentation/screens/faq_screen.dart';
import '../features/public/presentation/screens/privacy_screen.dart';
import '../features/public/presentation/widgets/public_layout.dart';

// Route name constants
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String faq = '/faq';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String localAuth = '/local-auth';
  static const String onboarding = '/onboarding';
  static const String cvDashboard = '/cv/dashboard';
  static const String cvSections = '/cv/sections';
  static const String cvDownloads = '/cv/downloads';
  static const String account = '/account';
  static const String changePassword = '/account/change-password';
  static const String cvForm = '/cv/form';
  static const String cvPreview = '/cv/preview';
  static const String pdfResult = '/pdf/result';
  static const String cvIntelligence = '/cv/intelligence';
  static const String versionHistory = '/cv/version-history';
  static const String notificationCenter = '/notifications';
  static const String notificationPreferences = '/notifications/preferences';
  static const String analytics = '/analytics';
  static const String templateCatalog = '/templates';
  static const String templateDetail = '/templates/:slug';
  static const String admin = '/admin';
  static const String adminStudentDetail = '/admin/students/:id';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Notifier that triggers router refresh when auth state changes
  final authNotifier = _AuthChangeNotifier(ref);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    routes: [
      // PUBLIC ROUTES (no auth required)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.contact,
        name: 'contact',
        builder: (_, __) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (_, __) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (_, __) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        builder: (_, __) => const FAQScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.localAuth,
        name: 'localAuth',
        builder: (_, __) => const LocalAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const ImprovedOnboardingScreen(),
      ),

      // PROTECTED ROUTES (with sidebar layout)
      GoRoute(
        path: AppRoutes.cvDashboard,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const CVDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cvSections,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const CVSectionsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cvDownloads,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const CVDownloadsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cvIntelligence,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const CVIntelligenceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const AccountScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cvForm,
        builder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep =
              stepParam != null ? int.tryParse(stepParam) ?? 0 : 0;
          return ImprovedAppLayout(
            currentRoute: state.uri.path,
            child: ImprovedCVFormScreen(initialStep: initialStep),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cvPreview,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const CVPreviewScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.pdfResult,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const PDFResultScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.versionHistory,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const VersionHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationCenter,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const NotificationCenterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const NotificationPreferencesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const AnalyticsDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.templateCatalog,
        builder: (context, state) => ImprovedAppLayout(
          currentRoute: state.uri.path,
          child: const TemplateCatalogScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.templateDetail,
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return ImprovedAppLayout(
            currentRoute: state.uri.path,
            child: TemplateDetailScreen(templateSlug: slug),
          );
        },
      ),
      GoRoute(
        path: '/pdf/preview/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ImprovedAppLayout(
            currentRoute: state.uri.path,
            child: PDFPreviewScreen(generatedCvId: id),
          );
        },
      ),
      // Admin shell — contains all 4 tabs via IndexedStack
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminShell(),
      ),
      // Student detail — pushed on top of admin shell
      GoRoute(
        path: AppRoutes.adminStudentDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return admin_screens.StudentDetailScreen(studentId: id);
        },
      ),
    ],
    redirect: (context, state) async {
      try {
        final currentPath = state.uri.path;

        if (currentPath == AppRoutes.splash) return null;

        // Use in-memory auth state first (set immediately on login)
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.isAuthenticated;

        final localAuthState = ref.read(localAuthProvider);

        if (isAuthenticated &&
            localAuthState.isSupported &&
            !localAuthState.isVerified) {
          if (currentPath != AppRoutes.localAuth &&
              currentPath != AppRoutes.splash) {
            return AppRoutes.localAuth;
          }
        } else if (currentPath == AppRoutes.localAuth &&
            localAuthState.isVerified) {
          final role = authState.user?.role;
          return role == 'admin' ? AppRoutes.admin : AppRoutes.cvDashboard;
        }

        // Unauthenticated — block protected routes
        if (!isAuthenticated) {
          if (currentPath.startsWith('/cv/') ||
              currentPath.startsWith('/pdf/') ||
              currentPath.startsWith('/admin') ||
              currentPath.startsWith('/account') ||
              currentPath == '/onboarding') {
            return AppRoutes.home;
          }
          return null;
        }

        // Authenticated — redirect away from auth screens
        if (currentPath == AppRoutes.login ||
            currentPath == AppRoutes.register ||
            currentPath == AppRoutes.forgotPassword) {
          final role = authState.user?.role;
          return role == 'admin' ? AppRoutes.admin : AppRoutes.cvDashboard;
        }

        // Admin guard — only admins can access /admin routes
        if (currentPath.startsWith('/admin')) {
          if (authState.user?.role != 'admin') {
            return AppRoutes.cvDashboard;
          }
        }

        return null;
      } catch (e) {
        return AppRoutes.home;
      }
    },
  );
});

// Bridges Riverpod authProvider to GoRouter's refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _sub1 = ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _sub2 = ref.listen<LocalAuthState>(
        localAuthProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription<AuthState> _sub1;
  late final ProviderSubscription<LocalAuthState> _sub2;

  @override
  void dispose() {
    _sub1.close();
    _sub2.close();
    super.dispose();
  }
}
