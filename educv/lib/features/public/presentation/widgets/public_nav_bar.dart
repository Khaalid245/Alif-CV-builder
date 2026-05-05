import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'responsive_layout.dart';

class PublicNavBar extends StatelessWidget implements PreferredSizeWidget {
  const PublicNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ResponsiveLayout(
        web: _WebNav(context),
        mobile: _MobileNav(context),
      ),
    );
  }
}

class _WebNav extends StatelessWidget {
  final BuildContext parentContext;
  const _WebNav(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Logo(onTap: () => parentContext.go('/')),
        const Spacer(),
        _NavLink('Home', () => parentContext.go('/')),
        const SizedBox(width: 28),
        _NavLink('How it works', () => parentContext.go('/')),
        const SizedBox(width: 28),
        _NavLink('Templates', () => parentContext.go('/')),
        const SizedBox(width: 28),
        _NavLink('About', () => parentContext.go('/about')),
        const SizedBox(width: 28),
        _NavLink('Contact', () => parentContext.go('/contact')),
        const Spacer(),
        _NavOutlineButton('Sign In', () => parentContext.go('/login')),
        const SizedBox(width: 10),
        _NavPrimaryButton('Get Started', () => parentContext.go('/register')),
      ],
    );
  }
}

class _MobileNav extends StatelessWidget {
  final BuildContext parentContext;
  const _MobileNav(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Logo(onTap: () => parentContext.go('/')),
        const Spacer(),
        IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
          onPressed: () => _openDrawer(parentContext),
        ),
      ],
    );
  }

  void _openDrawer(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MobileDrawer(parentContext: ctx),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  final BuildContext parentContext;
  const _MobileDrawer({required this.parentContext});

  void _nav(String path) {
    Navigator.of(parentContext).pop();
    parentContext.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Logo(onTap: () => _nav('/')),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _DrawerLink('Home', () => _nav('/')),
            _DrawerLink('About', () => _nav('/about')),
            _DrawerLink('Contact', () => _nav('/contact')),
            _DrawerLink('Privacy Policy', () => _nav('/privacy')),
            _DrawerLink('Terms of Service', () => _nav('/terms')),
            _DrawerLink('FAQ', () => _nav('/faq')),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _nav('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                  ),
                ),
                child: Text('Sign In', style: AppTypography.label.copyWith(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nav('/register'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Get Started', style: AppTypography.button),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DrawerLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(label, style: AppTypography.label),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;
  const _Logo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'CV',
                style: AppTypography.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'EduCV',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _NavOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavOutlineButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.divider),
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
        ),
      ),
      child: Text(label, style: AppTypography.label.copyWith(fontSize: 13)),
    );
  }
}

class _NavPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavPrimaryButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
        ),
      ),
      child: Text(label, style: AppTypography.button.copyWith(fontSize: 13)),
    );
  }
}
