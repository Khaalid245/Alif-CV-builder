import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/admin_provider.dart';
import '../widgets/status_badge.dart';
import '../../data/models/admin_models.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentDetailProvider(widget.studentId).notifier).fetch(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentDetailProvider(widget.studentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          studentState.value?.fullName ?? 'Student Detail',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          studentState.when(
            data: (student) => student != null ? _buildPopupMenu(student) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: studentState.when(
        data: (student) => student != null 
            ? _buildStudentDetail(student)
            : const Center(child: Text('Student not found')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading student: $error',
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(AdminStudentDetailModel student) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.textPrimary),
      onSelected: (value) => _handleMenuAction(value, student),
      itemBuilder: (context) => [
        if (student.status == 'active') ...[
          const PopupMenuItem(
            value: 'suspend',
            child: Text('Suspend Account'),
          ),
          const PopupMenuItem(
            value: 'deactivate',
            child: Text('Deactivate Account'),
          ),
        ],
        if (student.status == 'suspended' || student.status == 'deactivated') ...[
          const PopupMenuItem(
            value: 'activate',
            child: Text('Activate Account'),
          ),
        ],
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          enabled: student.deletionRequested,
          child: Text(
            'Process Deletion',
            style: TextStyle(
              color: student.deletionRequested ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDetail(AdminStudentDetailModel student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Identity
          _buildStudentIdentity(student),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Account Info
          _buildAccountInfo(student),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Consent & Compliance
          _buildConsentCompliance(student),
          
          const SizedBox(height: AppSpacing.lg),
          
          // CV Profile Summary
          _buildCVProfileSummary(student),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Generated CVs History
          _buildGeneratedCVsHistory(student),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Status Management
          if (student.status == 'suspended' || student.deletionRequested)
            _buildStatusManagement(student),
        ],
      ),
    );
  }

  Widget _buildStudentIdentity(AdminStudentDetailModel student) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            backgroundImage: student.photoUrl != null 
                ? NetworkImage(student.photoUrl!) 
                : null,
            child: student.photoUrl == null
                ? Text(
                    student.fullName.isNotEmpty 
                        ? student.fullName[0].toUpperCase()
                        : 'U',
                    style: AppTypography.h2.copyWith(color: AppColors.background),
                  )
                : null,
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      student.fullName,
                      style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    StatusBadge(status: student.status),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  student.email,
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'ID: ${student.studentId}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Joined ${DateFormatter.toDisplayFormat(student.createdAt)}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(AdminStudentDetailModel student) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Last Login', student.lastActiveText)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildInfoTile('CVs Generated', student.totalCvsGenerated.toString())),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildInfoTile('CV Completion', '${student.cvCompletionPercentage.round()}%')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildInfoTile('Member Since', DateFormatter.toDisplayFormat(student.createdAt))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCompliance(AdminStudentDetailModel student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent & Compliance',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            children: [
              _buildConsentRow(
                'Terms of Service accepted',
                student.termsAccepted,
                student.termsAcceptedAt,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildConsentRow(
                'Privacy Policy accepted',
                student.privacyPolicyAccepted,
                student.privacyPolicyAcceptedAt,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildConsentRow(
                'Data Processing consented',
                student.dataProcessingConsent,
                student.dataProcessingConsentAt,
              ),
              
              if (student.deletionRequested) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle, color: Color(0xFFE65100), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deletion Requested',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Requested on ${student.deletionRequestedAt != null ? DateFormatter.toDisplayFormat(student.deletionRequestedAt!) : 'Unknown'}',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsentRow(String label, bool accepted, DateTime? acceptedAt) {
    return Row(
      children: [
        Icon(
          accepted ? LucideIcons.checkCircle : LucideIcons.xCircle,
          color: accepted ? AppColors.success : AppColors.error,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          ),
        ),
        if (accepted && acceptedAt != null)
          Text(
            DateFormatter.toDisplayFormat(acceptedAt),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildCVProfileSummary(AdminStudentDetailModel student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CV Profile',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${student.cvCompletionPercentage.round()}%',
                        style: AppTypography.h1.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sections filled',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${student.sectionsFilled}/7',
                        style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              LinearProgressIndicator(
                value: student.cvCompletionPercentage / 100,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              ..._buildSectionStatusRows(student),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionStatusRows(AdminStudentDetailModel student) {
    final sections = [
      ('Education', LucideIcons.graduationCap, student.cvProfile?['education']?.isNotEmpty == true),
      ('Experience', LucideIcons.briefcase, student.cvProfile?['experience']?.isNotEmpty == true),
      ('Skills', LucideIcons.zap, student.cvProfile?['skills']?.isNotEmpty == true),
      ('Languages', LucideIcons.globe, student.cvProfile?['languages']?.isNotEmpty == true),
      ('Projects', LucideIcons.folder, student.cvProfile?['projects']?.isNotEmpty == true),
      ('Certifications', LucideIcons.award, student.cvProfile?['certifications']?.isNotEmpty == true),
      ('Summary', LucideIcons.fileText, student.cvProfile?['summary']?.isNotEmpty == true),
    ];

    return sections.map((section) {
      final (name, icon, hasData) = section;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasData ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            if (hasData)
              Text(
                'Filled',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              )
            else
              Text(
                'Not filled',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildGeneratedCVsHistory(AdminStudentDetailModel student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated CVs',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        if (student.generatedCvs.isEmpty)
          Text(
            'No CVs generated yet',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          )
        else
          ...student.generatedCvs.map((cv) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SectionCard(
              child: Row(
                children: [
                  // Template thumbnail
                  Container(
                    width: 36,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 3, width: 24, color: AppColors.primary),
                        const SizedBox(height: 3),
                        Container(height: 2, width: 28, color: AppColors.divider),
                        const SizedBox(height: 2),
                        Container(height: 2, width: 26, color: AppColors.divider),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.sm),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cv['template_display'] ?? '',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cv['generated_at'] != null 
                              ? DateFormatter.toDisplayFormat(DateTime.parse(cv['generated_at']))
                              : '',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cv['download_count'] ?? 0} downloads',
                          style: AppTypography.caption.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  
                  const Icon(LucideIcons.download, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildStatusManagement(AdminStudentDetailModel student) {
    return SectionCard(
      child: Column(
        children: [
          if (student.status == 'suspended') ...[
            Row(
              children: [
                const Icon(LucideIcons.alertCircle, color: Color(0xFFE65100), size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Suspended',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This student cannot log in or access the app',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Reactivate Account',
              onPressed: _isLoading ? null : () => _showStatusChangeDialog('active', student),
              isLoading: _isLoading,
            ),
          ],
          
          if (student.deletionRequested) ...[
            if (student.status == 'suspended') const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deletion Requested',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student has requested permanent data deletion',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Process Deletion',
              onPressed: _isLoading ? null : () => _showDeletionDialog(student),
              isLoading: _isLoading,
            ),
            const SizedBox(height: 8),
            Text(
              'This action is irreversible. Student data will be permanently anonymized.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(String action, AdminStudentDetailModel student) {
    switch (action) {
      case 'suspend':
        _showStatusChangeDialog('suspended', student);
        break;
      case 'activate':
        _showStatusChangeDialog('active', student);
        break;
      case 'deactivate':
        _showStatusChangeDialog('deactivated', student);
        break;
      case 'delete':
        if (student.deletionRequested) {
          _showDeletionDialog(student);
        }
        break;
    }
  }

  void _showStatusChangeDialog(String newStatus, AdminStudentDetailModel student) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_getStatusActionTitle(newStatus)} Account?',
          style: AppTypography.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusActionMessage(newStatus, student.fullName),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: reasonController,
              label: 'Reason (optional)',
              hint: 'e.g. Policy violation',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateStudentStatus(newStatus, reasonController.text);
            },
            child: Text(
              _getStatusActionTitle(newStatus),
              style: AppTypography.body.copyWith(
                color: newStatus == 'suspended' ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletionDialog(AdminStudentDetailModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Process Data Deletion',
          style: AppTypography.h3,
        ),
        content: Text(
          'This will permanently anonymize all data for ${student.fullName}. This cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processDeletion();
            },
            child: Text(
              'Yes, Delete Data',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusActionTitle(String status) {
    switch (status) {
      case 'active':
        return 'Activate';
      case 'suspended':
        return 'Suspend';
      case 'deactivated':
        return 'Deactivate';
      default:
        return 'Update';
    }
  }

  String _getStatusActionMessage(String status, String name) {
    switch (status) {
      case 'active':
        return 'This will allow $name to access their account again.';
      case 'suspended':
        return 'This will prevent $name from logging in or accessing the app.';
      case 'deactivated':
        return 'This will deactivate $name\'s account.';
      default:
        return 'This will update the account status.';
    }
  }

  Future<void> _updateStudentStatus(String status, String? reason) async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(studentDetailProvider(widget.studentId).notifier)
          .updateStatus(widget.studentId, status, reason);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account status updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processDeletion() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(studentDetailProvider(widget.studentId).notifier)
          .processDeletion(widget.studentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student data has been anonymized'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Navigate back to students list
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process deletion: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}