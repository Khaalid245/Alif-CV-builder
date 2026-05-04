import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final stopwatch = Stopwatch()..start();

    final secureStorage = ref.read(secureStorageProvider);
    final accessToken = await secureStorage.getAccessToken();

    String? role;
    if (accessToken != null) {
      try {
        final authRepository = ref.read(authRepositoryProvider);
        final student = await authRepository.getProfile();
        ref.read(currentUserProvider.notifier).state = student;
        role = student.role;
      } catch (_) {
        // Token invalid — clear ALL stored data (FIX S8)
        await secureStorage.clearAll();
      }
    }

    // Smart minimum display: only pad if auth check was faster than 600ms
    const minimumDisplay = Duration(milliseconds: 600);
    final elapsed = stopwatch.elapsed;
    if (elapsed < minimumDisplay) {
      await Future.delayed(minimumDisplay - elapsed);
    }

    if (!mounted) return;

    if (role == 'admin') {
      context.go('/admin');
    } else if (role != null) {
      context.go('/cv/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text('EduCV', style: AppTypography.display),

              const SizedBox(height: 8),

              Text('by University Name', style: AppTypography.caption),

              const SizedBox(height: 64),

              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              const SizedBox(height: 8),

              Text('Loading...', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
