import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/template_engine_provider.dart';
import '../widgets/template_filters_widget.dart';
import '../widgets/template_grid_widget.dart';
import '../widgets/template_search_widget.dart';
import '../widgets/recommended_templates_widget.dart';
import '../widgets/popular_templates_widget.dart';
import '../widgets/recent_templates_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_widgets;

class TemplateCatalogScreen extends StatefulWidget {
  const TemplateCatalogScreen({super.key});

  @override
  State<TemplateCatalogScreen> createState() => _TemplateCatalogScreenState();
}

class _TemplateCatalogScreenState extends State<TemplateCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateEngineProvider>().initialize();
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
          'Template Catalog',
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
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? LucideIcons.x : LucideIcons.filter,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TemplateEngineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.templates.isEmpty) {
            return const LoadingWidget(message: 'Loading templates...');
          }

          if (provider.error != null && provider.templates.isEmpty) {
            return app_widgets.AppErrorWidget(
              message: provider.error!,
              onRetry: () => provider.initialize(),
            );
          }

          return Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: const TemplateSearchWidget(),
              ),
              
              // Filters (collapsible)
              if (_showFilters)
                Container(
                  color: Colors.white,
                  child: const TemplateFiltersWidget(),
                ),
              
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
                    Tab(text: 'All Templates'),
                    Tab(text: 'Recommended'),
                    Tab(text: 'Popular'),
                    Tab(text: 'Recent'),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All Templates
                    _buildAllTemplatesTab(provider),
                    
                    // Recommended Templates
                    _buildRecommendedTab(provider),
                    
                    // Popular Templates
                    _buildPopularTab(provider),
                    
                    // Recent Templates
                    _buildRecentTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllTemplatesTab(TemplateEngineProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadTemplates(),
      child: CustomScrollView(
        slivers: [
          if (provider.hasActiveFilters)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.filter, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filters applied • ${provider.templates.length} templates found',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
            ),
          
          if (provider.templates.isEmpty && !provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileText, size: 64, color: Colors.grey),
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
                      'Try adjusting your filters or search terms',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: TemplateGridWidget(templates: provider.templates),
            ),
          
          if (provider.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendedTab(TemplateEngineProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadRecommendedTemplates(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RecommendedTemplatesWidget(
          onLoadMore: () => provider.loadRecommendedTemplates(limit: 12),
        ),
      ),
    );
  }

  Widget _buildPopularTab(TemplateEngineProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPopularTemplates(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PopularTemplatesWidget(
          onLoadMore: () => provider.loadPopularTemplates(limit: 12),
        ),
      ),
    );
  }

  Widget _buildRecentTab(TemplateEngineProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RecentTemplatesWidget(),
    );
  }
}