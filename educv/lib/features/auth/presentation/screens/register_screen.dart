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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _studentIdFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;
  bool _dataProcessingConsent = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _studentIdFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    if (value.contains(' ')) {
      return 'Student ID cannot contain spaces';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'At least 8 characters required';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submitForm() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Debug: Print consent values
    debugPrint('Consent values: terms=$_termsAccepted, privacy=$_privacyPolicyAccepted, data=$_dataProcessingConsent');

    // Validate form fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate consent checkboxes
    if (!_termsAccepted || !_privacyPolicyAccepted || !_dataProcessingConsent) {
      SnackbarHelper.showError(
        context,
        'Please accept all terms to continue',
      );
      return;
    }

    // Submit registration
    ref.read(registerProvider.notifier).register(
          email: _emailController.text,
          fullName: _fullNameController.text,
          studentId: _studentIdController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          termsAccepted: _termsAccepted,
          privacyPolicyAccepted: _privacyPolicyAccepted,
          dataProcessingConsent: _dataProcessingConsent,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    // Listen to register state changes
    ref.listen(registerProvider, (previous, next) {
      next.when(
        data: (authResponse) {
          if (authResponse != null) {
            context.go('/cv/dashboard');
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
                    'Create account',
                    style: AppTypography.h1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join thousands of students building professional CVs',
                    style: AppTypography.body,
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Full Name Field
                  AppInput(
                    label: 'Full Name',
                    hint: 'As it appears on official documents',
                    controller: _fullNameController,
                    textInputAction: TextInputAction.next,
                    focusNode: _fullNameFocusNode,
                    validator: Validators.name,
                    onEditingComplete: () {
                      _studentIdFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Student ID Field
                  AppInput(
                    label: 'Student ID',
                    hint: 'e.g. STU2024001',
                    controller: _studentIdController,
                    textInputAction: TextInputAction.next,
                    focusNode: _studentIdFocusNode,
                    validator: _validateStudentId,
                    onEditingComplete: () {
                      _emailFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  AppPasswordInput(
                    label: 'Password',
                    hint: 'Minimum 8 characters',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocusNode,
                    validator: _validatePassword,
                    onEditingComplete: () {
                      _confirmPasswordFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  AppPasswordInput(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    focusNode: _confirmPasswordFocusNode,
                    validator: _validateConfirmPassword,
                    onEditingComplete: _submitForm,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Consent Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: AppColors.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before continuing',
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: 12),
                        
                        // Terms of Service
                        ConsentCheckbox(
                          value: _termsAccepted,
                          text: 'I agree to the Terms of Service',
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Privacy Policy
                        ConsentCheckbox(
                          value: _privacyPolicyAccepted,
                          text: 'I accept the Privacy Policy',
                          onChanged: (value) {
                            setState(() {
                              _privacyPolicyAccepted = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Data Processing
                        ConsentCheckbox(
                          value: _dataProcessingConsent,
                          text: 'I consent to data processing for CV generation',
                          onChanged: (value) {
                            setState(() {
                              _dataProcessingConsent = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Create Account Button
                  AppButton(
                    text: 'Create Account',
                    onPressed: registerState.isLoading ? null : _submitForm,
                    isLoading: registerState.isLoading,
                    isFullWidth: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.body,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Sign In',
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

class ConsentCheckbox extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool?> onChanged;

  const ConsentCheckbox({
    super.key,
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}