import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      title: Text(
        title,
        style: AppTypography.h2,
      ),
      content: Text(
        message,
        style: AppTypography.body,
      ),
      actions: [
        AppButton(
          text: cancelText,
          variant: AppButtonVariant.text,
          onPressed: () {
            if (onCancel != null) {
              onCancel!.call();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          text: confirmText,
          variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
          onPressed: () {
            onConfirm();
          },
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Delete $itemName',
      message: 'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: onConfirm,
      onCancel: () => Navigator.of(context).pop(false),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String itemName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: itemName,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
