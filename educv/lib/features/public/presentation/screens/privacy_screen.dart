import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../widgets/public_layout.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Container(
        color: PremiumPortfolioColors.background,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Column(
              children: [
                _buildHero(),
                _buildContent(),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentPurple
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: PremiumPortfolioColors.accentPurple
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'PRIVACY POLICY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.accentPurple,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your privacy matters to us',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: PremiumPortfolioColors.primaryText,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We collect only what is necessary to build your CV. Your data is never sold, never shared without consent, and always under your control.',
                style: TextStyle(
                  fontSize: 18,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PremiumPortfolioColors.borderLight),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendar,
                        size: 16, color: PremiumPortfolioColors.secondaryText),
                    SizedBox(width: 8),
                    Text(
                      'Last updated: January 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: PremiumPortfolioColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 60),
              _buildSection(
                icon: LucideIcons.database,
                title: '1. What data we collect',
                items: [
                  const _PolicyItem(
                    subtitle: 'Account information',
                    body:
                        'Your full name, university email address, and student ID. These are required to create your account and verify your enrollment.',
                  ),
                  const _PolicyItem(
                    subtitle: 'CV content',
                    body:
                        'Education history, work experience, skills, languages, projects, and certifications that you voluntarily enter to build your CV.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Profile photo',
                    body:
                        'An optional profile photo (maximum 5 MB) used in your generated CV templates.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Usage data',
                    body:
                        'Login timestamps, IP addresses for security logging, and CV generation history. This data is used solely for security and platform improvement.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.settings,
                title: '2. How we use your data',
                items: [
                  const _PolicyItem(
                    subtitle: 'CV generation',
                    body:
                        'Your data is used exclusively to generate your three professional PDF CV templates. It is never used for any other purpose without your explicit consent.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Account management',
                    body:
                        'To authenticate your identity, manage your session, and allow you to update or delete your information.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Security',
                    body:
                        'Failed login attempts and suspicious activity are logged with IP addresses to protect your account from unauthorized access.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Platform improvement',
                    body:
                        'Anonymized, aggregated usage statistics (e.g. number of CVs generated) may be used to improve the platform. No personally identifiable information is included.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.share2,
                title: '3. Data sharing',
                items: [
                  const _PolicyItem(
                    subtitle: 'We do not sell your data',
                    body:
                        'Your personal information is never sold to third parties under any circumstances.',
                  ),
                  const _PolicyItem(
                    subtitle: 'University administration',
                    body:
                        'Platform administrators can verify account status and view usage statistics. They cannot access your CV content.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Legal requirements',
                    body:
                        'We may disclose data if required by law or a valid court order. We will notify you unless legally prohibited from doing so.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.lock,
                title: '4. Data security',
                items: [
                  const _PolicyItem(
                    subtitle: 'Encryption',
                    body:
                        'All data is transmitted over HTTPS. Passwords are hashed using industry-standard algorithms and are never stored in plain text.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Access control',
                    body:
                        'You can only access your own data. UUID-based identifiers prevent enumeration attacks. JWT tokens expire and are blacklisted on logout.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Audit logging',
                    body:
                        'Every significant action (login, CV generation, profile update) is recorded with a timestamp, IP address, and user agent for security auditing.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.userCheck,
                title: '5. Your rights',
                items: [
                  const _PolicyItem(
                    subtitle: 'Access',
                    body:
                        'You can view all your stored data at any time through your account dashboard.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Correction',
                    body:
                        'You can update your personal information and CV content at any time.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Deletion',
                    body:
                        'You can request full deletion of your account and all associated data from Account Settings → Request Data Deletion. Requests are processed within 30 days.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Portability',
                    body:
                        'Your generated CVs are available for download at any time in PDF format.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.cookie,
                title: '6. Cookies & storage',
                items: [
                  const _PolicyItem(
                    subtitle: 'Authentication tokens',
                    body:
                        'We store JWT access and refresh tokens in secure storage on your device to keep you logged in. These are cleared when you log out.',
                  ),
                  const _PolicyItem(
                    subtitle: 'No tracking cookies',
                    body:
                        'We do not use advertising cookies, tracking pixels, or any third-party analytics that identify you personally.',
                  ),
                ],
              ),
              _buildSection(
                icon: LucideIcons.refreshCw,
                title: '7. Policy updates',
                items: [
                  const _PolicyItem(
                    subtitle: 'Notification',
                    body:
                        'If we make material changes to this policy, we will notify you via email and display a notice on the platform before the changes take effect.',
                  ),
                  const _PolicyItem(
                    subtitle: 'Continued use',
                    body:
                        'Continued use of the platform after a policy update constitutes acceptance of the revised terms.',
                  ),
                ],
              ),
              const SizedBox(height: 60),
              _buildContactCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final items = [
      (
        LucideIcons.shieldCheck,
        'Never sold',
        'Your data is never sold to third parties',
        PremiumPortfolioColors.success
      ),
      (
        LucideIcons.eye,
        'Minimal collection',
        'Only data needed for your CV is collected',
        PremiumPortfolioColors.accentPurple
      ),
      (
        LucideIcons.trash2,
        'Right to delete',
        'Request full deletion of your data anytime',
        PremiumPortfolioColors.accentBlue
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        if (isDesktop) {
          return Row(
            children: items
                .map((item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildSummaryCard(
                            item.$1, item.$2, item.$3, item.$4),
                      ),
                    ))
                .toList(),
          );
        }
        return Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child:
                        _buildSummaryCard(item.$1, item.$2, item.$3, item.$4),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumPortfolioColors.borderLight),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: PremiumPortfolioColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<_PolicyItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumPortfolioColors.borderLight),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: PremiumPortfolioColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.accentPurple
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PremiumPortfolioColors.accentPurple
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon,
                      size: 22, color: PremiumPortfolioColors.accentPurple),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: PremiumPortfolioColors.accentPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: PremiumPortfolioColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          PremiumPortfolioColors.secondaryText,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumPortfolioColors.accentPurple.withValues(alpha: 0.06),
            PremiumPortfolioColors.accentBlue.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  PremiumPortfolioColors.accentPurple,
                  PremiumPortfolioColors.accentBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PremiumPortfolioColors.accentPurple
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(LucideIcons.mail, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 20),
          const Text(
            'Questions about your privacy?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: PremiumPortfolioColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Contact the university data protection officer at privacy@university.edu',
            style: TextStyle(
              fontSize: 15,
              color: PremiumPortfolioColors.secondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PolicyItem {
  final String subtitle;
  final String body;
  const _PolicyItem({required this.subtitle, required this.body});
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 1;
    const gridSize = 50.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
