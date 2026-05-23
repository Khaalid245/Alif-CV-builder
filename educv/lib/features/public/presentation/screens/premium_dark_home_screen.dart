import 'package:flutter/material.dart';

import '../widgets/premium_dark_layout.dart';
import '../widgets/premium_hero_section.dart';
import '../widgets/premium_dark_stats_section.dart';
import '../widgets/premium_dark_how_it_works_section.dart';
import '../widgets/templates_section.dart';
import '../widgets/premium_dark_features_grid.dart';
import '../widgets/premium_dark_cta_banner.dart';

class PremiumDarkHomeScreen extends StatelessWidget {
  const PremiumDarkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumDarkLayout(
      child: Column(
        children: [
          PremiumHeroSection(),
          PremiumDarkStatsSection(),
          PremiumDarkHowItWorksSection(),
          TemplatesSection(),
          PremiumDarkFeaturesGrid(),
          PremiumDarkCTABanner(),
        ],
      ),
    );
  }
}