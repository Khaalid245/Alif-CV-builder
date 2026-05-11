import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
            confirmPassword: _confirmController.text,
          );
      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Password updated successfully');
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Current password is incorrect');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Change password',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppPasswordInput(
                label: 'Current password',
                hint: 'Enter current password',
                controller: _currentController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Current password is required'
                    : null,
              ),
              const SizedBox(height: 20),
              AppPasswordInput(
                label: 'New password',
                hint: 'Enter new password',
                controller: _newController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 8) {
                    return 'New password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppPasswordInput(
                label: 'Confirm new password',
                hint: 'Confirm new password',
                controller: _confirmController,
                textInputAction: TextInputAction.done,
                onEditingComplete: _submit,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value != _newController.text) {
                    return 'Passwords must match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              AppButton.primary(
                label: 'Update password',
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
