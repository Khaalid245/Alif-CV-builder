import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_card_widget.dart';

class RecentTemplatesWidget extends StatelessWidget {
  const RecentTemplatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        if (provider.recentTemplates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recently Viewed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _clearRecent(provider),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'Templates you\'ve recently viewed or previewed',
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
              itemCount: provider.recentTemplates.length,
              itemBuilder: (context, index) {
                final template = provider.recentTemplates[index];
                return Stack(
                  children: [
                    TemplateCardWidget(
                      template: template,
                      onTap: () => _navigateToTemplate(template.slug),
                      onFavorite: () => provider.toggleFavorite(template),
                      onPreview: () => _previewTemplate(template, provider),
                    ),
                    
                    // Recent indicator
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Recent',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
              LucideIcons.clock,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Recent Templates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Templates you view or preview will appear here for quick access',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to all templates
              },
              child: const Text('Browse Templates'),
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

  void _previewTemplate(template, TemplateEngineProvider provider) {
    provider.addToRecent(template);
    provider.previewTemplate(template.slug);
  }

  void _clearRecent(TemplateEngineProvider provider) {
    // Clear recent templates
    provider.recentTemplates.clear();
    provider.notifyListeners();
  }
}