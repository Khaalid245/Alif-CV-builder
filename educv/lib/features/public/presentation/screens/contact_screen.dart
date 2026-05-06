import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/section_card.dart';
import '../widgets/public_layout.dart';
import '../widgets/section_padding.dart';
import '../widgets/section_header.dart';
import '../widgets/faq_tile.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedSubject = 'Account issue';
  bool _isLoading = false;
  bool _isSuccess = false;

  final List<String> _subjects = [
    'Account issue',
    'CV generation problem',
    'Template question',
    'Data deletion request',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Column(
        children: [
          _buildHeader(),
          _buildContactSection(),
          _buildFAQSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SectionPadding(
      child: SectionHeader(
        eyebrow: 'Get in touch',
        title: 'We are here to help',
        subtitle: 'Questions about your account, CV generation, or the platform? Reach out and we will respond within one business day.',
      ),
    );
  }

  Widget _buildContactSection() {
    return SectionPadding(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          return isWeb ? _buildContactWeb() : _buildContactMobile();
        },
      ),
    );
  }

  Widget _buildContactWeb() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildContactInfo()),
        const SizedBox(width: 40),
        Expanded(flex: 1, child: _buildContactForm()),
      ],
    );
  }

  Widget _buildContactMobile() {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 32),
        _buildContactForm(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildContactInfoRow(
          LucideIcons.building2,
          'Department',
          'University Career Center',
        ),
        const SizedBox(height: 20),
        _buildContactInfoRow(
          LucideIcons.mapPin,
          'Address',
          '[University Address]',
        ),
        const SizedBox(height: 20),
        _buildContactInfoRow(
          LucideIcons.mail,
          'Email',
          'support@university.edu',
        ),
        const SizedBox(height: 20),
        _buildContactInfoRow(
          LucideIcons.clock,
          'Hours',
          'Mon–Fri, 8:00 AM – 5:00 PM',
        ),
      ],
    );
  }

  Widget _buildContactInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _isSuccess ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send a message',
            style: AppTypography.h3.copyWith(
              color: const Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Your Name',
            hint: 'Enter your full name',
            controller: _nameController,
            validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            prefixIcon: const Icon(LucideIcons.user),
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Student ID',
            hint: 'Enter your student ID',
            controller: _studentIdController,
            validator: (value) => value?.isEmpty == true ? 'Student ID is required' : null,
            prefixIcon: const Icon(LucideIcons.hash),
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Email Address',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildSubjectDropdown(),
          const SizedBox(height: 16),
          AppInput(
            label: 'Message',
            controller: _messageController,
            maxLines: 5,
            maxLength: 500,
            hint: 'Describe your issue or question...',
            validator: (value) => value?.isEmpty == true ? 'Message is required' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Send Message',
              onPressed: _isLoading ? null : _submitForm,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: AppTypography.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: _subjects.map((subject) => DropdownMenuItem(
            value: subject,
            child: Text(
              subject,
              style: AppTypography.body.copyWith(fontSize: 14),
            ),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSubject = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const Icon(
          LucideIcons.checkCircle,
          size: 40,
          color: Color(0xFF2E7D32),
        ),
        const SizedBox(height: 20),
        Text(
          'Message sent!',
          style: AppTypography.h2.copyWith(
            color: const Color(0xFF0A0A0A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We will get back to you within one business day.',
          style: AppTypography.body.copyWith(
            color: const Color(0xFF9E9E9E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        AppButton.secondary(
          'Send another',
          onPressed: _resetForm,
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For MVP: launch mailto
    final uri = Uri.parse(
      'mailto:support@university.edu'
      '?subject=${Uri.encodeComponent(_selectedSubject)}'
      '&body=${Uri.encodeComponent(_messageController.text)}'
    );
    
    try {
      await launchUrl(uri);
    } catch (e) {
      // Handle error silently for now
    }

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  void _resetForm() {
    setState(() {
      _isSuccess = false;
      _nameController.clear();
      _studentIdController.clear();
      _emailController.clear();
      _messageController.clear();
      _selectedSubject = _subjects.first;
    });
  }

  Widget _buildFAQSection() {
    return SectionPadding(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Common questions',
            title: 'Quick answers',
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              FAQTile(
                question: 'Is EduCV free to use?',
                answer: 'Yes. EduCV is completely free for all enrolled students at our university.',
              ),
              FAQTile(
                question: 'Who can see my CV information?',
                answer: 'Only you can view and download your CVs. Administrators can verify accounts but cannot access your CV content.',
              ),
              FAQTile(
                question: 'Can I delete my account and data?',
                answer: 'Yes. Go to Account Settings → Request Data Deletion. Your data is removed within 30 days.',
              ),
              FAQTile(
                question: 'Which template should I choose?',
                answer: 'Modern for tech and startup roles, Classic for corporate and government, Academic for research.',
              ),
              FAQTile(
                question: 'Can I update my CV after generating?',
                answer: 'Yes. Edit your information anytime and regenerate fresh PDFs. History is preserved.',
              ),
              FAQTile(
                question: 'Is my password secure?',
                answer: 'Passwords are encrypted. We never store or display plain-text passwords.',
              ),
              FAQTile(
                question: 'Does it work on mobile?',
                answer: 'Yes. Use the mobile app or web browser — both sync your data automatically.',
              ),
              FAQTile(
                question: 'My PDF looks wrong. What should I do?',
                answer: 'Try regenerating after completing all sections. Contact support if the issue persists.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}