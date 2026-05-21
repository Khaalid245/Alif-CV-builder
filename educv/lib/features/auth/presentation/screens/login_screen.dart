import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_input.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(loginProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Listen to login state changes
    ref.listen(loginProvider, (previous, next) {
      next.when(
        data: (authResponse) {
          if (authResponse != null) {
            final user = ref.read(currentUserProvider);
            if (user?.role == 'admin') {
              context.go('/admin');
            } else {
              context.go('/cv/dashboard');
            }
          }
        },
        error: (error, stackTrace) {
          SnackbarHelper.showError(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumDarkColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDarkColors.blueGlow.withValues(alpha: 0.3),
                      PremiumDarkColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDarkColors.purpleGlow.withValues(alpha: 0.2),
                      PremiumDarkColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo and brand
                          Container(
                            margin: const EdgeInsets.only(bottom: 48),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: PremiumDarkColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PremiumDarkColors.blueGlow,
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    LucideIcons.graduationCap,
                                    color: PremiumDarkColors.textPrimary,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'EduCV',
                                  style: TextStyle(
                                    color: PremiumDarkColors.textPrimary,
                                    fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Glass login card
                          GlassCard(
                            padding: const EdgeInsets.all(40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      color: PremiumDarkColors.textPrimary,
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 32,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue building your professional CV',
                                    style: TextStyle(
                                      color: PremiumDarkColors.textSecondary,
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // Email Field
                                  PremiumInput(
                                    label: 'University Email',
                                    hint: 'you@university.edu',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    focusNode: _emailFocusNode,
                                    validator: Validators.email,
                                    onEditingComplete: () {
                                      _passwordFocusNode.requestFocus();
                                    },
                                    prefixIcon: const Icon(
                                      LucideIcons.mail,
                                      color: Color(0xFF6B7280), // Gray icon color
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Password Field
                                  PremiumPasswordInput(
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    controller: _passwordController,
                                    textInputAction: TextInputAction.done,
                                    focusNode: _passwordFocusNode,
                                    validator: (value) =>
                                        Validators.required(value, 'Password'),
                                    onEditingComplete: _submitForm,
                                  ),

                                  const SizedBox(height: 16),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.go('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: PremiumDarkColors.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Sign In Button
                                  PremiumButton(
                                    text: 'Sign In',
                                    onPressed: loginState.isLoading ? null : _submitForm,
                                    isLoading: loginState.isLoading,
                                    isFullWidth: true,
                                  ),

                                  const SizedBox(height: 32),

                                  // Register Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Don\'t have an account? ',
                                        style: TextStyle(
                                          color: PremiumDarkColors.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.go('/register'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                        ),
                                        child: const Text(
                                          'Register',
                                          style: TextStyle(
                                            color: PremiumDarkColors.accent,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
