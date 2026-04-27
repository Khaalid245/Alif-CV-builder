import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: Text(
          'Reset Password',
          style: AppTypography.h2,
        ),
        content: Text(
          'Please contact your university administrator to reset your password.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTypography.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
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
              context.go('/admin/dashboard');
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  
                  // Header
                  Text(
                    'Welcome back',
                    style: AppTypography.h1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your CV builder',
                    style: AppTypography.body,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Email Field
                  AppInput(
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
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field
                  AppPasswordInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    focusNode: _passwordFocusNode,
                    validator: (value) => Validators.required(value, 'Password'),
                    onEditingComplete: _submitForm,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot password?',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  AppButton(
                    text: 'Sign In',
                    onPressed: loginState.isLoading ? null : _submitForm,
                    isLoading: loginState.isLoading,
                    isFullWidth: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTypography.body,
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          'Register',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}