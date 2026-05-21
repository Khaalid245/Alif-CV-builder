import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_preview_widget.dart';
import '../widgets/template_features_widget.dart';
import '../widgets/template_branding_widget.dart';
import '../../../data/models/template_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_widgets;
import '../../../../router/app_router.dart';

class TemplateDetailScreen extends StatefulWidget {
  final String templateSlug;

  const TemplateDetailScreen({
    super.key,
    required this.templateSlug,
  });

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateEngineProvider>().selectTemplate(widget.templateSlug);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Template Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Consumer<TemplateEngineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedTemplate == null) {
            return const LoadingWidget(message: 'Loading template...');
          }

          if (provider.error != null && provider.selectedTemplate == null) {
            return app_widgets.AppErrorWidget(
              message: provider.error!,
              onRetry: () => provider.selectTemplate(widget.templateSlug),
            );
          }

          final template = provider.selectedTemplate;
          if (template == null) {
            return const Center(
              child: Text('Template not found'),
            );
          }

          return Column(
            children: [
              // Template header
              _buildTemplateHeader(template, provider),
              
              // Tab bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Theme.of(context).primaryColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Preview'),
                    Tab(text: 'Features'),
                    Tab(text: 'Customize'),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Preview tab
                    TemplatePreviewWidget(template: template),
                    
                    // Features tab
                    TemplateFeaturesWidget(template: template),
                    
                    // Customize tab
                    TemplateBrandingWidget(template: template),
                  ],
                ),
              ),
              
              // Bottom action bar
              _buildBottomActionBar(template, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateHeader(TemplateModel template, TemplateEngineProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description ?? 'No description available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  provider.isFavorite(template)
                      ? LucideIcons.heart
                      : LucideIcons.heart,
                  color: provider.isFavorite(template)
                      ? Colors.red
                      : Colors.grey[400],
                ),
                onPressed: () => provider.toggleFavorite(template),
                tooltip: provider.isFavorite(template)
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Template metadata
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetadataChip(
                icon: LucideIcons.tag,
                label: template.category.name,
                color: Colors.blue,
              ),
              _buildMetadataChip(
                icon: LucideIcons.layout,
                label: template.layoutDisplayName,
                color: Colors.green,
              ),
              if (template.isPremium)
                _buildMetadataChip(
                  icon: LucideIcons.crown,
                  label: 'Premium',
                  color: Colors.orange,
                ),
              _buildMetadataChip(
                icon: LucideIcons.users,
                label: '${template.usageCount} uses',
                color: Colors.purple,
              ),
            ],
          ),
          
          // Industries and roles
          if (template.industries.isNotEmpty || template.roles.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (template.industries.isNotEmpty) ...[
              Text(
                'Industries: ${template.industries.map((i) => i.name).join(', ')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (template.roles.isNotEmpty)
              Text(
                'Roles: ${template.roles.map((r) => r.name).join(', ')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
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

  Widget _buildBottomActionBar(TemplateModel template, TemplateEngineProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            // Preview button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previewTemplate(template, provider),
                icon: const Icon(LucideIcons.eye, size: 18),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Apply template button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isApplying ? null : () => _applyTemplate(template, provider),
                icon: _isApplying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(_isApplying ? 'Applying...' : 'Apply Template'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _previewTemplate(TemplateModel template, TemplateEngineProvider provider) async {
    // Add to recent templates
    provider.addToRecent(template);
    
    // Generate preview
    await provider.previewTemplate(template.slug);
    
    if (provider.templatePreview != null) {
      // Show preview in dialog or navigate to preview screen
      _showPreviewDialog(provider.templatePreview!);
    }
  }

  void _showPreviewDialog(String previewHtml) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Template Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(previewHtml), // In a real app, use WebView or HTML renderer
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyTemplate(TemplateModel template, TemplateEngineProvider provider) async {
    setState(() {
      _isApplying = true;
    });

    try {
      // Add to recent templates
      provider.addToRecent(template);
      
      // Render template with user's CV data
      final result = await provider.renderTemplate(template.slug);
      
      if (result != null) {
        // Navigate to CV preview with the rendered template
        if (mounted) {
          context.go(AppRoutes.cvPreview, extra: {
            'template': template,
            'renderedData': result,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply template: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }
}