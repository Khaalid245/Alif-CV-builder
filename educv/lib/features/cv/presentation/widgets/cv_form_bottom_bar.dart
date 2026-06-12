import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_saas_theme.dart';
import 'cv_form_step_shell.dart';

/// Bottom action bar for CV builder pages (not the app sidebar).
class CVFormBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final bool isLoading;
  final bool showPrevious;
  final VoidCallback? onPrevious;
  final VoidCallback? onPrimary;
  final String primaryLabel;
  final IconData primaryIcon;

  const CVFormBottomBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.isLoading,
    required this.showPrevious,
    required this.onPrevious,
    required this.onPrimary,
    required this.primaryLabel,
    required this.primaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.08),
      color: PremiumSaaSTheme.lightSurface,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 560;

            final previousButton = showPrevious
                ? OutlinedButton.icon(
                    onPressed: isLoading ? null : onPrevious,
                    icon: const Icon(LucideIcons.arrowLeft, size: 18),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PremiumSaaSTheme.textPrimary,
                      side: const BorderSide(
                        color: PremiumSaaSTheme.lightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : null;

            final primaryButton = FilledButton.icon(
              onPressed: isLoading ? null : onPrimary,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PremiumSaaSTheme.lightSurface,
                      ),
                    )
                  : Icon(primaryIcon, size: 18),
              label: Text(primaryLabel),
              style: FilledButton.styleFrom(
                backgroundColor: PremiumSaaSTheme.primaryPurple,
                foregroundColor: PremiumSaaSTheme.lightSurface,
                disabledBackgroundColor:
                    PremiumSaaSTheme.primaryPurple.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CVFormStepShell.maxContentWidth + 48,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: narrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Step ${currentStep + 1} of $totalSteps · $stepTitle',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: PremiumSaaSTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            if (previousButton != null) ...[
                              previousButton,
                              const SizedBox(height: 8),
                            ],
                            primaryButton,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Step ${currentStep + 1} of $totalSteps',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PremiumSaaSTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stepTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: PremiumSaaSTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (previousButton != null) ...[
                              previousButton,
                              const SizedBox(width: 12),
                            ],
                            primaryButton,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
