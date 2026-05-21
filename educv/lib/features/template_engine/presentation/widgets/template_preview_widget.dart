import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../../../data/models/template_model.dart';

class TemplatePreviewWidget extends StatefulWidget {
  final TemplateModel template;

  const TemplatePreviewWidget({
    super.key,
    required this.template,
  });

  @override
  State<TemplatePreviewWidget> createState() => _TemplatePreviewWidgetState();
}

class _TemplatePreviewWidgetState extends State<TemplatePreviewWidget> {
  bool _isGeneratingPreview = false;

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    setState(() {
      _isGeneratingPreview = true;
    });

    try {
      await context.read<TemplateEngineProvider>().previewTemplate(widget.template.slug);
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              // Preview controls
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.eye, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Template Preview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_isGeneratingPreview)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        onPressed: _generatePreview,
                        tooltip: 'Refresh Preview',
                      ),
                  ],
                ),
              ),
              
              // Preview content
              Expanded(
                child: _buildPreviewContent(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(TemplateEngineProvider provider) {
    if (_isGeneratingPreview) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Generating preview...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Preview Generation Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePreview,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.templatePreview == null) {
      return _buildPlaceholderPreview();
    }

    // In a real implementation, you would use a WebView or HTML renderer
    // For now, we'll show a placeholder with the template structure
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildTemplateStructure(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Template Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Refresh Preview" to generate a preview with sample data',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateStructure() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        _buildPreviewSection(
          title: 'Personal Information',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Software Engineer',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'john.doe@email.com • +1 (555) 123-4567',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Summary section
        _buildPreviewSection(
          title: 'Professional Summary',
          content: Text(
            'Experienced software engineer with 5+ years of experience in full-stack development. Passionate about creating efficient, scalable solutions and leading development teams.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Experience section
        _buildPreviewSection(
          title: 'Work Experience',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExperienceItem(
                title: 'Senior Software Engineer',
                company: 'Tech Company Inc.',
                period: '2020 - Present',
                description: 'Led development of microservices architecture, improved system performance by 40%.',
              ),
              const SizedBox(height: 16),
              _buildExperienceItem(
                title: 'Software Engineer',
                company: 'Startup Co.',
                period: '2018 - 2020',
                description: 'Developed web applications using React and Node.js, collaborated with cross-functional teams.',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Skills section
        _buildPreviewSection(
          title: 'Skills',
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'JavaScript', 'React', 'Node.js', 'Python', 'AWS', 'Docker'
            ].map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 2,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildExperienceItem({
    required String title,
    required String company,
    required String period,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              company,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' • $period',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}