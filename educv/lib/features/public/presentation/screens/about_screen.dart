import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../widgets/public_layout.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Container(
        decoration: const BoxDecoration(
          color: PremiumPortfolioColors.background,
        ),
        child: Column(
          children: [
            _buildHeroSection(),
            _buildMissionSection(),
            _buildUniversityEndorsement(),
            _buildStatisticsSection(),
            _buildTechnologySection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return isDesktop ? _buildHeroDesktop() : _buildHeroMobile();
          },
        ),
      ),
    );
  }

  Widget _buildHeroDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Built for ',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: PremiumPortfolioColors.primaryText,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: 'student success',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: PremiumPortfolioColors.accentPurple,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: PremiumPortfolioColors.primaryText,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Born from a real problem — thousands of students graduating without knowing how to present themselves professionally. EduCV bridges that gap.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTag('CV Builder'),
                  _buildTag('Student Platform'),
                  _buildTag('Career Ready'),
                  _buildTag('Professional Templates'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 2,
          child: _buildHeroCard(),
        ),
      ],
    );
  }

  Widget _buildHeroMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Built for ',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: PremiumPortfolioColors.primaryText,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'student success',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: PremiumPortfolioColors.accentPurple,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: PremiumPortfolioColors.primaryText,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Born from a real problem — thousands of students graduating without knowing how to present themselves professionally.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: PremiumPortfolioColors.secondaryText,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag('CV Builder'),
            _buildTag('Student Platform'),
            _buildTag('Career Ready'),
          ],
        ),
        const SizedBox(height: 40),
        _buildHeroCard(),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PremiumPortfolioColors.accentPurple,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 1,
        ),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.user,
                  color: PremiumPortfolioColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Johnson',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    Text(
                      'Computer Science Student',
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumPortfolioColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: PremiumPortfolioColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CV Score: 95/100',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PremiumPortfolioColors.success,
                        ),
                      ),
                      Text(
                        'Ready for applications',
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return isDesktop ? _buildMissionDesktop() : _buildMissionMobile();
          },
        ),
      ),
    );
  }

  Widget _buildMissionDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTestimonialCard(),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: _buildMissionPoints(),
        ),
      ],
    );
  }

  Widget _buildMissionMobile() {
    return Column(
      children: [
        _buildTestimonialCard(),
        const SizedBox(height: 40),
        _buildMissionPoints(),
      ],
    );
  }

  Widget _buildTestimonialCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 1,
        ),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentNavy,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.quote,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'University Career Center',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    Text(
                      'Official Statement',
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
          const SizedBox(height: 24),
          Text(
            '"Our mission is to ensure that no student at this university is held back from opportunities because of a poorly formatted CV. EduCV represents our commitment to student success."',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: PremiumPortfolioColors.primaryText,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPoints() {
    final points = [
      {
        'icon': LucideIcons.target,
        'title': 'Remove barriers',
        'description': 'Eliminate obstacles to professional presentation for all students',
      },
      {
        'icon': LucideIcons.award,
        'title': 'Standardize quality',
        'description': 'Ensure consistent CV excellence across all departments',
      },
      {
        'icon': LucideIcons.briefcase,
        'title': 'Market preparation',
        'description': 'Prepare students for real-world job market competition',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Mission',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        ...points.map((point) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PremiumPortfolioColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PremiumPortfolioColors.borderLight,
              width: 1,
            ),
            boxShadow: PremiumPortfolioColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  point['icon'] as IconData,
                  color: PremiumPortfolioColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      point['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: PremiumPortfolioColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildUniversityEndorsement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PremiumPortfolioColors.borderLight,
                width: 1,
              ),
              boxShadow: PremiumPortfolioColors.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumPortfolioColors.accentPurple,
                        PremiumPortfolioColors.accentBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: PremiumPortfolioColors.cardShadow,
                  ),
                  child: Icon(
                    LucideIcons.award,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Officially endorsed by University',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.primaryText,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'EduCV was proposed by the university dean and implemented as the official CV building platform for all enrolled students. It meets the university\'s standards for student data privacy and professional development.',
                  style: TextStyle(
                    fontSize: 16,
                    color: PremiumPortfolioColors.secondaryText,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final stats = [
      {
        'icon': LucideIcons.users,
        'value': '2,400+',
        'label': 'Students registered',
        'color': PremiumPortfolioColors.accentPurple,
      },
      {
        'icon': LucideIcons.fileText,
        'value': '8,900+',
        'label': 'CVs generated',
        'color': PremiumPortfolioColors.accentBlue,
      },
      {
        'icon': LucideIcons.layout,
        'value': '3',
        'label': 'Professional templates',
        'color': PremiumPortfolioColors.success,
      },
      {
        'icon': LucideIcons.clock,
        'value': '5 min',
        'label': 'Average time to CV',
        'color': PremiumPortfolioColors.warning,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Platform Statistics',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 800;
                if (isDesktop) {
                  return Row(
                    children: stats.map((stat) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          child: _buildStatCard(stat),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: stats.map((stat) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildStatCard(stat),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 1,
        ),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: PremiumPortfolioColors.primaryText,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['label'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PremiumPortfolioColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologySection() {
    final technologies = [
      {'name': 'Flutter', 'icon': LucideIcons.smartphone},
      {'name': 'Django', 'icon': LucideIcons.server},
      {'name': 'PostgreSQL', 'icon': LucideIcons.database},
      {'name': 'JWT', 'icon': LucideIcons.shield},
      {'name': 'Docker', 'icon': LucideIcons.box},
      {'name': 'DigitalOcean', 'icon': LucideIcons.cloud},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Powered by modern technologies',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Built with enterprise-grade tools and frameworks for reliability, security, and performance.',
              style: TextStyle(
                fontSize: 16,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PremiumPortfolioColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: PremiumPortfolioColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tech['icon'] as IconData,
                        size: 20,
                        color: PremiumPortfolioColors.accentPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tech['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PremiumPortfolioColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
