import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'responsive_layout.dart';

const Color _bg = Color(0xFF0A0A0A);
const Color _textMuted = Color(0xFF9E9E9E);
const Color _textLight = Color(0xFFE0E0E0);
const Color _dividerDark = Color(0xFF2A2A2A);

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: ResponsiveLayout(
              web: _WebFooterColumns(context),
              mobile: _MobileFooterColumns(context),
            ),
          ),
          Container(
            height: 1,
            color: _dividerDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ResponsiveLayout(
              web: _FooterBottom(context),
              mobile: _FooterBottomMobile(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebFooterColumns extends StatelessWidget {
  final BuildContext ctx;
  const _WebFooterColumns(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _BrandColumn(),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: _FooterColumn(
            title: 'Platform',
            links: [
              _FooterLink('Home', () => ctx.go('/')),
              _FooterLink('How it works', () => ctx.go('/')),
              _FooterLink('Templates', () => ctx.go('/')),
              _FooterLink('Sign In', () => ctx.go('/login')),
              _FooterLink('Create Account', () => ctx.go('/register')),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: _FooterColumn(
            title: 'University',
            links: [
              _FooterLink('About EduCV', () => ctx.go('/about')),
              _FooterLink('Contact Support', () => ctx.go('/contact')),
              _FooterLink('FAQ', () => ctx.go('/faq')),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: _FooterColumn(
            title: 'Legal',
            links: [
              _FooterLink('Privacy Policy', () => ctx.go('/privacy')),
              _FooterLink('Terms of Service', () => ctx.go('/terms')),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileFooterColumns extends StatelessWidget {
  final BuildContext ctx;
  const _MobileFooterColumns(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FooterColumn(
                title: 'Platform',
                links: [
                  _FooterLink('Home', () => ctx.go('/')),
                  _FooterLink('About', () => ctx.go('/about')),
                  _FooterLink('Contact', () => ctx.go('/contact')),
                  _FooterLink('FAQ', () => ctx.go('/faq')),
                ],
              ),
            ),
            Expanded(
              child: _FooterColumn(
                title: 'Legal',
                links: [
                  _FooterLink('Privacy Policy', () => ctx.go('/privacy')),
                  _FooterLink('Terms of Service', () => ctx.go('/terms')),
                  _FooterLink('Sign In', () => ctx.go('/login')),
                  _FooterLink('Register', () => ctx.go('/register')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'The official CV builder platform\nfor university students.',
          style: AppTypography.caption.copyWith(
            color: _textMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _FooterLink {
  final String label;
  final VoidCallback onTap;
  const _FooterLink(this.label, this.onTap);
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;
  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: link.onTap,
              child: Text(
                link.label,
                style: AppTypography.caption.copyWith(
                  color: _textMuted,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterBottom extends StatelessWidget {
  final BuildContext ctx;
  const _FooterBottom(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '© ${DateTime.now().year} EduCV. All rights reserved.',
          style: AppTypography.caption.copyWith(color: _textMuted),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => ctx.go('/privacy'),
          child: Text(
            'Privacy Policy',
            style: AppTypography.caption.copyWith(color: _textMuted),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => ctx.go('/terms'),
          child: Text(
            'Terms of Service',
            style: AppTypography.caption.copyWith(color: _textMuted),
          ),
        ),
      ],
    );
  }
}

class _FooterBottomMobile extends StatelessWidget {
  final BuildContext ctx;
  const _FooterBottomMobile(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => ctx.go('/privacy'),
              child: Text(
                'Privacy Policy',
                style: AppTypography.caption.copyWith(color: _textMuted),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => ctx.go('/terms'),
              child: Text(
                'Terms of Service',
                style: AppTypography.caption.copyWith(color: _textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© ${DateTime.now().year} EduCV. All rights reserved.',
          style: AppTypography.caption.copyWith(color: _textMuted),
        ),
      ],
    );
  }
}
