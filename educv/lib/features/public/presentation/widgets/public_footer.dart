import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'educv_logo.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.all(40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          
          if (isWeb) {
            return _buildWebFooter(context);
          } else {
            return _buildMobileFooter(context);
          }
        },
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
                  const EduCVLogo(isDark: true),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      'The official CV builder for university students. Build a professional CV in minutes.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'Platform',
                ['Home', 'How it works', 'Templates', 'Sign In'],
                ['/', '/#how-it-works', '/#templates', '/login'],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'University',
                ['About', 'Career Center', 'Contact', 'FAQ'],
                ['/about', '/about#career', '/contact', '/faq'],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                'Legal',
                ['Privacy Policy', 'Terms of Service', 'Data Deletion'],
                ['/privacy', '/terms', '/privacy#deletion'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          height: 1,
          color: const Color(0xFF1A1A1A),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              '© 2024 EduCV · [University Name]. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/privacy'),
                  child: Text(
                    'Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => context.go('/terms'),
                  child: Text(
                    'Terms of Service',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EduCVLogo(isDark: true),
        const SizedBox(height: 12),
        Text(
          'The official CV builder for university students. Build a professional CV in minutes.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFooterColumn(
                'Platform',
                ['Home', 'How it works', 'Templates', 'Sign In'],
                ['/', '/#how-it-works', '/#templates', '/login'],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildFooterColumn(
                'University',
                ['About', 'Career Center', 'Contact', 'FAQ'],
                ['/about', '/about#career', '/contact', '/faq'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFooterColumn(
          'Legal',
          ['Privacy Policy', 'Terms of Service', 'Data Deletion'],
          ['/privacy', '/terms', '/privacy#deletion'],
        ),
        const SizedBox(height: 32),
        Container(
          height: 1,
          color: const Color(0xFF1A1A1A),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '© 2024 EduCV · [University Name]. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/privacy'),
                  child: Text(
                    'Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => context.go('/terms'),
                  child: Text(
                    'Terms of Service',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<String> links, List<String> routes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.07,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(links.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                // Handle navigation - will be implemented with proper routing
              },
              child: Text(
                links[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}