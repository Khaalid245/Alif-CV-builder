import 'package:flutter/material.dart';
import 'public_nav_bar.dart';
import 'public_footer.dart';

class PremiumDarkLayout extends StatelessWidget {
  final Widget child;

  const PremiumDarkLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            const PublicNavBar(),
            child,
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}
