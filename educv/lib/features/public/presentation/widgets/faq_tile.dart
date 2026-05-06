import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            question,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A0A0A),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF4A4A4A),
                  height: 1.65,
                ),
              ),
            ),
          ],
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFEEEEEE),
        ),
      ],
    );
  }
}