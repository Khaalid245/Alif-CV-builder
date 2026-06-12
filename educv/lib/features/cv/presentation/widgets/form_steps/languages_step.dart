import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../data/models/cv_models.dart';
import '../../providers/cv_provider.dart';
import '../cv_section_tile.dart';
import '../level_selector.dart';
import '../step_bottom_sheet.dart';

class LanguagesStep extends ConsumerStatefulWidget {
  const LanguagesStep({super.key});

  @override
  ConsumerState<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends ConsumerState<LanguagesStep> {
  @override
  Widget build(BuildContext context) {
    final languagesState = ref.watch(languagesProvider);

    return languagesState.when(
      data: (languagesList) => languagesList.isEmpty
          ? _buildEmptyState()
          : _buildLanguagesList(languagesList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load languages. Please try again.',
            style: TextStyle(
              fontSize: 14,
              color: PremiumPortfolioColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PremiumPortfolioColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.globe,
            size: 32,
            color: PremiumPortfolioColors.accentPurple.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'No languages yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showLanguageSheet(),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add language'),
            style: FilledButton.styleFrom(
              backgroundColor: PremiumPortfolioColors.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesList(List<LanguageModel> languagesList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...languagesList.map(
          (language) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLanguageTile(language),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showLanguageSheet(),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add another language'),
          style: OutlinedButton.styleFrom(
            foregroundColor: PremiumPortfolioColors.accentPurple,
            side: const BorderSide(color: PremiumPortfolioColors.accentPurple),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    late Color backgroundColor;
    late Color textColor;

    switch (proficiency) {
      case 'professional':
        backgroundColor = PremiumPortfolioColors.accentBlue.withOpacity(0.12);
        textColor = PremiumPortfolioColors.accentBlue;
        break;
      case 'native':
        backgroundColor = PremiumPortfolioColors.accentPurple;
        textColor = Colors.white;
        break;
      case 'basic':
      case 'conversational':
      default:
        backgroundColor = PremiumPortfolioColors.borderLight;
        textColor = PremiumPortfolioColors.secondaryText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getProficiencyDisplayName(proficiency),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
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
        title: Text(
          'Remove language',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        content: Text(
          'Remove "${language.language}" from your CV?',
          style: TextStyle(
            fontSize: 14,
            color: PremiumPortfolioColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: PremiumPortfolioColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(languagesProvider.notifier).delete(language.id);
              SnackbarHelper.showSuccess(context, 'Language removed');
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: PremiumPortfolioColors.error),
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
  ConsumerState<_LanguageBottomSheet> createState() =>
      _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends ConsumerState<_LanguageBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();

  String _selectedProficiency = 'conversational';
  bool _isLoading = false;

  final List<String> _proficiencies = [
    'basic',
    'conversational',
    'professional',
    'native',
  ];

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
              label: 'Language name',
              hint: 'e.g. English, Arabic, French',
              controller: _languageController,
              validator: (value) =>
                  value?.isEmpty == true ? 'Language name is required' : null,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proficiency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                LevelSelector(
                  options: _proficiencies
                      .map((prof) => _getProficiencyDisplayName(prof))
                      .toList(),
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
        if (!mounted) return;
        Navigator.of(context).pop();
        SnackbarHelper.showSuccess(context, 'Language added');
      } else {
        await ref
            .read(languagesProvider.notifier)
            .updateItem(widget.language!.id, data);
        if (!mounted) return;
        Navigator.of(context).pop();
        SnackbarHelper.showSuccess(context, 'Language updated');
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Failed to save language');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
