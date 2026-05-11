import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/auth_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cv/presentation/providers/cv_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(cvProfileProvider).valueOrNull;
    final fullName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : user?.fullName ?? 'Student';
    final email =
        profile?.email.isNotEmpty == true ? profile!.email : user?.email ?? '';
    final studentId = profile?.studentId.isNotEmpty == true
        ? profile!.studentId
        : user?.studentId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Account',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              fullName: fullName,
              email: email,
              studentId: studentId,
              photoUrl: profile?.photoUrl,
            ),
            const SizedBox(height: 24),
            const _GroupLabel('Security'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountSettingsTile(
                    icon: LucideIcons.lock,
                    title: 'Change password',
                    showArrow: true,
                    onTap: () => context.go('/account/change-password'),
                  ),
                  const _TileDivider(),
                  const AccountSettingsTile(
                    icon: LucideIcons.mailCheck,
                    iconColor: AppColors.success,
                    title: 'Email verified',
                    trailing: _StatusBadge(text: 'Verified'),
                  ),
                  const _TileDivider(),
                  AccountSettingsTile(
                    icon: LucideIcons.smartphone,
                    title: 'Active sessions',
                    subtitle: '2 devices',
                    showArrow: true,
                    onTap: () => _showSessionsSheet(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _GroupLabel('Privacy & Legal'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountSettingsTile(
                    icon: LucideIcons.shield,
                    title: 'Privacy Policy',
                    showArrow: true,
                    onTap: () => context.go('/privacy'),
                  ),
                  const _TileDivider(),
                  AccountSettingsTile(
                    icon: LucideIcons.fileText,
                    title: 'Terms of Service',
                    showArrow: true,
                    onTap: () => context.go('/terms'),
                  ),
                  const _TileDivider(),
                  AccountSettingsTile(
                    icon: LucideIcons.clipboardCheck,
                    title: 'Consent history',
                    subtitle:
                        'Terms accepted ${_formatDate(user?.termsConsentDate)}',
                    showArrow: true,
                    onTap: () => _showConsentSheet(context, user),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _GroupLabel('Account'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountSettingsTile(
                    icon: LucideIcons.logOut,
                    title: 'Sign out',
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                  const _TileDivider(),
                  AccountSettingsTile(
                    icon: LucideIcons.trash2,
                    iconColor: AppColors.error,
                    title: 'Delete my account',
                    titleColor: AppColors.error,
                    onTap: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'not recorded';
    return DateFormatter.toDisplayFormat(date);
  }

  static Future<void> _showSessionsSheet(
      BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetRow(
              title: 'Current device',
              subtitle: 'Active now',
              icon: LucideIcons.smartphone,
            ),
            const _SheetRow(
              title: 'Other device',
              subtitle: 'Last seen 2 days ago',
              icon: LucideIcons.monitor,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).logoutAll();
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  if (context.mounted) {
                    SnackbarHelper.showSuccess(
                      context,
                      'Signed out all other devices.',
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    SnackbarHelper.showError(context, error.toString());
                  }
                }
              },
              child: Text(
                'Sign out all other devices',
                style: AppTypography.body.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showConsentSheet(BuildContext context, user) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConsentRow(
              title: 'Terms of Service',
              timestamp: 'Accepted ${_formatDate(user?.termsConsentDate)}',
            ),
            _ConsentRow(
              title: 'Privacy Policy',
              timestamp: 'Accepted ${_formatDate(user?.termsConsentDate)}',
            ),
            _ConsentRow(
              title: 'Data Processing',
              timestamp:
                  'Accepted ${_formatDate(user?.dataProcessingConsentDate)}',
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmSignOut(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to access your CVs.',
      confirmText: 'Sign out',
      cancelText: 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      await logoutUser(ref, context);
    }
  }

  static Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete account?',
      message:
          'All your CV data will be permanently removed within 30 days. This cannot be undone.',
      confirmText: 'Yes, delete my account',
      cancelText: 'Keep my account',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      await ref.read(authRepositoryProvider).requestDeletion();
      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Deletion request submitted. Your data will be removed within 30 days.',
        );
        await logoutUser(ref, context);
      }
    } catch (error) {
      if (context.mounted) SnackbarHelper.showError(context, error.toString());
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String studentId;
  final String? photoUrl;

  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.studentId,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary,
          backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
          child: hasPhoto
              ? null
              : Text(
                  _initials(fullName),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          studentId.isEmpty ? email : '$email · $studentId',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.uppercase.copyWith(
          color: AppColors.textHint,
          fontSize: 10,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class AccountSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final Color titleColor;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;

  const AccountSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = const Color(0xFF4A4A4A),
    this.titleColor = AppColors.textPrimary,
    this.trailing,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showArrow)
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;

  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.success,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 60, color: AppColors.divider);
  }
}

class _SheetRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SheetRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTypography.label),
      subtitle: Text(subtitle, style: AppTypography.caption),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String title;
  final String timestamp;

  const _ConsentRow({
    required this.title,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(LucideIcons.checkCircle, color: AppColors.success),
      title: Text(title, style: AppTypography.label),
      subtitle: Text(timestamp, style: AppTypography.caption),
    );
  }
}
