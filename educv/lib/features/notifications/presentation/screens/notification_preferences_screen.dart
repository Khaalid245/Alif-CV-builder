import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_card.dart';
import '../../data/models/notification_models.dart';
import '../providers/notification_provider.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  NotificationPreferencesModel? _preferences;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  void _loadPreferences() {
    final provider = context.read<NotificationProvider>();
    provider.loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _savePreferences,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.preferences == null) {
            return const AppLoader();
          }

          if (_preferences == null) {
            _preferences = provider.preferences;
          }

          return _buildPreferencesForm();
        },
      ),
    );
  }

  Widget _buildPreferencesForm() {
    if (_preferences == null) {
      return const AppLoader();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlobalSettings(),
          const SizedBox(height: AppSpacing.lg),
          _buildNotificationTypes(),
          const SizedBox(height: AppSpacing.lg),
          _buildDeliverySettings(),
          const SizedBox(height: AppSpacing.lg),
          _buildQuietHours(),
          const SizedBox(height: AppSpacing.xl),
          if (_hasChanges) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: 'Reset',
                    onPressed: _resetChanges,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton.primary(
                    label: 'Save Changes',
                    onPressed: _savePreferences,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalSettings() {
    return SectionCard(
      title: 'Global Settings',
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _preferences!.emailNotificationsEnabled,
            onChanged: (value) => _updatePreference(
              _preferences!.copyWith(emailNotificationsEnabled: value),
            ),
          ),
          SwitchListTile(
            title: const Text('In-App Notifications'),
            subtitle: const Text('Receive notifications within the app'),
            value: _preferences!.inAppNotificationsEnabled,
            onChanged: (value) => _updatePreference(
              _preferences!.copyWith(inAppNotificationsEnabled: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return SectionCard(
      title: 'Notification Types',
      child: Column(
        children: [
          _buildNotificationTypeSection(
            'CV Updates',
            'Notifications about CV changes and completions',
            _preferences!.cvUpdatesEmail,
            _preferences!.cvUpdatesInApp,
            (email, inApp) => _updatePreference(
              _preferences!.copyWith(
                cvUpdatesEmail: email,
                cvUpdatesInApp: inApp,
              ),
            ),
          ),
          const Divider(),
          _buildNotificationTypeSection(
            'Workflow Changes',
            'Notifications about workflow status updates',
            _preferences!.workflowChangesEmail,
            _preferences!.workflowChangesInApp,
            (email, inApp) => _updatePreference(
              _preferences!.copyWith(
                workflowChangesEmail: email,
                workflowChangesInApp: inApp,
              ),
            ),
          ),
          const Divider(),
          _buildNotificationTypeSection(
            'System Notifications',
            'Important system updates and maintenance',
            _preferences!.systemNotificationsEmail,
            _preferences!.systemNotificationsInApp,
            (email, inApp) => _updatePreference(
              _preferences!.copyWith(
                systemNotificationsEmail: email,
                systemNotificationsInApp: inApp,
              ),
            ),
          ),
          const Divider(),
          _buildNotificationTypeSection(
            'Security Alerts',
            'Important security-related notifications',
            _preferences!.securityAlertsEmail,
            _preferences!.securityAlertsInApp,
            (email, inApp) => _updatePreference(
              _preferences!.copyWith(
                securityAlertsEmail: email,
                securityAlertsInApp: inApp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeSection(
    String title,
    String description,
    bool emailEnabled,
    bool inAppEnabled,
    Function(bool email, bool inApp) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          description,
          style: AppTypography.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Email'),
                value: emailEnabled,
                onChanged: (value) => onChanged(value ?? false, inAppEnabled),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('In-App'),
                value: inAppEnabled,
                onChanged: (value) => onChanged(emailEnabled, value ?? false),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliverySettings() {
    return SectionCard(
      title: 'Delivery Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Digest Frequency',
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'How often you want to receive notification summaries',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...['immediate', 'hourly', 'daily', 'weekly', 'never'].map((frequency) {
            return RadioListTile<String>(
              title: Text(_formatDigestFrequency(frequency)),
              value: frequency,
              groupValue: _preferences!.digestFrequency,
              onChanged: (value) => _updatePreference(
                _preferences!.copyWith(digestFrequency: value),
              ),
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuietHours() {
    return SectionCard(
      title: 'Quiet Hours',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Enable Quiet Hours'),
            subtitle: const Text('Pause notifications during specified hours'),
            value: _preferences!.quietHoursEnabled,
            onChanged: (value) => _updatePreference(
              _preferences!.copyWith(quietHoursEnabled: value),
            ),
          ),
          if (_preferences!.quietHoursEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    'Start Time',
                    _preferences!.quietHoursStart,
                    (time) => _updatePreference(
                      _preferences!.copyWith(quietHoursStart: time),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTimeSelector(
                    'End Time',
                    _preferences!.quietHoursEnd,
                    (time) => _updatePreference(
                      _preferences!.copyWith(quietHoursEnd: time),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, String? time, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _selectTime(time, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    time ?? 'Select time',
                    style: AppTypography.body2.copyWith(
                      color: time != null ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectTime(String? currentTime, Function(String) onChanged) async {
    TimeOfDay? initialTime;
    
    if (currentTime != null) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      onChanged(timeString);
    }
  }

  void _updatePreference(NotificationPreferencesModel newPreferences) {
    setState(() {
      _preferences = newPreferences;
      _hasChanges = true;
    });
  }

  void _resetChanges() {
    final provider = context.read<NotificationProvider>();
    setState(() {
      _preferences = provider.preferences;
      _hasChanges = false;
    });
  }

  void _savePreferences() async {
    if (_preferences == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final provider = context.read<NotificationProvider>();
    final success = await provider.updatePreferences(_preferences!);
    
    setState(() {
      _isLoading = false;
      if (success) {
        _hasChanges = false;
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Preferences saved successfully' : 'Failed to save preferences'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  String _formatDigestFrequency(String frequency) {
    switch (frequency) {
      case 'immediate':
        return 'Immediate';
      case 'hourly':
        return 'Hourly';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'never':
        return 'Never';
      default:
        return frequency;
    }
  }
}