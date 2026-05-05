import 'package:flutter/material.dart';

import 'public_nav_bar.dart';
import 'public_footer.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;
  final bool showFooter;

  const PublicLayout({
    super.key,
    required this.child,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PublicNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            child,
            if (showFooter) const PublicFooter(),
          ],
        ),
      ),
    );
  }
}
