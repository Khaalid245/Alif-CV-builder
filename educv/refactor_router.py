with open('lib/router/app_router.dart', 'r') as f:
    content = f.read()

# Add imports
imports_to_add = """import '../features/auth/presentation/screens/local_auth_screen.dart';
import '../features/auth/presentation/providers/local_auth_provider.dart';
"""
content = content.replace("import '../features/auth/presentation/screens/login_screen.dart';", imports_to_add + "import '../features/auth/presentation/screens/login_screen.dart';")

# Add route constant
content = content.replace("static const String register = '/register';", "static const String register = '/register';\n  static const String localAuth = '/local-auth';")

# Add route builder
route_to_add = """      GoRoute(
        path: AppRoutes.localAuth,
        name: 'localAuth',
        builder: (_, __) => const LocalAuthScreen(),
      ),
"""
content = content.replace("      GoRoute(\n        path: AppRoutes.onboarding,", route_to_add + "      GoRoute(\n        path: AppRoutes.onboarding,")

# Update redirect logic
redirect_logic = """        // Use in-memory auth state first (set immediately on login)
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.isAuthenticated;
        
        final localAuthState = ref.read(localAuthProvider);

        if (isAuthenticated && localAuthState.isSupported && !localAuthState.isVerified) {
          if (currentPath != AppRoutes.localAuth && currentPath != AppRoutes.splash) {
            return AppRoutes.localAuth;
          }
        } else if (currentPath == AppRoutes.localAuth && localAuthState.isVerified) {
          final role = authState.user?.role;
          return role == 'admin' ? AppRoutes.admin : AppRoutes.cvDashboard;
        }"""
content = content.replace("        // Use in-memory auth state first (set immediately on login)\n        final authState = ref.read(authProvider);\n        final isAuthenticated = authState.isAuthenticated;", redirect_logic)

# Update _AuthChangeNotifier
notifier_logic = """class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _sub1 = ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _sub2 = ref.listen<LocalAuthState>(localAuthProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription<AuthState> _sub1;
  late final ProviderSubscription<LocalAuthState> _sub2;

  @override
  void dispose() {
    _sub1.close();
    _sub2.close();
    super.dispose();
  }
}"""

content = content.replace("""class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _sub = ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}""", notifier_logic)


with open('lib/router/app_router.dart', 'w') as f:
    f.write(content)
