import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../../../core/widgets/enterprise_validation.dart';
import '../../../../../core/widgets/enterprise_api_handler.dart';
import '../../../../../core/widgets/enterprise_toast.dart';
import 'package:educv/features/auth/presentation/providers/auth_provider.dart';
import '../../providers/cv_provider.dart';
import '../section_divider.dart';
import '../target_role_picker.dart';

class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep>
    with RealTimeValidation {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _summaryController = TextEditingController();

  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    // Register save function so cv_form_screen can call it on Next
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvFormSaveProvider.notifier).state = _saveData;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final profile = ref.read(cvProfileProvider).value;
    if (profile != null) {
      _phoneController.text = profile.phone;
      _cityController.text = profile.city;
      _countryController.text = profile.country;
      _linkedinController.text = profile.linkedin;
      _githubController.text = profile.github;
      _portfolioController.text = profile.portfolio;
      _summaryController.text = profile.summary;
    }
  }

  ImageProvider? _getImageProvider(String? photoUrl) {
    if (_selectedPhoto != null) {
      return FileImage(_selectedPhoto!) as ImageProvider;
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl) as ImageProvider;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final cvProfile = ref.watch(cvProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfilePhotoSection(cvProfile.value?.photoUrl),

            const SizedBox(height: AppSpacing.xl),

            const SectionDivider(label: 'Basic Information'),
            const SizedBox(height: AppSpacing.lg),

            // Full Name — read-only, sourced from auth
            AppInput(
              label: 'Full Name',
              hint: 'Your full name',
              controller:
                  TextEditingController(text: currentUser?.fullName ?? ''),
              enabled: false,
              suffixIcon: const Icon(LucideIcons.lock,
                  color: AppColors.textHint, size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'To change your name contact admin',
              style: AppTypography.caption.copyWith(color: AppColors.textHint),
            ),

            const SizedBox(height: AppSpacing.md),

            // Phone Number with real-time validation
            EnterpriseValidatedInput(
              label: 'Phone Number',
              hint: '+1 234 567 8900',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: EnterpriseValidators.phone,
              onValidationChanged: (result) =>
                  updateValidation('phone', result),
            ),

            const SizedBox(height: AppSpacing.md),

            // City with validation
            EnterpriseValidatedInput(
              label: 'City',
              hint: 'e.g. New York',
              controller: _cityController,
              validator: (value) =>
                  EnterpriseValidators.required(value, 'City'),
              onValidationChanged: (result) => updateValidation('city', result),
            ),

            const SizedBox(height: AppSpacing.md),

            // Country with validation
            EnterpriseValidatedInput(
              label: 'Country',
              hint: 'e.g. United States',
              controller: _countryController,
              validator: (value) =>
                  EnterpriseValidators.required(value, 'Country'),
              onValidationChanged: (result) =>
                  updateValidation('country', result),
            ),

            const SizedBox(height: AppSpacing.xl),

            const SectionDivider(label: 'Online Presence'),
            const SizedBox(height: AppSpacing.lg),

            // LinkedIn with URL validation
            EnterpriseValidatedInput(
              label: 'LinkedIn Profile',
              hint: 'linkedin.com/in/yourname',
              controller: _linkedinController,
              keyboardType: TextInputType.url,
              prefixIcon: LucideIcons.linkedin,
              validator: (value) => EnterpriseValidators.url(value),
              onValidationChanged: (result) =>
                  updateValidation('linkedin', result),
            ),

            const SizedBox(height: AppSpacing.md),

            // GitHub with URL validation
            EnterpriseValidatedInput(
              label: 'GitHub Profile',
              hint: 'github.com/yourname',
              controller: _githubController,
              keyboardType: TextInputType.url,
              prefixIcon: LucideIcons.github,
              validator: (value) => EnterpriseValidators.url(value),
              onValidationChanged: (result) =>
                  updateValidation('github', result),
            ),

            const SizedBox(height: AppSpacing.md),

            // Portfolio with URL validation
            EnterpriseValidatedInput(
              label: 'Portfolio Website',
              hint: 'yourwebsite.com',
              controller: _portfolioController,
              keyboardType: TextInputType.url,
              prefixIcon: LucideIcons.link,
              validator: (value) => EnterpriseValidators.url(value),
              onValidationChanged: (result) =>
                  updateValidation('portfolio', result),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Target Role ─────────────────────────────────────────────────
            // Ask the user what role they are targeting — drives the entire
            // AI analysis, template recommendations, and benchmarking.
            const SectionDivider(label: 'Target Role'),
            const SizedBox(height: AppSpacing.md),
            _buildRolePicker(),

            const SizedBox(height: AppSpacing.xl),

            const SectionDivider(label: 'Professional Summary'),
            const SizedBox(height: AppSpacing.lg),

            // Summary with character count validation
            EnterpriseValidatedInput(
              label: 'About You',
              hint:
                  'Write 2-3 sentences about your background, skills and career goals...',
              controller: _summaryController,
              maxLines: 5,
              validator: (value) =>
                  EnterpriseValidators.maxLength(value, 500, 'Summary'),
              onValidationChanged: (result) =>
                  updateValidation('summary', result),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// Reads the current target_role from CVProfile and renders the picker.
  Widget _buildRolePicker() {
    final profileAsync = ref.watch(cvProfileProvider);
    final currentRole = profileAsync.valueOrNull?.targetRole;
    return TargetRolePicker(currentRole: currentRole);
  }

  Widget _buildProfilePhotoSection(String? photoUrl) {
    final imageProvider = _getImageProvider(photoUrl);
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  _getInitials(),
                  style: AppTypography.h2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!kIsWeb)
          TextButton.icon(
            icon: const Icon(Icons.camera_alt_outlined,
                size: 16, color: AppColors.primary),
            label: Text(
              'Change Photo',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
            onPressed: _pickPhoto,
          )
        else
          Text(
            'Photo upload available on mobile',
            style: AppTypography.caption.copyWith(color: AppColors.textHint),
          ),
      ],
    );
  }

  String _getInitials() {
    final fullName = ref.read(currentUserProvider)?.fullName ?? '';
    if (fullName.isNotEmpty) {
      final names = fullName.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) return; // guarded — web not supported
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _selectedPhoto = File(pickedFile.path));
    }
  }

  // Enhanced save with enterprise error handling
  Future<bool> _saveData() async {
    // Validate all fields first
    if (!isFormValid) {
      context.showWarningToast('Please fix the errors before continuing');
      return false;
    }

    return await EnterpriseAsyncOperation.execute<bool>(
          context,
          operation: () async {
            // Upload photo if selected
            if (_selectedPhoto != null) {
              await ref
                  .read(cvProfileProvider.notifier)
                  .uploadPhoto(_selectedPhoto!);
            }

            // Update profile data
            final data = {
              'phone': _phoneController.text.trim(),
              'city': _cityController.text.trim(),
              'country': _countryController.text.trim(),
              'linkedin': _linkedinController.text.trim(),
              'github': _githubController.text.trim(),
              'portfolio': _portfolioController.text.trim(),
              'summary': _summaryController.text.trim(),
            };

            await ref.read(cvProfileProvider.notifier).updateProfile(data);
            return true;
          },
          loadingMessage: 'Saving your information...',
          successMessage: 'Personal information saved successfully!',
          errorMessage: 'Failed to save personal information',
          showLoadingToast: false, // We'll use the form loading state instead
        ) ??
        false;
  }
}
