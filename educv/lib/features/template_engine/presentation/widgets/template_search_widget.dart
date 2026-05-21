import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';

class TemplateSearchWidget extends StatefulWidget {
  const TemplateSearchWidget({super.key});

  @override
  State<TemplateSearchWidget> createState() => _TemplateSearchWidgetState();
}

class _TemplateSearchWidgetState extends State<TemplateSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _controller.text = context.read<TemplateEngineProvider>().searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search templates by name, category, or description...',
            prefixIcon: const Icon(LucideIcons.search, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _controller.clear();
                      provider.setSearchQuery('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            // Debounce search to avoid too many API calls
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_controller.text == value) {
                provider.setSearchQuery(value);
              }
            });
          },
          onSubmitted: (value) {
            provider.setSearchQuery(value);
          },
        );
      },
    );
  }
}