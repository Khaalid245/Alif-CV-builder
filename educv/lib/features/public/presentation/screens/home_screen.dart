import 'package:flutter/material.dart';

import '../widgets/public_layout.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_bar.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/templates_section.dart';
import '../widgets/features_grid.dart';
import '../widgets/cta_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicLayout(
      child: Column(
        children: [
          HeroSection(),
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