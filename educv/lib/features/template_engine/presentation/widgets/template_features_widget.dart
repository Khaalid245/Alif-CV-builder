import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/template_model.dart';

class TemplateFeaturesWidget extends StatelessWidget {
  final TemplateModel template;

  const TemplateFeaturesWidget({
    super.key,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template overview
          _buildOverviewCard(),
          const SizedBox(height: 16),
          
          // Key features
          _buildFeaturesCard(),
          const SizedBox(height: 16),
          
          // Layout details
          _buildLayoutCard(),
          const SizedBox(height: 16),
          
          // Compatibility
          _buildCompatibilityCard(),
          const SizedBox(height: 16),
          
          // Industries and roles
          if (template.industries.isNotEmpty || template.roles.isNotEmpty)
            _buildTargetingCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.info, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Template Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (template.description?.isNotEmpty == true) ...[
              Text(
                template.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Template metadata
            Row(
              children: [
                _buildMetadataItem(
                  icon: LucideIcons.calendar,
                  label: 'Version',
                  value: template.version ?? '1.0.0',
                ),
                const SizedBox(width: 24),
                _buildMetadataItem(
                  icon: LucideIcons.users,
                  label: 'Usage',
                  value: '${template.usageCount} times',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    final features = _getTemplateFeatures();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.star, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.check,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.layout, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Layout Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildLayoutFeature(
                    icon: LucideIcons.columns,
                    title: 'Layout Type',
                    description: template.layoutDisplayName,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLayoutFeature(
                    icon: LucideIcons.palette,
                    title: 'Customizable',
                    description: 'Colors & fonts',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildLayoutFeature(
                    icon: LucideIcons.printer,
                    title: 'Print Ready',
                    description: 'Optimized for PDF',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLayoutFeature(
                    icon: LucideIcons.smartphone,
                    title: 'Responsive',
                    description: 'Mobile friendly',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.shield, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Compatibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildCompatibilityChip(
                  icon: LucideIcons.fileText,
                  label: 'PDF Export',
                  color: Colors.red,
                ),
                _buildCompatibilityChip(
                  icon: LucideIcons.printer,
                  label: 'Print Ready',
                  color: Colors.blue,
                ),
                _buildCompatibilityChip(
                  icon: LucideIcons.download,
                  label: 'Downloadable',
                  color: Colors.green,
                ),
                _buildCompatibilityChip(
                  icon: LucideIcons.share,
                  label: 'Shareable',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.target, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Best For',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (template.industries.isNotEmpty) ...[
              Text(
                'Industries',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: template.industries.map((industry) => Chip(
                  label: Text(
                    industry.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide(color: Colors.blue[200]!),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (template.roles.isNotEmpty) ...[
              Text(
                'Job Roles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: template.roles.map((role) => Chip(
                  label: Text(
                    role.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green[50],
                  side: BorderSide(color: Colors.green[200]!),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompatibilityChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTemplateFeatures() {
    final features = <String>[
      'Professional layout optimized for ${template.layoutDisplayName.toLowerCase()}',
      'Automatic section organization and formatting',
      'Customizable colors and typography',
      'Print-ready PDF generation',
      'Mobile-responsive design',
    ];

    if (template.isPremium) {
      features.addAll([
        'Premium design elements and styling',
        'Advanced customization options',
        'Priority support and updates',
      ]);
    }

    // Add layout-specific features
    switch (template.layoutType) {
      case TemplateLayout.twoColumn:
        features.add('Sidebar for skills and contact information');
        break;
      case TemplateLayout.timeline:
        features.add('Timeline-based experience presentation');
        break;
      case TemplateLayout.modernGrid:
        features.add('Modern grid layout with visual hierarchy');
        break;
      default:
        break;
    }

    return features;
  }
}