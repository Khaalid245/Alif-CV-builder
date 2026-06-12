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
              return isDesktop
                  ? _buildDesktopNavBar(context)
                  : _buildMobileNavBar(context);
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
                _buildNavLink(context, 'Home', '/', LucideIcons.home),
                _buildNavLink(context, 'How it works', '/#how-it-works',
                    LucideIcons.layoutList),
                _buildNavLink(
                    context, 'Templates', '/#templates', LucideIcons.fileText),
                _buildNavLink(context, 'About', '/about', LucideIcons.info),
                _buildNavLink(context, 'Contact', '/contact', LucideIcons.mail),
              ],
            ),
          ),
          Row(
            children: [
              _buildSecondaryButton(
                context,
                'Sign In',
                LucideIcons.logIn,
                () => context.go('/login'),
              ),
              const SizedBox(width: 12),
              _buildPrimaryButton(
                context,
                'Get Started',
                LucideIcons.arrowRight,
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

  Widget _buildNavLink(
      BuildContext context, String text, String route, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: PremiumPortfolioColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: PremiumPortfolioColors.primaryText,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            ],
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
        decoration: const BoxDecoration(
          color: PremiumPortfolioColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  icon: const Icon(
                    LucideIcons.x,
                    size: 24,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildMobileNavLink(context, 'Home', '/', LucideIcons.home),
            _buildMobileNavLink(context, 'How it works', '/#how-it-works',
                LucideIcons.layoutList),
            _buildMobileNavLink(
                context, 'Templates', '/#templates', LucideIcons.fileText),
            _buildMobileNavLink(context, 'About', '/about', LucideIcons.info),
            _buildMobileNavLink(
                context, 'Contact', '/contact', LucideIcons.mail),
            const Spacer(),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _buildSecondaryButton(
                    context,
                    'Sign In',
                    LucideIcons.logIn,
                    () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _buildPrimaryButton(
                    context,
                    'Get Started',
                    LucideIcons.arrowRight,
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

  Widget _buildMobileNavLink(
      BuildContext context, String text, String route, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.accentPurple
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: PremiumPortfolioColors.accentPurple,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const Spacer(),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: PremiumPortfolioColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
