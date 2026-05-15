import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/storage/secure_storage.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/cv/presentation/screens/student_shell.dart';
import '../features/cv/presentation/screens/onboarding_screen.dart';
import '../features/cv/presentation/screens/cv_dashboard_screen.dart';
import '../features/cv/presentation/screens/cv_sections_screen.dart';
import '../features/cv/presentation/screens/cv_downloads_screen.dart';
import '../features/account/presentation/screens/account_screen.dart';
import '../features/account/presentation/screens/change_password_screen.dart';
import '../features/cv/presentation/screens/cv_form_screen.dart';
import '../features/cv/presentation/screens/cv_preview_screen.dart';
import '../features/pdf/presentation/screens/pdf_result_screen.dart';
import '../features/pdf/presentation/screens/pdf_preview_screen.dart';
import '../features/admin/presentation/screens/admin_shell.dart';
import '../features/admin/presentation/screens/student_detail_screen.dart'
    as admin_screens;
import '../features/public/presentation/screens/home_screen.dart';
import '../features/public/presentation/screens/about_screen.dart';
import '../features/public/presentation/screens/contact_screen.dart';
import '../features/public/presentation/screens/faq_screen.dart';
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
  static const String onboarding = '/onboarding';
  static const String cvDashboard = '/cv/dashboard';
  static const String cvSections = '/cv/sections';
  static const String cvDownloads = '/cv/downloads';
  static const String account = '/account';
  static const String changePassword = '/account/change-password';
  static const String cvForm = '/cv/form';
  static const String cvPreview = '/cv/preview';
  static const String pdfResult = '/pdf/result';
  static const String admin = '/admin';
  static const String adminStudentDetail = '/admin/students/:id';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
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
        builder: (_, __) => const PublicLayout(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Privacy — Phase W4',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (_, __) => const PublicLayout(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Terms — Phase W4',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
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
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // STUDENT SHELL with 4 tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StudentShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cvDashboard,
                builder: (context, state) => const CVDashboardScreen(),
              ),
            ],
          ),
          // Branch 2: My CV (Sections)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cvSections,
                builder: (context, state) => const CVSectionsScreen(),
              ),
            ],
          ),
          // Branch 3: Downloads
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cvDownloads,
                builder: (context, state) => const CVDownloadsScreen(),
              ),
            ],
          ),
          // Branch 4: Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Other CV routes (outside shell)
      GoRoute(
        path: AppRoutes.cvForm,
        builder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep =
              stepParam != null ? int.tryParse(stepParam) ?? 0 : 0;
          return CVFormScreen(initialStep: initialStep);
        },
      ),
      GoRoute(
        path: AppRoutes.cvPreview,
        builder: (context, state) => const CVPreviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.pdfResult,
        builder: (context, state) => const PDFResultScreen(),
      ),
      GoRoute(
        path: '/pdf/preview/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PDFPreviewScreen(generatedCvId: id);
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

        final secureStorage = ref.read(secureStorageProvider);
        final accessToken = await secureStorage.getAccessToken();
        final isAuthenticated = accessToken != null;

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
          final userRole = await secureStorage.getUserRole();
          return userRole == 'admin' ? AppRoutes.admin : AppRoutes.cvDashboard;
        }

        // Admin guard — only admins can access /admin routes
        if (currentPath.startsWith('/admin')) {
          final user = ref.read(currentUserProvider);
          if (user != null && user.role != 'admin') {
            return AppRoutes.cvDashboard;
          }
        }

        return null;
      } catch (e) {
        print('Router redirect error: $e');
        return AppRoutes.home;
      }
    },
  );
});
