import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/project_model.dart';
import '../controllers/projects_controller.dart';
import '../widgets/project_card.dart';

class ExploreProjectsScreen extends ConsumerStatefulWidget {
  const ExploreProjectsScreen({super.key});

  @override
  ConsumerState<ExploreProjectsScreen> createState() => _ExploreProjectsScreenState();
}

class _ExploreProjectsScreenState extends ConsumerState<ExploreProjectsScreen> {
  final _searchController = TextEditingController();
  List<ProjectModel> _allProjects = [];
  bool _isLoading = true;
  String _selectedTag = 'All';
  String _selectedStatus = 'All';

  final List<String> _tags = ['All', 'AI', 'Flutter', 'Cloud', 'Node.js', 'Web'];
  final List<String> _statuses = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchProjects());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(projectsRepositoryProvider);
      final list = await repo.searchProjects();
      if (mounted) {
        setState(() {
          _allProjects = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ProjectModel> get _filteredProjects {
    final query = _searchController.text.trim().toLowerCase();

    return _allProjects.where((p) {
      // Query filter
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          (p.description?.toLowerCase().contains(query) ?? false) ||
          p.tags.any((t) => t.toLowerCase().contains(query));

      // Status filter
      final matchesStatus = _selectedStatus == 'All' ||
          (_selectedStatus == 'Active' && !p.isCompleted) ||
          (_selectedStatus == 'Completed' && p.isCompleted);

      // Tag filter
      final matchesTag = _selectedTag == 'All' ||
          p.tags.any((t) => t.toLowerCase() == _selectedTag.toLowerCase());

      return matchesQuery && matchesStatus && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProjects;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Explore Capstones'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
            onPressed: _fetchProjects,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by title, description or tag...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Tech Tag Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedTag = tag);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Status Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Capstone Projects',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
                Row(
                  children: _statuses.map((status) {
                    final isSel = _selectedStatus == status;
                    return InkWell(
                      onTap: () => setState(() => _selectedStatus = status),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? AppTheme.primaryLight : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Projects List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchProjects,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.folderSearch,
                                    size: 48,
                                    color: AppTheme.textSecondary.withAlpha(100),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No matching capstone projects',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Try adjusting your search keywords or active filters',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final project = filtered[index];
                            return ProjectCard(
                              project: project,
                              onTap: () {
                                context.push('/projects/${project.id}');
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
