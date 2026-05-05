import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../data/models/cv_models.dart';
import '../../providers/cv_provider.dart';
import '../add_item_button.dart';
import '../cv_section_tile.dart';
import '../empty_state.dart';
import '../month_year_picker.dart';
import '../step_bottom_sheet.dart';

class CertificationsStep extends ConsumerStatefulWidget {
  const CertificationsStep({super.key});

  @override
  ConsumerState<CertificationsStep> createState() => _CertificationsStepState();
}

class _CertificationsStepState extends ConsumerState<CertificationsStep> {
  @override
  void initState() {
    super.initState();
    // Data is pre-populated from cvProfileProvider.fetch() — no separate API call needed
  }

  @override
  Widget build(BuildContext context) {
    final certificationsState = ref.watch(certificationsProvider);

    return certificationsState.when(
      data: (certificationsList) => _buildContent(certificationsList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading certifications: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<CertificationModel> certificationsList) {
    if (certificationsList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.award,
        title: 'No certifications added',
        subtitle: 'Add professional certificates and courses',
        actionText: 'Add Certification',
        onAction: () => _showCertificationSheet(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: certificationsList.length,
            itemBuilder: (context, index) {
              final certification = certificationsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildCertificationTile(certification),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Certification',
            onTap: () => _showCertificationSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationTile(CertificationModel certification) {
    final issueDate = DateFormat('MMM yyyy').format(certification.issueDate);
    final isExpired = certification.expiryDate != null && 
        certification.expiryDate!.isBefore(DateTime.now());
    
    String dateText = 'Issued: $issueDate';
    if (certification.expiryDate != null) {
      final expiryDate = DateFormat('MMM yyyy').format(certification.expiryDate!);
      dateText += '\nExpires: $expiryDate';
    } else {
      dateText += '\nNo Expiry';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: CVSectionTile(
        title: certification.name,
        subtitle: certification.issuer,
        trailing: dateText,
        badge: isExpired ? _buildExpiredBadge() : null,
        onEdit: () => _showCertificationSheet(certification: certification),
        onDelete: () => _showDeleteConfirmation(certification),
      ),
    );
  }

  Widget _buildExpiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Expired',
        style: AppTypography.caption.copyWith(
          color: AppColors.error,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showCertificationSheet({CertificationModel? certification}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CertificationBottomSheet(certification: certification),
    );
  }

  void _showDeleteConfirmation(CertificationModel certification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Certification', style: AppTypography.h3),
        content: Text(
          'This will permanently remove "${certification.name}" from your certifications.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(certificationsProvider.notifier).delete(certification.id);
              SnackbarHelper.showSuccess(context, 'Certification removed');
            },
            child: Text(
              'Remove',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationBottomSheet extends ConsumerStatefulWidget {
  final CertificationModel? certification;

  const _CertificationBottomSheet({this.certification});

  @override
  ConsumerState<_CertificationBottomSheet> createState() => _CertificationBottomSheetState();
}

class _CertificationBottomSheetState extends ConsumerState<_CertificationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _credentialUrlController = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _noExpiry = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.certification != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final certification = widget.certification!;
    _nameController.text = certification.name;
    _issuerController.text = certification.issuer;
    _credentialUrlController.text = certification.credentialUrl;
    _issueDate = certification.issueDate;
    _expiryDate = certification.expiryDate;
    _noExpiry = certification.expiryDate == null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.certification == null ? 'Add Certification' : 'Edit Certification',
      isLoading: _isLoading,
      onSave: _saveCertification,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Certification Name',
              hint: 'e.g. AWS Solutions Architect',
              controller: _nameController,
              validator: (value) => value?.isEmpty == true ? 'Certification name is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Issuing Organization',
              hint: 'e.g. Amazon Web Services',
              controller: _issuerController,
              validator: (value) => value?.isEmpty == true ? 'Issuing organization is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Issue Date',
              selectedDate: _issueDate,
              onChanged: (date) => setState(() => _issueDate = date),
              validator: (value) => _issueDate == null ? 'Issue date is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // No Expiry Toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This certification does not expire',
                    style: AppTypography.body,
                  ),
                ),
                Switch.adaptive(
                  value: _noExpiry,
                  onChanged: (value) {
                    setState(() {
                      _noExpiry = value;
                      if (value) {
                        _expiryDate = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            
            if (!_noExpiry) ...[
              const SizedBox(height: AppSpacing.md),
              MonthYearPicker(
                label: 'Expiry Date',
                selectedDate: _expiryDate,
                onChanged: (date) => setState(() => _expiryDate = date),
                validator: (value) => !_noExpiry && _expiryDate == null ? 'Expiry date is required' : null,
              ),
            ],
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Credential URL (Optional)',
              hint: 'Link to your certificate online',
              controller: _credentialUrlController,
              keyboardType: TextInputType.url,
              prefixIcon: const Icon(
                LucideIcons.link,
                color: AppColors.textSecondary,
              ),
              validator: _validateUrl,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    String url = value;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
    if (!RegExp(urlPattern).hasMatch(url)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Future<void> _saveCertification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issueDate == null) return;
    if (!_noExpiry && _expiryDate == null) return;

    setState(() => _isLoading = true);

    try {
      String credentialUrl = _credentialUrlController.text.trim();
      if (credentialUrl.isNotEmpty && !credentialUrl.startsWith('http://') && !credentialUrl.startsWith('https://')) {
        credentialUrl = 'https://$credentialUrl';
      }

      final data = {
        'name': _nameController.text.trim(),
        'issuer': _issuerController.text.trim(),
        'issue_date': _issueDate!.toIso8601String().split('T')[0],
        'expiry_date': _noExpiry ? null : _expiryDate?.toIso8601String().split('T')[0],
        'credential_url': credentialUrl,
      };

      if (widget.certification == null) {
        await ref.read(certificationsProvider.notifier).add(data);
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, 'Certification added successfully');
      } else {
        await ref.read(certificationsProvider.notifier).updateItem(widget.certification!.id, data);
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, 'Certification updated successfully');
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Failed to save certification');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
