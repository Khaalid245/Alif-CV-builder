import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';
import 'educv_logo.dart';

class PremiumDarkFooter extends StatelessWidget {
  const PremiumDarkFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border(
          top: BorderSide(color: PremiumDarkColors.border, width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(60),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWeb = constraints.maxWidth >= 800;
                  return isWeb ? _buildWebFooter(context) : _buildMobileFooter(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EduCVLogo(isDark: true)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'The official CV builder for university students. Build a professional CV in minutes with our premium templates.',
                      style: PremiumDarkTypography.bodyMedium.copyWith(
                        color: PremiumDarkColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'Platform',
                ['Home', 'How it works', 'Templates', 'Sign In'],
                ['/', '/#how-it-works', '/#templates', '/login'],
                0,
                context,
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'University',
                ['About', 'Career Center', 'Contact', 'FAQ'],
                ['/about', '/about#career', '/contact', '/faq'],
                1,
                context,
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'Legal',
                ['Privacy Policy', 'Terms of Service', 'Data Deletion'],
                ['/privacy', '/terms', '/privacy#deletion'],
                2,
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                PremiumDarkColors.glassBorder,
                Colors.transparent,
              ],
            ),
          ),
        )
            .animate(delay: 800.ms)
            .fadeIn(duration: 800.ms)
            .scaleX(begin: 0, end: 1),
        const SizedBox(height: 32),
        Row(
          children: [
            Text(
              '© 2024 EduCV · [University Name]. All rights reserved.',
              style: PremiumDarkTypography.caption.copyWith(
                color: PremiumDarkColors.textTertiary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildFooterLink(context, 'Privacy Policy', '/privacy'),
                const SizedBox(width: 24),
                _buildFooterLink(context, 'Terms of Service', '/terms'),
              ],
            ),
          ],
        )
            .animate(delay: 1000.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EduCVLogo(isDark: true),
        const SizedBox(height: 20),
        Text(
          'The official CV builder for university students. Build a professional CV in minutes with our premium templates.',
          style: PremiumDarkTypography.bodyMedium.copyWith(
            color: PremiumDarkColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFooterColumn(
                'Platform',
                ['Home', 'How it works', 'Templates', 'Sign In'],
                ['/', '/#how-it-works', '/#templates', '/login'],
                0,
                context,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _buildFooterColumn(
                'University',
                ['About', 'Career Center', 'Contact', 'FAQ'],
                ['/about', '/about#career', '/contact', '/faq'],
                1,
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildFooterColumn(
          'Legal',
          ['Privacy Policy', 'Terms of Service', 'Data Deletion'],
          ['/privacy', '/terms', '/privacy#deletion'],
          2,
          context,
        ),
        const SizedBox(height: 40),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                PremiumDarkColors.glassBorder,
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '© 2024 EduCV · [University Name]. All rights reserved.',
              style: PremiumDarkTypography.caption.copyWith(
                color: PremiumDarkColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFooterLink(context, 'Privacy Policy', '/privacy'),
                const SizedBox(width: 24),
                _buildFooterLink(context, 'Terms of Service', '/terms'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterColumn(
    String title,
    List<String> links,
    List<String> routes,
    int columnIndex,
    BuildContext context, // Add context parameter
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: PremiumDarkTypography.eyebrow.copyWith(
            fontSize: 11,
            color: PremiumDarkColors.primary,
          ),
        )
            .animate(delay: (400 + columnIndex * 100).ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        ...List.generate(links.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFooterLink(context, links[index], routes[index])
                .animate(delay: (500 + columnIndex * 100 + index * 50).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () {
        // Handle navigation - will be implemented with proper routing
        if (route.startsWith('/')) {
          context.go(route);
        }
      },
      child: Text(
        text,
        style: PremiumDarkTypography.bodyMedium.copyWith(
          color: PremiumDarkColors.textSecondary,
        ),
      ),
    );
  }
}