import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ToastType { success, error, warning, info, loading }

class EnterpriseToast {
  static OverlayEntry? _currentToast;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (_isShowing) {
      hide();
    }

    _isShowing = true;
    final overlay = Overlay.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: hide,
      ),
    );

    overlay.insert(_currentToast!);

    // Auto-hide after duration (except for loading toasts)
    if (type != ToastType.loading) {
      Future.delayed(duration, () {
        hide();
      });
    }
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void loading(
    BuildContext context,
    String message,
  ) {
    show(
      context,
      message: message,
      type: ToastType.loading,
    );
  }

  static void hide() {
    if (_currentToast != null) {
      _currentToast!.remove();
      _currentToast = null;
      _isShowing = false;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: widget.type == ToastType.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _getIcon(),
                            color: Colors.white,
                            size: 18,
                          ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Message
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Action Button
                  if (widget.actionLabel != null &&
                      widget.onAction != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        widget.onAction!();
                        widget.onDismiss();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusBtn),
                        ),
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Close Button
                  if (widget.type != ToastType.loading) ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
      case ToastType.loading:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return LucideIcons.checkCircle;
      case ToastType.error:
        return LucideIcons.alertCircle;
      case ToastType.warning:
        return LucideIcons.alertTriangle;
      case ToastType.info:
        return LucideIcons.info;
      case ToastType.loading:
        return LucideIcons.loader;
    }
  }
}

// Convenience extension for easy access
extension ToastExtension on BuildContext {
  void showSuccessToast(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    EnterpriseToast.success(this, message,
        actionLabel: actionLabel, onAction: onAction);
  }

  void showErrorToast(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    EnterpriseToast.error(this, message,
        actionLabel: actionLabel, onAction: onAction);
  }

  void showWarningToast(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    EnterpriseToast.warning(this, message,
        actionLabel: actionLabel, onAction: onAction);
  }

  void showInfoToast(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    EnterpriseToast.info(this, message,
        actionLabel: actionLabel, onAction: onAction);
  }

  void showLoadingToast(String message) {
    EnterpriseToast.loading(this, message);
  }

  void hideToast() {
    EnterpriseToast.hide();
  }
}
