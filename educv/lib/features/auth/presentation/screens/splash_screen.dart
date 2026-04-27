import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth status changes and navigate accordingly
    ref.listen(splashProvider, (previous, next) {
      next.whenData((authStatus) {
        if (authStatus == AuthStatus.authenticated) {
          final currentUser = ref.read(currentUserProvider);
          if (currentUser?.role == 'admin') {
            context.go('/admin/dashboard');
          } else {
            context.go('/cv/dashboard');
          }
        } else if (authStatus == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    'CV',
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Name
              Text(
                'EduCV',
                style: AppTypography.display,
              ),
              
              const SizedBox(height: 8),
              
              // University Name
              Text(
                'by University Name',
                style: AppTypography.caption,
              ),
              
              const SizedBox(height: 64),
              
              // Loading Indicator
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Loading Text
              Text(
                'Loading...',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}