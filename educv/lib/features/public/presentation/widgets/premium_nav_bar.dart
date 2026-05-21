import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';
import 'educv_logo.dart';

class PremiumNavBar extends StatelessWidget {
  const PremiumNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border(
          bottom: BorderSide(color: PremiumDarkColors.border, width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth >= 800;
              return isWeb ? _buildWebNavBar(context) : _buildMobileNavBar(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWebNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const EduCVLogo(isDark: true)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavLink(context, 'Home', '/'),
                _buildNavLink(context, 'How it works', '/#how-it-works'),
                _buildNavLink(context, 'Templates', '/#templates'),
                _buildNavLink(context, 'About', '/about'),
                _buildNavLink(context, 'Contact', '/contact'),
              ]
                  .asMap()
                  .entries
                  .map((entry) => entry.value
                      .animate(delay: (200 + entry.key * 100).ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0))
                  .toList(),
            ),
          ),
          Row(
            children: [
              _buildSecondaryButton(
                context,
                'Sign In',
                () => context.go('/login'),
              ),
              const SizedBox(width: 12),
              _buildPrimaryButton(
                context,
                'Get Started',
                () => context.go('/register'),
              ),
            ],
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const EduCVLogo(isDark: true),
          const Spacer(),
          _buildMobileMenuButton(context),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (route.startsWith('/#')) {
            context.go('/');
          } else {
            context.go(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: PremiumDarkTypography.bodyMedium.copyWith(
              color: PremiumDarkColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Center(
              child: Text(
                text,
                style: PremiumDarkTypography.bodyMedium.copyWith(
                  color: PremiumDarkColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PremiumDarkColors.gradientStart,
            PremiumDarkColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PremiumDarkColors.glow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Center(
              child: Text(
                text,
                style: PremiumDarkTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMobileDrawer(context),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            LucideIcons.menu,
            size: 20,
            color: PremiumDarkColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: PremiumDarkColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: PremiumDarkColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const EduCVLogo(isDark: true),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          LucideIcons.x,
                          size: 24,
                          color: PremiumDarkColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMobileNavLink(context, 'Home', '/'),
                  _buildMobileNavLink(context, 'How it works', '/#how-it-works'),
                  _buildMobileNavLink(context, 'Templates', '/#templates'),
                  _buildMobileNavLink(context, 'About', '/about'),
                  _buildMobileNavLink(context, 'Contact', '/contact'),
                  const Spacer(),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _buildSecondaryButton(
                          context,
                          'Sign In',
                          () {
                            Navigator.pop(context);
                            context.go('/login');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: _buildPrimaryButton(
                          context,
                          'Get Started',
                          () {
                            Navigator.pop(context);
                            context.go('/register');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavLink(BuildContext context, String text, String route) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (route.startsWith('/#')) {
              context.go('/');
            } else {
              context.go(route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              text,
              style: PremiumDarkTypography.body.copyWith(
                color: PremiumDarkColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}