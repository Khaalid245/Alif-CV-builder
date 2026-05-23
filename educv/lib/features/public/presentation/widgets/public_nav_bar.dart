import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../../../../core/theme/premium_portfolio_colors.dart';
import 'educv_logo.dart';

class PublicNavBar extends StatelessWidget {
  const PublicNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.background.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              return isDesktop ? _buildDesktopNavBar(context) : _buildMobileNavBar(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const EduCVLogo(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavLink(context, 'Home', '/'),
                _buildNavLink(context, 'How it works', '/#how-it-works'),
                _buildNavLink(context, 'Templates', '/#templates'),
                _buildNavLink(context, 'About', '/about'),
                _buildNavLink(context, 'Contact', '/contact'),
              ],
            ),
          ),
          Row(
            children: [
              _buildSecondaryButton(
                context,
                'Sign In',
                () => context.go('/login'),
              ),
              const SizedBox(width: 16),
              _buildPrimaryButton(
                context,
                'Get Started',
                () => context.go('/register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const EduCVLogo(),
          const Spacer(),
          IconButton(
            onPressed: () => _showMobileDrawer(context),
            icon: Icon(
              LucideIcons.menu,
              size: 24,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (route.startsWith('/#')) {
              context.go('/');
            } else {
              context.go(route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.2,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumPortfolioColors.accentPurple,
            PremiumPortfolioColors.accentBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PremiumPortfolioColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PremiumPortfolioColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const EduCVLogo(),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    LucideIcons.x,
                    size: 24,
                    color: PremiumPortfolioColors.primaryText,
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
                  height: 48,
                  child: _buildSecondaryButton(
                    context,
                    'Sign In',
                    () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
