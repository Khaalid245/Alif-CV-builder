import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_card_widget.dart';

class PopularTemplatesWidget extends StatefulWidget {
  final VoidCallback? onLoadMore;

  const PopularTemplatesWidget({
    super.key,
    this.onLoadMore,
  });

  @override
  State<PopularTemplatesWidget> createState() => _PopularTemplatesWidgetState();
}

class _PopularTemplatesWidgetState extends State<PopularTemplatesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateEngineProvider>().loadPopularTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.popularTemplates.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.popularTemplates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(LucideIcons.trendingUp, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Popular Templates',
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
              'Most used templates in the last 30 days',
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
              itemCount: provider.popularTemplates.length,
              itemBuilder: (context, index) {
                final template = provider.popularTemplates[index];
                return Stack(
                  children: [
                    TemplateCardWidget(
                      template: template,
                      onTap: () => _navigateToTemplate(template.slug),
                      onFavorite: () => provider.toggleFavorite(template),
                      onPreview: () => _previewTemplate(template),
                    ),
                    
                    // Popularity rank badge
                    if (index < 3)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getRankColor(index),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
              LucideIcons.trendingUp,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Popular Templates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Popular templates will appear here based on usage statistics',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.orange[700]!; // Bronze
      default:
        return Colors.blue;
    }
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