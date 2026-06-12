import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../widgets/premium_dark_layout.dart';
import '../widgets/enhanced_premium_grid_background.dart';
import '../widgets/premium_floating_card.dart';
import '../widgets/animated_counter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumDarkLayout(
      child: PremiumGridBackground(
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              return isDesktop ? _buildHeroDesktop() : _buildHeroMobile();
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0);
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
                text: const TextSpan(
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
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
              const Text(
                'Born from a real problem — thousands of students graduating without knowing how to present themselves professionally. EduCV bridges that gap.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
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
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 2,
          child: _buildHeroCard()
              .animate(delay: 800.ms)
              .fadeIn(duration: 1000.ms)
              .slideX(begin: 0.3, end: 0),
        ),
      ],
    );
  }

  Widget _buildHeroMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
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
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        const Text(
          'Born from a real problem — thousands of students graduating without knowing how to present themselves professionally.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: PremiumPortfolioColors.secondaryText,
            height: 1.6,
          ),
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag('CV Builder'),
            _buildTag('Student Platform'),
            _buildTag('Career Ready'),
          ],
        )
            .animate(delay: 600.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 40),
        _buildHeroCard()
            .animate(delay: 800.ms)
            .fadeIn(duration: 1000.ms)
            .slideY(begin: 0.3, end: 0),
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PremiumPortfolioColors.accentPurple,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return PremiumFloatingCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentPurple
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: PremiumPortfolioColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
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
            child: const Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: PremiumPortfolioColors.success,
                  size: 20,
                ),
                SizedBox(width: 12),
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
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -8,
          duration: 4000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildMissionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              return isDesktop ? _buildMissionDesktop() : _buildMissionMobile();
            },
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildMissionDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTestimonialCard()
              .animate(delay: 600.ms)
              .fadeIn(duration: 1000.ms)
              .slideX(begin: -0.3, end: 0),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: _buildMissionPoints()
              .animate(delay: 800.ms)
              .fadeIn(duration: 1000.ms)
              .slideX(begin: 0.3, end: 0),
        ),
      ],
    );
  }

  Widget _buildMissionMobile() {
    return Column(
      children: [
        _buildTestimonialCard()
            .animate(delay: 600.ms)
            .fadeIn(duration: 1000.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 40),
        _buildMissionPoints()
            .animate(delay: 800.ms)
            .fadeIn(duration: 1000.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTestimonialCard() {
    return PremiumFloatingCard(
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
                child: const Icon(
                  LucideIcons.quote,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
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
          const Text(
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
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -6,
          duration: 5000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildMissionPoints() {
    final points = [
      {
        'icon': LucideIcons.target,
        'title': 'Remove barriers',
        'description':
            'Eliminate obstacles to professional presentation for all students',
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
        const Text(
          'Our Mission',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
            height: 1.2,
          ),
        )
            .animate(delay: 1000.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 32),
        ...points.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: PremiumFloatingCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PremiumPortfolioColors.accentPurple
                          .withValues(alpha: 0.1),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PremiumPortfolioColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          point['description'] as String,
                          style: const TextStyle(
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
            )
                .animate(
                  delay: (1200 + index * 200).ms,
                )
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0)
                .then()
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -4,
                  duration: (4000 + index * 500).ms,
                  curve: Curves.easeInOut,
                ),
          );
        }),
      ],
    );
  }

  Widget _buildUniversityEndorsement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumFloatingCard(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        PremiumPortfolioColors.accentPurple,
                        PremiumPortfolioColors.accentBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: PremiumPortfolioColors.cardShadow,
                  ),
                  child: const Icon(
                    LucideIcons.award,
                    color: Colors.white,
                    size: 40,
                  ),
                )
                    .animate(delay: 1600.ms)
                    .fadeIn(duration: 800.ms)
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0))
                    .then()
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .rotate(
                      begin: -0.02,
                      end: 0.02,
                      duration: 3000.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 24),
                const Text(
                  'Officially endorsed by University',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.primaryText,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 1800.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 16),
                const Text(
                  'EduCV was proposed by the university dean and implemented as the official CV building platform for all enrolled students. It meets the university\'s standards for student data privacy and professional development.',
                  style: TextStyle(
                    fontSize: 16,
                    color: PremiumPortfolioColors.secondaryText,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 2000.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .moveY(
                begin: 0,
                end: -10,
                duration: 6000.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ),
    )
        .animate(delay: 1400.ms)
        .fadeIn(duration: 1000.ms)
        .slideY(begin: 0.3, end: 0);
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Platform Statistics',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: PremiumPortfolioColors.primaryText,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 2200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 800;
                  if (isDesktop) {
                    return Row(
                      children: stats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stat = entry.value;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: _buildStatCard(stat, index),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Column(
                      children: stats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stat = entry.value;
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildStatCard(stat, index),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 2000.ms)
        .fadeIn(duration: 1000.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    return PremiumFloatingCard(
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
          )
              .animate(delay: (2400 + index * 100).ms)
              .fadeIn(duration: 600.ms)
              .scale(
                  begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
          const SizedBox(height: 20),
          AnimatedCounter(
            value: stat['value'] as String,
            delay: Duration(milliseconds: 2600 + index * 100),
            textStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: PremiumPortfolioColors.primaryText,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['label'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PremiumPortfolioColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: (2800 + index * 100).ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    )
        .animate(
          delay: (2400 + index * 150).ms,
        )
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -6,
          duration: (4000 + index * 400).ms,
          curve: Curves.easeInOut,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Powered by modern technologies',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: PremiumPortfolioColors.primaryText,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 3000.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              const Text(
                'Built with enterprise-grade tools and frameworks for reliability, security, and performance.',
                style: TextStyle(
                  fontSize: 16,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 3200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 48),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: technologies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tech = entry.value;
                  return _TechnologyChip(
                    name: tech['name'] as String,
                    icon: tech['icon'] as IconData,
                    index: index,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 2800.ms)
        .fadeIn(duration: 1000.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class _TechnologyChip extends StatefulWidget {
  final String name;
  final IconData icon;
  final int index;

  const _TechnologyChip({
    required this.name,
    required this.icon,
    required this.index,
  });

  @override
  State<_TechnologyChip> createState() => _TechnologyChipState();
}

class _TechnologyChipState extends State<_TechnologyChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: PremiumPortfolioColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? PremiumPortfolioColors.accentPurple.withValues(alpha: 0.3)
                : PremiumPortfolioColors.borderLight,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: PremiumPortfolioColors.accentPurple
                        .withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  ...PremiumPortfolioColors.floatingCardShadow,
                ]
              : PremiumPortfolioColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.icon,
                size: 20,
                color: _isHovered
                    ? PremiumPortfolioColors.accentPurple
                    : PremiumPortfolioColors.accentPurple
                        .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(
          delay: (3400 + widget.index * 100).ms,
        )
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }
}
