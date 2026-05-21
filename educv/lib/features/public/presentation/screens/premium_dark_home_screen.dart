import 'package:flutter/material.dart';

import '../widgets/premium_dark_layout.dart';
import '../widgets/premium_hero_section.dart';
import '../widgets/stats_bar.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/templates_section.dart';
import '../widgets/features_grid.dart';
import '../widgets/cta_banner.dart';

class PremiumDarkHomeScreen extends StatelessWidget {
  const PremiumDarkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumDarkLayout(
      child: Column(
        children: [
          PremiumHeroSection(),
          StatsBar(),
          HowItWorksSection(),
          TemplatesSection(),
          FeaturesGrid(),
          CTABanner(),
        ],
      ),
    );
  }
}