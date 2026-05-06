import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'educv_logo.dart';

class PublicNavBar extends StatelessWidget {
  const PublicNavBar({super.key});

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          
          if (isWeb) {
            return _buildWebNavBar(context);
          } else {
            return _buildMobileNavBar(context);
          }
        },
      ),
    );
  }

  Widget _buildWebNavBar(BuildContext context) {
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
              _buildCompactButton(
                context,
                'Sign In',
                () => context.go('/login'),
                isSecondary: true,
              ),
              const SizedBox(width: 10),
              _buildCompactButton(
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const EduCVLogo(),
          const Spacer(),
          IconButton(
            onPressed: () => _showMobileDrawer(context),
            icon: const Icon(LucideIcons.menu, size: 22, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (route.startsWith('/#')) {
            // Handle scroll to section or navigate to home with anchor
            context.go('/');
          } else {
            context.go(route);
          }
        },
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isSecondary = false,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.textPrimary : Colors.white,
          side: isSecondary ? const BorderSide(color: AppColors.divider) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const EduCVLogo(),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 22, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMobileNavLink(context, 'Home', '/'),
            const Divider(),
            _buildMobileNavLink(context, 'How it works', '/#how-it-works'),
            const Divider(),
            _buildMobileNavLink(context, 'Templates', '/#templates'),
            const Divider(),
            _buildMobileNavLink(context, 'About', '/about'),
            const Divider(),
            _buildMobileNavLink(context, 'Contact', '/contact'),
            const Spacer(),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppButton.secondary(
                    'Sign In',
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    'Get Started',
                    onPressed: () {
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
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          if (route.startsWith('/#')) {
            context.go('/');
          } else {
            context.go(route);
          }
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}