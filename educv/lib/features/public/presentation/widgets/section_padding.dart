import 'package:flutter/material.dart';

class SectionPadding extends StatelessWidget {
  final Widget child;
  
  const SectionPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWeb = c.maxWidth >= 800;
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 72 : 48,
          horizontal: isWeb ? 40 : 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: child,
          ),
        ),
      );
    });
  }
}