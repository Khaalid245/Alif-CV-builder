import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../providers/admin_provider.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/action_icon.dart';
import '../widgets/date_header.dart';
import '../widgets/pagination_loader.dart';
import '../../data/models/admin_models.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedAction = 'all';
  bool _securityOnly = false;
  String? _fromDate;
  String? _toDate;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auditLogsProvider.notifier).fetch();
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    final logsState = ref.read(auditLogsProvider);
    if (logsState.value?.hasMore != true) return;

    setState(() => _isLoadingMore = true);
    await ref.read(auditLogsProvider.notifier).loadMore();
    setState(() => _isLoadingMore = false);
  }

  void _onActionChanged(String action) {
    setState(() => _selectedAction = action);
    _applyFilters();
  }

  void _applyFilters() {
    ref.read(auditLogsProvider.notifier).fetch(
      action: _selectedAction == 'all' ? null : _selectedAction,
      fromDate: _fromDate,
      toDate: _toDate,
      securityOnly: _securityOnly,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedAction: _selectedAction,
        securityOnly: _securityOnly,
        fromDate: _fromDate,
        toDate: _toDate,
        onApply: (action, security, from, to) {
          setState(() {
            _selectedAction = action;
            _securityOnly = security;
            _fromDate = from;
            _toDate = to;
          });
          _applyFilters();
        },
        onReset: () {
          setState(() {
            _selectedAction = 'all';
            _securityOnly = false;
            _fromDate = null;
            _toDate = null;
          });
          ref.read(auditLogsProvider.notifier).resetFilters();
          ref.read(auditLogsProvider.notifier).fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(auditLogsProvider);

    return Column(
      children: [
        // Action filter row
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: FilterChipRow(
            options: const ['All', 'Login', 'Register', 'CV Generated', 'PDF Downloaded', 'Password Changed', 'Account Deleted', 'Suspended'],
            selected: _selectedAction,
            onChanged: _onActionChanged,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Logs list
        Expanded(
          child: logsState.when(
            data: (response) => response != null 
                ? _buildLogsList(response)
                : const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(auditLogsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList(PaginatedResponse<AuditLogModel> response) {
    if (response.results.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.clipboardList,
        title: 'No logs found',
        subtitle: 'Try adjusting your filters',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(auditLogsProvider.notifier).fetch(
        action: _selectedAction == 'all' ? null : _selectedAction,
        fromDate: _fromDate,
        toDate: _toDate,
        securityOnly: _securityOnly,
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _calculateItemCount(response.results) + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          return _buildListItem(response.results, index);
        },
      ),
    );
  }

  int _calculateItemCount(List<AuditLogModel> logs) {
    if (logs.isEmpty) return 0;
    
    int count = logs.length;
    DateTime? lastDate;
    
    for (final log in logs) {
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (lastDate == null || !_isSameDay(logDate, lastDate)) {
        count++; // Add date header
        lastDate = logDate;
      }
    }
    
    return count;
  }

  Widget _buildListItem(List<AuditLogModel> logs, int index) {
    if (index >= _calculateItemCount(logs)) {
      return const PaginationLoader();
    }
    
    int logIndex = 0;
    int currentIndex = 0;
    DateTime? lastDate;
    
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      
      // Check if we need a date header
      if (lastDate == null || !_isSameDay(logDate, lastDate)) {
        if (currentIndex == index) {
          return DateHeader(date: logDate);
        }
        currentIndex++;
        lastDate = logDate;
      }
      
      // Check if this is the log we want
      if (currentIndex == index) {
        return _buildAuditLogTile(log, i < logs.length - 1);
      }
      currentIndex++;
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildAuditLogTile(AuditLogModel log, bool showDivider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              ActionIcon(action: log.action),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          log.actionDisplay,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          log.timeAgo,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.studentName} (${log.studentId})',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    if (log.extraDataSummary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        log.extraDataSummary,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String selectedAction;
  final bool securityOnly;
  final String? fromDate;
  final String? toDate;
  final Function(String, bool, String?, String?) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.selectedAction,
    required this.securityOnly,
    required this.fromDate,
    required this.toDate,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedAction;
  late bool _securityOnly;
  late String? _fromDate;
  late String? _toDate;
  
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAction = widget.selectedAction;
    _securityOnly = widget.securityOnly;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    
    _fromController.text = _fromDate ?? '';
    _toController.text = _toDate ?? '';
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Filter Logs',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Action Type
          Text(
            'Action Type',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ['All', 'Login', 'Register', 'CV Generated', 'PDF Downloaded', 'Password Changed', 'Account Deleted', 'Suspended']
                .map((action) => FilterChip(
                  label: Text(action),
                  selected: action.toLowerCase() == _selectedAction,
                  onSelected: (_) => setState(() => _selectedAction = action.toLowerCase()),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primaryLight,
                  side: BorderSide(
                    color: action.toLowerCase() == _selectedAction ? AppColors.primary : AppColors.divider,
                    width: action.toLowerCase() == _selectedAction ? 1.5 : 1,
                  ),
                  labelStyle: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: action.toLowerCase() == _selectedAction ? AppColors.primary : AppColors.textSecondary,
                  ),
                  showCheckmark: false,
                ))
                .toList(),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Security Only
          Row(
            children: [
              Text(
                'Show security events only',
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Switch(
                value: _securityOnly,
                onChanged: (value) => setState(() => _securityOnly = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Date Range
          Text(
            'Date Range',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _fromController,
                  label: 'From Date',
                  hint: 'YYYY-MM-DD',
                  onChanged: (value) => _fromDate = value.isEmpty ? null : value,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppInput(
                  controller: _toController,
                  label: 'To Date',
                  hint: 'YYYY-MM-DD',
                  onChanged: (value) => _toDate = value.isEmpty ? null : value,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Reset',
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onReset();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  text: 'Apply',
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onApply(_selectedAction, _securityOnly, _fromDate, _toDate);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
