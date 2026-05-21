import 'package:flutter/material.dart';

class TransitionConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const TransitionConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransitionConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }
}