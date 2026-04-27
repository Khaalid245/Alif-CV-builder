import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/storage/secure_storage.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/cv/presentation/screens/cv_dashboard_screen.dart';
import '../features/cv/presentation/screens/cv_form_screen.dart';

// Placeholder screens for routes not yet implemented

class CVPreviewScreen extends StatelessWidget {
  const CVPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CV Preview')),
      body: const Center(child: Text('CVPreviewScreen')),
    );
  }
}

class PDFResultScreen extends StatelessWidget {
  const PDFResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Result')),
      body: const Center(child: Text('PDFResultScreen')),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('AdminDashboardScreen')),
    );
  }
}

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students List')),
      body: const Center(child: Text('StudentsListScreen')),
    );
  }
}

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Detail: $studentId')),
      body: Center(child: Text('StudentDetailScreen: $studentId')),
    );
  }
}

// Route constants
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String cvDashboard = '/cv/dashboard';
  static const String cvForm = '/cv/form';
  static const String cvPreview = '/cv/preview';
  static const String pdfResult = '/pdf/result';
  static const String adminDashboard = '/admin/dashboard';
  static const String studentsList = '/admin/students';
  static const String studentDetail = '/admin/students/:id';
}

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.cvDashboard,
        builder: (context, state) => const CVDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.cvForm,
        builder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep = stepParam != null ? int.tryParse(stepParam) ?? 0 : 0;
          return CVFormScreen(initialStep: initialStep);
        },
      ),
      GoRoute(
        path: AppRoutes.cvPreview,
        builder: (context, state) => const CVPreviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.pdfResult,
        builder: (context, state) => const PDFResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentsList,
        builder: (context, state) => const StudentsListScreen(),
      ),
      GoRoute(
        path: '/admin/students/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StudentDetailScreen(studentId: id);
        },
      ),
    ],
    redirect: (context, state) async {
      final currentPath = state.uri.path;
      
      // Allow splash screen always
      if (currentPath == AppRoutes.splash) {
        return null;
      }
      
      // Check if user is authenticated
      final secureStorage = ref.read(secureStorageProvider);
      final accessToken = await secureStorage.getAccessToken();
      final isAuthenticated = accessToken != null;
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated) {
        if (currentPath.startsWith('/cv/') || currentPath.startsWith('/admin/')) {
          return AppRoutes.login;
        }
        return null; // Allow login and register
      }
      
      // If authenticated and trying to access auth routes
      if (isAuthenticated) {
        if (currentPath == AppRoutes.login || currentPath == AppRoutes.register) {
          // Get user role to determine redirect
          final userRole = await secureStorage.getUserRole();
          if (userRole == 'admin') {
            return AppRoutes.adminDashboard;
          } else {
            return AppRoutes.cvDashboard;
          }
        }
      }
      
      return null; // No redirect needed
    },
  );
});