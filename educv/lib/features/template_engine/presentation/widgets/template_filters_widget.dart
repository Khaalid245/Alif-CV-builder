import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../../../data/models/template_model.dart';

class TemplateFiltersWidget extends StatelessWidget {
  const TemplateFiltersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEngineProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.filter, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (provider.hasActiveFilters)
                    TextButton(
                      onPressed: provider.clearFilters,
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filter chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category filter
                    _buildFilterDropdown(
                      context: context,
                      label: 'Category',
                      value: provider.selectedCategory,
                      items: provider.categories.map((c) => DropdownMenuItem(
                        value: c.slug,
                        child: Text(c.name),
                      )).toList(),
                      onChanged: provider.setCategory,
                    ),
                    const SizedBox(width: 12),
                    
                    // Industry filter
                    _buildFilterDropdown(
                      context: context,
                      label: 'Industry',
                      value: provider.selectedIndustry,
                      items: provider.industries.map((i) => DropdownMenuItem(
                        value: i.slug,
                        child: Text(i.name),
                      )).toList(),
                      onChanged: provider.setIndustry,
                    ),
                    const SizedBox(width: 12),
                    
                    // Role filter (filtered by industry)
                    _buildFilterDropdown(
                      context: context,
                      label: 'Role',
                      value: provider.selectedRole,
                      items: provider.roles.map((r) => DropdownMenuItem(
                        value: r.slug,
                        child: Text(r.name),
                      )).toList(),
                      onChanged: provider.setRole,
                      enabled: provider.selectedIndustry != null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Layout filter
                    _buildFilterDropdown(
                      context: context,
                      label: 'Layout',
                      value: provider.selectedLayout,
                      items: TemplateLayout.values.map((layout) => DropdownMenuItem(
                        value: _layoutToString(layout),
                        child: Text(_layoutToDisplayName(layout)),
                      )).toList(),
                      onChanged: provider.setLayout,
                    ),
                    const SizedBox(width: 12),
                    
                    // Premium filter
                    _buildPremiumFilter(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('All ${label}s'),
          ),
          ...items,
        ],
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
      ),
    );
  }

  Widget _buildPremiumFilter(TemplateEngineProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Premium',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          DropdownButton<bool?>(
            value: provider.isPremiumFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text('All'),
              ),
              DropdownMenuItem<bool?>(
                value: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.crown, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('Premium'),
                  ],
                ),
              ),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Free'),
              ),
            ],
            onChanged: provider.setPremiumFilter,
          ),
        ],
      ),
    );
  }

  String _layoutToString(TemplateLayout layout) {
    switch (layout) {
      case TemplateLayout.singleColumn:
        return 'single_column';
      case TemplateLayout.twoColumn:
        return 'two_column';
      case TemplateLayout.threeColumn:
        return 'three_column';
      case TemplateLayout.modernGrid:
        return 'modern_grid';
      case TemplateLayout.timeline:
        return 'timeline';
      case TemplateLayout.classic:
        return 'classic';
      case TemplateLayout.modern:
        return 'modern';
      case TemplateLayout.academic:
        return 'academic';
      case TemplateLayout.creative:
        return 'creative';
      case TemplateLayout.minimal:
        return 'minimal';
    }
  }

  String _layoutToDisplayName(TemplateLayout layout) {
    switch (layout) {
      case TemplateLayout.singleColumn:
        return 'Single Column';
      case TemplateLayout.twoColumn:
        return 'Two Column';
      case TemplateLayout.threeColumn:
        return 'Three Column';
      case TemplateLayout.modernGrid:
        return 'Modern Grid';
      case TemplateLayout.timeline:
        return 'Timeline';
      case TemplateLayout.classic:
        return 'Classic';
      case TemplateLayout.modern:
        return 'Modern';
      case TemplateLayout.academic:
        return 'Academic';
      case TemplateLayout.creative:
        return 'Creative';
      case TemplateLayout.minimal:
        return 'Minimal';
    }
  }
}