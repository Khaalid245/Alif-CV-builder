import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import 'educv_logo.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        border: Border(
          top: BorderSide(color: PremiumPortfolioColors.borderLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          return Column(
            children: [
              isDesktop
                  ? _buildDesktopLinks(context)
                  : _buildMobileLinks(context),
              const SizedBox(height: 40),
              Container(height: 1, color: PremiumPortfolioColors.borderLight),
              const SizedBox(height: 24),
              _buildBottom(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLinks(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBrand()),
        Expanded(
          flex: 2,
          child: _buildColumn(context, 'Platform', [
            (LucideIcons.home, 'Home', '/'),
            (LucideIcons.layoutList, 'How it works', '/'),
            (LucideIcons.fileText, 'Templates', '/'),
            (LucideIcons.logIn, 'Sign In', '/login'),
          ]),
        ),
        Expanded(
          flex: 2,
          child: _buildColumn(context, 'University', [
            (LucideIcons.info, 'About', '/about'),
            (LucideIcons.mail, 'Contact', '/contact'),
            (LucideIcons.helpCircle, 'FAQ', '/faq'),
          ]),
        ),
        Expanded(
          flex: 2,
          child: _buildColumn(context, 'Legal', [
            (LucideIcons.shield, 'Privacy Policy', '/privacy'),
            (LucideIcons.scrollText, 'Terms of Service', '/terms'),
            (LucideIcons.trash2, 'Data Deletion', '/privacy'),
          ]),
        ),
      ],
    );
  }

  Widget _buildMobileLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrand(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildColumn(context, 'Platform', [
                (LucideIcons.home, 'Home', '/'),
                (LucideIcons.layoutList, 'How it works', '/'),
                (LucideIcons.fileText, 'Templates', '/'),
                (LucideIcons.logIn, 'Sign In', '/login'),
              ]),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildColumn(context, 'University', [
                (LucideIcons.info, 'About', '/about'),
                (LucideIcons.mail, 'Contact', '/contact'),
                (LucideIcons.helpCircle, 'FAQ', '/faq'),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildColumn(context, 'Legal', [
          (LucideIcons.shield, 'Privacy Policy', '/privacy'),
          (LucideIcons.scrollText, 'Terms of Service', '/terms'),
          (LucideIcons.trash2, 'Data Deletion', '/privacy'),
        ]),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EduCVLogo(),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: const Text(
            'The official CV builder for university students. Build a professional CV in minutes.',
            style: TextStyle(
              fontSize: 13,
              color: PremiumPortfolioColors.secondaryText,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Purple accent badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  PremiumPortfolioColors.accentPurple.withValues(alpha: 0.15),
            ),
          ),
          child: const Text(
            'Free for all students',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.accentPurple,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context,
    String title,
    List<(IconData, String, String)> links,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FooterLink(icon: link.$1, label: link.$2, route: link.$3),
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        if (isDesktop) {
          return Row(
            children: [
              const Text(
                '© 2024 EduCV · University Name. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: PremiumPortfolioColors.lightText,
                ),
              ),
              const Spacer(),
              _FooterLink(
                  icon: LucideIcons.shield,
                  label: 'Privacy Policy',
                  route: '/privacy'),
              const SizedBox(width: 20),
              _FooterLink(
                  icon: LucideIcons.scrollText,
                  label: 'Terms of Service',
                  route: '/terms'),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '© 2024 EduCV · University Name. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: PremiumPortfolioColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _FooterLink(
                    icon: LucideIcons.shield,
                    label: 'Privacy Policy',
                    route: '/privacy'),
                const SizedBox(width: 20),
                _FooterLink(
                    icon: LucideIcons.scrollText,
                    label: 'Terms of Service',
                    route: '/terms'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FooterLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  const _FooterLink(
      {required this.icon, required this.label, required this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 13,
            color: _hovered
                ? PremiumPortfolioColors.accentPurple
                : PremiumPortfolioColors.secondaryText,
            fontWeight: _hovered ? FontWeight.w500 : FontWeight.w400,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: _hovered
                    ? PremiumPortfolioColors.accentPurple
                    : PremiumPortfolioColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          ),
        ),
      ),
    );
  }
}
