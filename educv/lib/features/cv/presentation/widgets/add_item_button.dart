import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';

class AddItemButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AddItemButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(LucideIcons.plus, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: PremiumPortfolioColors.accentPurple,
        side: const BorderSide(color: PremiumPortfolioColors.accentPurple),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
