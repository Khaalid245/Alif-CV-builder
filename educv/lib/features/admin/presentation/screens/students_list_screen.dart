import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../providers/admin_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/status_badge.dart';
import '../widgets/pagination_loader.dart';
import '../../data/models/admin_models.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchActive = false;
  String _selectedStatus = 'all';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminStudentsProvider.notifier).fetch();
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    final studentsState = ref.read(adminStudentsProvider);
    if (studentsState.value?.hasMore != true) return;

    setState(() => _isLoadingMore = true);
    await ref.read(adminStudentsProvider.notifier).loadMore();
    setState(() => _isLoadingMore = false);
  }

  void _onSearchChanged(String query) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(adminStudentsProvider.notifier).fetch(
          search: query.isEmpty ? null : query,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
        );
      }
    });
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    ref.read(adminStudentsProvider.notifier).fetch(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      status: status == 'all' ? null : status,
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        ref.read(adminStudentsProvider.notifier).fetch(
          status: _selectedStatus == 'all' ? null : _selectedStatus,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(adminStudentsProvider);
    final isSearchActive = ref.watch(studentsSearchToggleProvider);

    // Update local search state when provider changes
    if (isSearchActive != _isSearchActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isSearchActive = isSearchActive);
      });
    }

    return Column(
      children: [
        // Search bar (collapsible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isSearchActive ? 60 : 0,
          child: _isSearchActive ? _buildSearchBar() : null,
        ),
        
        // Filter row
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: FilterChipRow(
            options: const ['All', 'Active', 'Suspended', 'Deactivated', 'Pending Deletion'],
            selected: _selectedStatus,
            onChanged: _onStatusChanged,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Students list
        Expanded(
          child: studentsState.when(
            data: (response) => response != null 
                ? _buildStudentsList(response)
                : const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminStudentsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppInput(
        controller: _searchController,
        label: 'Search',
        hint: 'Search by name, email or student ID...',
        prefixIcon: const Icon(LucideIcons.search),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildStudentsList(PaginatedResponse<AdminStudentModel> response) {
    if (response.results.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminStudentsProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: response.results.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == response.results.length) {
            return const PaginationLoader();
          }
          
          final student = response.results[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: StudentListTile(
              student: student,
              onTap: () => context.go('/admin/students/${student.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    
    return EmptyState(
      icon: hasSearch ? LucideIcons.searchX : LucideIcons.users,
      title: hasSearch ? 'No students found' : 'No students yet',
      subtitle: hasSearch 
          ? 'Try a different search term'
          : 'Students will appear here after registering',
    );
  }
}

class StudentListTile extends StatelessWidget {
  final AdminStudentModel student;
  final VoidCallback onTap;

  const StudentListTile({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: student.photoUrl != null 
                ? NetworkImage(student.photoUrl!) 
                : null,
            child: student.photoUrl == null
                ? Text(
                    student.fullName.isNotEmpty 
                        ? student.fullName[0].toUpperCase()
                        : 'U',
                    style: AppTypography.label.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      student.fullName,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: student.status),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '${student.studentId} • ${student.email}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    const Icon(LucideIcons.fileText, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${student.totalCvsGenerated} CVs',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.clock, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      student.lastActiveText,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
