import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../level_selector.dart';

class LanguagesStep extends ConsumerWidget {
  const LanguagesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(languagesProvider);
    
    return languagesAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (languages) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (languages.isEmpty)
              EmptyState(
                icon: Icons.language,
                title: 'No languages added',
                subtitle: 'Add languages you speak and your proficiency',
                actionLabel: 'Add Language',
                onAction: () => _showLanguageSheet(context, ref),
              )
            else ...[
              ...languages.map((language) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: CVSectionTile(
                  title: language.language,
                  badge: _ProficiencyBadge(proficiency: language.proficiency),
                  onEdit: () => _showLanguageSheet(context, ref, language: language),
                  onDelete: () => _showDeleteConfirmation(context, ref, language),
                ),
              )),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Language',
              onTap: () => _showLanguageSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref, {LanguageModel? language}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageBottomSheet(
        language: language,
        onSave: (data) async {
          try {
            if (language != null) {
              await ref.read(languagesProvider.notifier).updateLanguage(language.id, data);
            } else {
              await ref.read(languagesProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving language: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, LanguageModel language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Language'),
        content: Text('This will permanently remove this language.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(languagesProvider.notifier).delete(language.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting language: $e')),
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

class _ProficiencyBadge extends StatelessWidget {
  final String proficiency;

  const _ProficiencyBadge({required this.proficiency});

  Color _getBadgeColor() {
    switch (proficiency.toLowerCase()) {
      case 'native':
        return AppColors.primary;
      case 'professional':
        return Color(0xFFE8F0FE);
      case 'conversational':
      case 'basic':
      default:
        return AppColors.surface;
    }
  }

  Color _getTextColor() {
    switch (proficiency.toLowerCase()) {
      case 'native':
        return Colors.white;
      case 'professional':
        return AppColors.primary;
      case 'conversational':
      case 'basic':
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        proficiency,
        style: AppTypography.caption.copyWith(
          color: _getTextColor(),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LanguageBottomSheet extends StatefulWidget {
  final LanguageModel? language;
  final Function(Map<String, dynamic>) onSave;

  const _LanguageBottomSheet({
    this.language,
    required this.onSave,
  });

  @override
  State<_LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<_LanguageBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();
  
  String _selectedProficiency = 'basic';
  bool _isLoading = false;

  final Map<String, String> _proficiencyLevels = {
    'basic': 'Basic',
    'conversational': 'Conversational',
    'professional': 'Professional',
    'native': 'Native',
  };

  @override
  void initState() {
    super.initState();
    if (widget.language != null) {
      final language = widget.language!;
      _languageController.text = language.language;
      _selectedProficiency = language.proficiency;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'language': _languageController.text.trim(),
      'proficiency': _selectedProficiency,
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.language != null ? 'Edit Language' : 'Add Language',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Language Name',
              hint: 'e.g. English, Arabic, French',
              controller: _languageController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Language name is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proficiency',
                  style: AppTypography.label,
                ),
                SizedBox(height: AppSpacing.sm),
                
                LevelSelector(
                  options: _proficiencyLevels.values.toList(),
                  selected: _proficiencyLevels[_selectedProficiency] ?? 'Basic',
                  onChanged: (proficiency) {
                    setState(() {
                      _selectedProficiency = _proficiencyLevels.entries
                          .firstWhere((entry) => entry.value == proficiency)
                          .key;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }
}
