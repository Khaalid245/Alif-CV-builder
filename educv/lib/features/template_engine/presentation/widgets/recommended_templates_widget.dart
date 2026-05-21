import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_card_widget.dart';

class RecommendedTemplatesWidget extends StatefulWidget {
  final VoidCallback? onLoadMore;

  const RecommendedTemplatesWidget({
    super.key,
    this.onLoadMore,
  });

  @override
  State<RecommendedTemplatesWidget> createState() => _RecommendedTemplatesWidgetState();
}

class _RecommendedTemplatesWidgetState extends State<RecommendedTemplatesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateEngineProvider>().loadRecommendedTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.recommendedTemplates.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.recommendedTemplates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(LucideIcons.sparkles, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.onLoadMore != null)
                  TextButton(
                    onPressed: widget.onLoadMore,
                    child: const Text('Load More'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'Based on your profile and preferences',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Templates grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.recommendedTemplates.length,
              itemBuilder: (context, index) {
                final template = provider.recommendedTemplates[index];
                return TemplateCardWidget(
                  template: template,
                  onTap: () => _navigateToTemplate(template.slug),
                  onFavorite: () => provider.toggleFavorite(template),
                  onPreview: () => _previewTemplate(template),
                );
              },
            ),
            
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Recommendations Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your CV profile to get personalized template recommendations',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to CV form
              },
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  void _navigateToTemplate(String slug) {
    // Navigate to template detail
  }

  void _previewTemplate(template) {
    final provider = context.read<TemplateEngineProvider>();
    provider.addToRecent(template);
    provider.previewTemplate(template.slug);
  }
}