import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/admin_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_icon.dart';
import '../../data/models/admin_models.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(platformStatsProvider.notifier).fetch();
      ref.read(templateStatsProvider.notifier).fetch();
      ref.read(auditLogsProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(platformStatsProvider);
    final templateStatsState = ref.watch(templateStatsProvider);
    final auditLogsState = ref.watch(auditLogsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(platformStatsProvider.notifier).refresh();
        await ref.read(templateStatsProvider.notifier).fetch();
        await ref.read(auditLogsProvider.notifier).fetch();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(),
            
            const SizedBox(height: 24),
            
            // Key Metrics
            statsState.when(
              data: (stats) => stats != null ? _buildKeyMetrics(stats) : const SizedBox.shrink(),
              loading: () => _buildKeyMetricsSkeleton(),
              error: (e, _) => AppErrorState(
                message: e.toString(),
                onRetry: () => ref.read(platformStatsProvider.notifier).refresh(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Student Status Breakdown
            statsState.when(
              data: (stats) => stats != null ? _buildStudentStatusBreakdown(stats) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // Template Popularity
            templateStatsState.when(
              data: (templates) => _buildTemplatePopularity(templates),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // Pending Alerts
            statsState.when(
              data: (stats) => stats != null && stats.deletionRequestsPending > 0 
                  ? _buildPendingAlerts(stats) 
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            auditLogsState.when(
              data: (logs) => logs != null ? _buildRecentActivity(logs.results.take(5).toList()) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'morning' : now.hour < 17 ? 'afternoon' : 'evening';
    final dateString = DateFormatter.toFullFormat(now);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good $timeOfDay, Admin',
          style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(PlatformStatsModel stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Students',
                value: stats.totalStudents.toString(),
                change: '+${stats.newToday} today',
                icon: LucideIcons.users,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                label: 'CVs Generated',
                value: stats.totalGenerated.toString(),
                change: '+${stats.generatedToday} today',
                icon: LucideIcons.fileText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Downloads',
                value: stats.totalDownloads.toString(),
                change: '+${stats.generatedThisWeek} this week',
                icon: LucideIcons.download,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                label: 'Avg Completion',
                value: '${stats.averageCompletionPercentage.round()}%',
                change: 'across all students',
                icon: LucideIcons.barChart2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyMetricsSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatusBreakdown(PlatformStatsModel stats) {
    final total = stats.totalStudents;
    if (total == 0) return const SizedBox.shrink();

    final activePercentage = (stats.activeStudents / total * 100).round();
    final suspendedPercentage = (stats.suspendedStudents / total * 100).round();
    final deactivatedPercentage = (stats.deactivatedStudents / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Status',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            children: [
              _buildStatusRow('Active', stats.activeStudents, activePercentage, const Color(0xFF2E7D32)),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              _buildStatusRow('Suspended', stats.suspendedStudents, suspendedPercentage, const Color(0xFFE65100)),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              _buildStatusRow('Deactivated', stats.deactivatedStudents, deactivatedPercentage, const Color(0xFF9E9E9E)),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      if (stats.activeStudents > 0)
                        Expanded(
                          flex: stats.activeStudents,
                          child: Container(color: const Color(0xFF2E7D32)),
                        ),
                      if (stats.suspendedStudents > 0)
                        Expanded(
                          flex: stats.suspendedStudents,
                          child: Container(color: const Color(0xFFE65100)),
                        ),
                      if (stats.deactivatedStudents > 0)
                        Expanded(
                          flex: stats.deactivatedStudents,
                          child: Container(color: const Color(0xFF9E9E9E)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, int count, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTemplatePopularity(List<TemplateStatsModel> templates) {
    if (templates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template Popularity',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            children: templates.asMap().entries.map((entry) {
              final index = entry.key;
              final template = entry.value;
              final color = _getTemplateColor(template.template);
              
              return Column(
                children: [
                  if (index > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _buildTemplateRow(template, color),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateRow(TemplateStatsModel template, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              template.templateDisplay,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            Text(
              '${template.totalGenerated} generated',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: template.percentageOfTotal / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${template.percentageOfTotal.round()}% of all CVs',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Color _getTemplateColor(String template) {
    switch (template) {
      case 'classic':
        return AppColors.primary;
      case 'modern':
        return AppColors.success;
      case 'academic':
        return const Color(0xFF6A1B9A);
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildPendingAlerts(PlatformStatsModel stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFCC02)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertTriangle,
            color: Color(0xFFE65100),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.deletionRequestsPending} data deletion requests pending',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Students have requested account deletion',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminTabProvider.notifier).state = 1; // Switch to Students tab
              // TODO: Add filter for deletion requests
            },
            child: Text(
              'Review',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<AuditLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(adminTabProvider.notifier).state = 3,
              child: Text(
                'View All',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            children: logs.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              
              return Column(
                children: [
                  if (index > 0) const Divider(),
                  _buildActivityRow(log),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(AuditLogModel log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          ActionIcon(action: log.action),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.actionDisplay,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.studentName} • ${log.timeAgo}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}