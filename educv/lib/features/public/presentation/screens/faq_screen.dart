import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../widgets/public_layout.dart';
import '../widgets/section_padding.dart';
import '../widgets/section_header.dart';
import '../widgets/faq_tile.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: SectionPadding(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              const SectionHeader(
                eyebrow: 'FAQ',
                title: 'Frequently asked questions',
                subtitle: 'Everything you need to know about EduCV.',
              ),
              const SizedBox(height: 32),
              _buildCategory('Getting Started', _getGettingStartedQuestions()),
              const SizedBox(height: 32),
              _buildCategory('CV and Templates', _getCVTemplateQuestions()),
              const SizedBox(height: 32),
              _buildCategory('Privacy and Security', _getPrivacySecurityQuestions()),
              const SizedBox(height: 32),
              _buildCategory('Technical Help', _getTechnicalHelpQuestions()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String categoryName, List<Map<String, String>> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName.toUpperCase(),
          style: AppTypography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.07,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFEEEEEE),
        ),
        const SizedBox(height: 16),
        Column(
          children: questions.map((q) => FAQTile(
            question: q['question']!,
            answer: q['answer']!,
          )).toList(),
        ),
      ],
    );
  }

  List<Map<String, String>> _getGettingStartedQuestions() {
    return [
      {
        'question': 'How do I register?',
        'answer': 'Click "Get Started" and use your university email address. You\'ll need your student ID to verify your enrollment.',
      },
      {
        'question': 'What is my Student ID?',
        'answer': 'Your Student ID is the unique number assigned by the university, usually found on your student card or enrollment documents.',
      },
      {
        'question': 'Is EduCV free to use?',
        'answer': 'Yes. EduCV is completely free for all enrolled students at our university.',
      },
      {
        'question': 'Who can see my CV information?',
        'answer': 'Only you can view and download your CVs. Administrators can verify accounts but cannot access your CV content.',
      },
      {
        'question': 'Can I delete my account and data?',
        'answer': 'Yes. Go to Account Settings → Request Data Deletion. Your data is removed within 30 days.',
      },
    ];
  }

  List<Map<String, String>> _getCVTemplateQuestions() {
    return [
      {
        'question': 'How many CV formats do I get?',
        'answer': 'You get 3 professionally designed formats: Classic (corporate), Modern (tech/creative), and Academic (research).',
      },
      {
        'question': 'Can I choose different templates?',
        'answer': 'Yes. Generate all 3 templates and download whichever ones suit your applications best.',
      },
      {
        'question': 'What information does the CV include?',
        'answer': 'Personal info, education, work experience, skills, languages, projects, and certifications. All sections are optional except education.',
      },
      {
        'question': 'Can I add a profile photo?',
        'answer': 'Yes. Upload a professional headshot in the Personal Info section. Photos are optional and only appear on some templates.',
      },
      {
        'question': 'Which template should I use for internships?',
        'answer': 'Modern template works well for most internships. Use Classic for traditional industries like banking or law.',
      },
    ];
  }

  List<Map<String, String>> _getPrivacySecurityQuestions() {
    return [
      {
        'question': 'Who owns my CV data?',
        'answer': 'You own all your data. The university provides the platform but you control your information completely.',
      },
      {
        'question': 'Is my data shared with employers?',
        'answer': 'No. Your data is never shared automatically. Only you can send your CV to employers.',
      },
      {
        'question': 'How is my data stored?',
        'answer': 'All data is encrypted and stored on secure university servers. We follow strict data protection standards.',
      },
      {
        'question': 'Can I export all my data?',
        'answer': 'Yes. Contact support to request a complete export of your account data in JSON format.',
      },
      {
        'question': 'What happens when I delete my account?',
        'answer': 'All your data is permanently removed within 30 days. Generated PDFs are deleted and cannot be recovered.',
      },
    ];
  }

  List<Map<String, String>> _getTechnicalHelpQuestions() {
    return [
      {
        'question': 'The app is not loading. What do I do?',
        'answer': 'Try refreshing your browser or restarting the mobile app. Check your internet connection and contact support if issues persist.',
      },
      {
        'question': 'I forgot my password.',
        'answer': 'Click "Forgot Password" on the login screen. You\'ll receive a reset link at your university email address.',
      },
      {
        'question': 'I cannot download my PDF.',
        'answer': 'Ensure your browser allows downloads and you have sufficient storage space. Try generating the CV again if the issue continues.',
      },
    ];
  }
}