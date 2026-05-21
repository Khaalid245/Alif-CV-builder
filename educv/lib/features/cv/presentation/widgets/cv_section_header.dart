import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/app_router.dart';

class CVSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showVersionHistory;

  const CVSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showVersionHistory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showVersionHistory) ...[
            IconButton(
              onPressed: () => context.push(AppRoutes.versionHistory),
              icon: const Icon(Icons.history),
              tooltip: 'Version History',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Usage Example in CV Detail Screen:
/*
class CVDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CVSectionHeader(
            title: 'My CV',
            subtitle: 'Manage your CV information',
            showVersionHistory: true, // Shows history button
          ),
          Expanded(
            child: CVFormContent(),
          ),
        ],
      ),
    );
  }
}
*/