import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../providers/cv_provider.dart';
import '../../../data/models/cv_models.dart';
import '../cv_section_tile.dart';
import '../add_item_button.dart';
import '../step_bottom_sheet.dart';
import '../month_year_picker.dart';

class CertificationsStep extends ConsumerWidget {
  const CertificationsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificationsAsync = ref.watch(certificationsProvider);
    
    return certificationsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (certifications) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (certifications.isEmpty)
              EmptyState(
                icon: Icons.emoji_events,
                title: 'No certifications added',
                subtitle: 'Add professional certificates and courses',
                actionLabel: 'Add Certification',
                onAction: () => _showCertificationSheet(context, ref),
              )
            else ...[
              ...certifications.map((cert) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _CertificationTile(
                  certification: cert,
                  onEdit: () => _showCertificationSheet(context, ref, certification: cert),
                  onDelete: () => _showDeleteConfirmation(context, ref, cert),
                ),
              )),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Certification',
              onTap: () => _showCertificationSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showCertificationSheet(BuildContext context, WidgetRef ref, {CertificationModel? certification}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CertificationBottomSheet(
        certification: certification,
        onSave: (data) async {
          try {
            if (certification != null) {
              await ref.read(certificationsProvider.notifier).updateCertification(certification.id, data);
            } else {
              await ref.read(certificationsProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving certification: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, CertificationModel certification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Certification'),
        content: Text('This will permanently remove this certification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(certificationsProvider.notifier).delete(certification.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting certification: $e')),
                );
              }
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  final CertificationModel certification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CertificationTile({
    required this.certification,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isExpired() {
    if (certification.expiryDate == null) return false;
    return certification.expiryDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        certification.name,
                        style: AppTypography.h3,
                      ),
                    ),
                    if (_isExpired()) ...[
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Expired',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.xs),
          
          Text(
            certification.issuer,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          SizedBox(height: AppSpacing.xs),
          
          Text(
            'Issued: ${_formatDate(certification.issueDate)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          if (certification.expiryDate != null) ...[
            Text(
              'Expires: ${_formatDate(certification.expiryDate!)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            Text(
              'No Expiry',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          if (certification.credentialUrl != null) ...[
            SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(certification.credentialUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'View Credential',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CertificationBottomSheet extends StatefulWidget {
  final CertificationModel? certification;
  final Function(Map<String, dynamic>) onSave;

  const _CertificationBottomSheet({
    this.certification,
    required this.onSave,
  });

  @override
  State<_CertificationBottomSheet> createState() => _CertificationBottomSheetState();
}

class _CertificationBottomSheetState extends State<_CertificationBottomSheet> {
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
      final cert = widget.certification!;
      _nameController.text = cert.name;
      _issuerController.text = cert.issuer;
      _credentialUrlController.text = cert.credentialUrl ?? '';
      _issueDate = cert.issueDate;
      _expiryDate = cert.expiryDate;
      _noExpiry = cert.expiryDate == null;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an issue date')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final data = {
      'name': _nameController.text.trim(),
      'issuer': _issuerController.text.trim(),
      'issue_date': _issueDate!.toIso8601String().split('T')[0],
      'expiry_date': _noExpiry ? null : _expiryDate?.toIso8601String().split('T')[0],
      'credential_url': _credentialUrlController.text.trim(),
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.certification != null ? 'Edit Certification' : 'Add Certification',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Certification Name',
              hint: 'e.g. AWS Solutions Architect',
              controller: _nameController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Certification name is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Issuing Organization',
              hint: 'e.g. Amazon Web Services',
              controller: _issuerController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Issuing organization is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Issue Date',
              value: _issueDate,
              onChanged: (date) {
                setState(() {
                  _issueDate = date;
                });
              },
              isRequired: true,
            ),
            
            SizedBox(height: AppSpacing.md),
            
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
              SizedBox(height: AppSpacing.md),
              
              MonthYearPicker(
                label: 'Expiry Date',
                value: _expiryDate,
                onChanged: (date) {
                  setState(() {
                    _expiryDate = date;
                  });
                },
                isRequired: !_noExpiry,
              ),
            ],
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Credential URL (Optional)',
              hint: 'Link to your certificate online',
              controller: _credentialUrlController,
              keyboardType: TextInputType.url,
              validator: _validateUrl,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }
}
