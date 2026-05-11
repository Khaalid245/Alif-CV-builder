import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String _sentEmail = '';
  int _secondsUntilResend = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_emailController.text);
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _sentEmail = _emailController.text.trim();
          _secondsUntilResend = 60;
        });
        _startResendTimer();
      }
    } catch (error) {
      if (mounted) SnackbarHelper.showError(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsUntilResend <= 1) {
        timer.cancel();
        setState(() => _secondsUntilResend = 0);
      } else {
        setState(() => _secondsUntilResend--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft,
                        color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 44),
                if (_isSuccess) _buildSuccess() else _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        const _IconBox(icon: LucideIcons.unlock, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Reset your password',
          textAlign: TextAlign.center,
          style: AppTypography.h1,
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your university email and we will send you a link to reset your password. Check your inbox within 5 minutes.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 32),
        AppInput(
          label: 'University email',
          hint: 'you@university.edu',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: Validators.email,
          onEditingComplete: _send,
        ),
        const SizedBox(height: 20),
        AppButton.primary(
          label: 'Send reset link',
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _send,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Back to Sign in',
            style: AppTypography.body.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final canResend = _secondsUntilResend == 0 && !_isLoading;

    return Column(
      children: [
        const Icon(LucideIcons.mailCheck, size: 40, color: AppColors.success),
        const SizedBox(height: 16),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: AppTypography.h1,
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a reset link to $_sentEmail. Tap the link in the email to set a new password.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            'Back to Sign in',
            style: AppTypography.body.copyWith(color: AppColors.primary),
          ),
        ),
        TextButton(
          onPressed: canResend ? _send : null,
          child: Text(
            canResend ? 'Resend email' : 'Resend in ${_secondsUntilResend}s',
            style: AppTypography.body.copyWith(
              color: canResend ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }
}
