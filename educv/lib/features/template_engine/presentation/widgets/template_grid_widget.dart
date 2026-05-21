import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_card_widget.dart';
import '../../../data/models/template_model.dart';

class TemplateGridWidget extends StatelessWidget {
  final List<TemplateModel> templates;

  const TemplateGridWidget({
    super.key,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No templates found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final template = templates[index];
          return TemplateCardWidget(
            template: template,
            onTap: () => _navigateToTemplate(context, template),
            onFavorite: () => _toggleFavorite(context, template),
            onPreview: () => _previewTemplate(context, template),
          );
        },
        childCount: templates.length,
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _navigateToTemplate(BuildContext context, TemplateModel template) {
    context.go('/templates/${template.slug}');
  }

  void _toggleFavorite(BuildContext context, TemplateModel template) {
    context.read<TemplateEngineProvider>().toggleFavorite(template);
  }

  void _previewTemplate(BuildContext context, TemplateModel template) {
    final provider = context.read<TemplateEngineProvider>();
    provider.addToRecent(template);
    provider.previewTemplate(template.slug);
  }
}