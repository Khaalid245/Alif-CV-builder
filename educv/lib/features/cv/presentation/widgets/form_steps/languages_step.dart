import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
import '../level_selector.dart';
import '../step_bottom_sheet.dart';

class LanguagesStep extends ConsumerStatefulWidget {
  const LanguagesStep({super.key});

  @override
  ConsumerState<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends ConsumerState<LanguagesStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(languagesProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languagesState = ref.watch(languagesProvider);

    return languagesState.when(
      data: (languagesList) => _buildContent(languagesList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading languages: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<LanguageModel> languagesList) {
    if (languagesList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.globe,
        title: 'No languages added',
        subtitle: 'Add languages you speak and your proficiency',
        actionText: 'Add Language',
        onAction: () => _showLanguageSheet(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: languagesList.length,
            itemBuilder: (context, index) {
              final language = languagesList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildLanguageTile(language),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Language',
            onTap: () => _showLanguageSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(LanguageModel language) {
    return CVSectionTile(
      title: language.language,
      subtitle: '',
      badge: _buildProficiencyBadge(language.proficiency),
      onEdit: () => _showLanguageSheet(language: language),
      onDelete: () => _showDeleteConfirmation(language),
    );
  }

  Widget _buildProficiencyBadge(String proficiency) {
    Color backgroundColor;
    Color textColor;

    switch (proficiency) {
      case 'basic':
        backgroundColor = AppColors.divider;
        textColor = AppColors.textSecondary;
        break;
      case 'conversational':
        backgroundColor = AppColors.divider;
        textColor = AppColors.textSecondary;
        break;
      case 'professional':
        backgroundColor = const Color(0xFFE8F0FE);
        textColor = AppColors.primary;
        break;
      case 'native':
        backgroundColor = const Color(0xFF1565C0);
        textColor = AppColors.white;
        break;
      default:
        backgroundColor = AppColors.divider;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getProficiencyDisplayName(proficiency),
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getProficiencyDisplayName(String proficiency) {
    switch (proficiency) {
      case 'basic':
        return 'Basic';
      case 'conversational':
        return 'Conversational';
      case 'professional':
        return 'Professional';
      case 'native':
        return 'Native';
      default:
        return 'Conversational';
    }
  }

  void _showLanguageSheet({LanguageModel? language}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageBottomSheet(language: language),
    );
  }

  void _showDeleteConfirmation(LanguageModel language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Language', style: AppTypography.h3),
        content: Text(
          'This will permanently remove "${language.language}" from your languages.',
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
              ref.read(languagesProvider.notifier).delete(language.id);
              SnackbarHelper.showSuccess(context, 'Language removed');
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

class _LanguageBottomSheet extends ConsumerStatefulWidget {
  final LanguageModel? language;

  const _LanguageBottomSheet({this.language});

  @override
  ConsumerState<_LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends ConsumerState<_LanguageBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();

  String _selectedProficiency = 'conversational';
  bool _isLoading = false;

  final List<String> _proficiencies = ['basic', 'conversational', 'professional', 'native'];

  @override
  void initState() {
    super.initState();
    if (widget.language != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final language = widget.language!;
    _languageController.text = language.language;
    _selectedProficiency = language.proficiency;
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.language == null ? 'Add Language' : 'Edit Language',
      isLoading: _isLoading,
      onSave: _saveLanguage,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Language Name',
              hint: 'e.g. English, Arabic, French',
              controller: _languageController,
              validator: (value) => value?.isEmpty == true ? 'Language name is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Proficiency Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proficiency',
                  style: AppTypography.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                LevelSelector(
                  options: _proficiencies.map((prof) => _getProficiencyDisplayName(prof)).toList(),
                  selected: _getProficiencyDisplayName(_selectedProficiency),
                  onChanged: (displayName) {
                    final proficiency = _proficiencies.firstWhere(
                      (p) => _getProficiencyDisplayName(p) == displayName,
                    );
                    setState(() => _selectedProficiency = proficiency);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getProficiencyDisplayName(String proficiency) {
    switch (proficiency) {
      case 'basic':
        return 'Basic';
      case 'conversational':
        return 'Conversational';
      case 'professional':
        return 'Professional';
      case 'native':
        return 'Native';
      default:
        return 'Conversational';
    }
  }

  Future<void> _saveLanguage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'language': _languageController.text.trim(),
        'proficiency': _selectedProficiency,
      };

      if (widget.language == null) {
        await ref.read(languagesProvider.notifier).add(data);
        SnackbarHelper.showSuccess(context, 'Language added successfully');
      } else {
        await ref.read(languagesProvider.notifier).updateItem(widget.language!.id, data);
        SnackbarHelper.showSuccess(context, 'Language updated successfully');
      }

      Navigator.of(context).pop();
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to save language');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
