import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/version_models.dart';
import '../providers/version_history_provider.dart';
import '../widgets/version_comparison_dialog.dart';
import '../widgets/version_item_card.dart';
import '../widgets/version_stats_card.dart';

class VersionHistoryScreen extends StatefulWidget {
  const VersionHistoryScreen({super.key});

  @override
  State<VersionHistoryScreen> createState() => _VersionHistoryScreenState();
}

class _VersionHistoryScreenState extends State<VersionHistoryScreen> {
  final Set<int> _selectedVersions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<VersionHistoryProvider>();
    provider.loadVersionHistory();
    provider.loadVersionStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Version History'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<VersionHistoryProvider>(
            builder: (context, provider, _) {
              if (_selectedVersions.length == 2) {
                return TextButton(
                  onPressed: () => _compareVersions(provider),
                  child: const Text('Compare'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VersionHistoryProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: _buildBody(provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(VersionHistoryProvider provider) {
    switch (provider.state) {
      case VersionHistoryState.loading:
        return const AppLoader();
      
      case VersionHistoryState.error:
        return AppErrorState(
          message: provider.errorMessage ?? 'Failed to load version history',
          onRetry: _loadData,
        );
      
      case VersionHistoryState.loaded:
        if (provider.versions.isEmpty) {
          return const EmptyState(
            title: 'No Version History',
            message: 'No versions found for your CV.',
            icon: Icons.history,
          );
        }
        return _buildVersionList(provider);
      
      case VersionHistoryState.initial:
        return const AppLoader();
    }
  }

  Widget _buildVersionList(VersionHistoryProvider provider) {
    return Column(
      children: [
        if (provider.stats != null) ...[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: VersionStatsCard(stats: provider.stats!),
          ),
        ],
        if (_selectedVersions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                Text(
                  '${_selectedVersions.length} version(s) selected',
                  style: AppTypography.body2,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selectedVersions.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: provider.versions.length,
            itemBuilder: (context, index) {
              final version = provider.versions[index];
              final isSelected = _selectedVersions.contains(version.versionNumber);
              
              return VersionItemCard(
                version: version,
                isSelected: isSelected,
                onTap: () => _toggleSelection(version.versionNumber),
                onRestore: () => _showRestoreDialog(provider, version),
              );
            },
          ),
        ),
      ],
    );
  }

  void _toggleSelection(int versionNumber) {
    setState(() {
      if (_selectedVersions.contains(versionNumber)) {
        _selectedVersions.remove(versionNumber);
      } else if (_selectedVersions.length < 2) {
        _selectedVersions.add(versionNumber);
      }
    });
  }

  void _compareVersions(VersionHistoryProvider provider) {
    if (_selectedVersions.length != 2) return;
    
    final versions = _selectedVersions.toList()..sort();
    provider.compareVersions(versions[0], versions[1]).then((_) {
      if (provider.comparison != null) {
        showDialog(
          context: context,
          builder: (context) => VersionComparisonDialog(
            comparison: provider.comparison!,
          ),
        );
      }
    });
  }

  void _showRestoreDialog(VersionHistoryProvider provider, CVVersionModel version) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Restore Version',
        message: 'Are you sure you want to restore your CV to version ${version.versionNumber}? This will create a new version with the restored data.',
        confirmText: 'Restore',
        onConfirm: () async {
          Navigator.of(context).pop();
          final success = await provider.restoreVersion(version.versionNumber);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('CV restored to version ${version.versionNumber}'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? 'Failed to restore version'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }
}