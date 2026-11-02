import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../../classes/presentation/controllers/classes_controller.dart';
import '../controllers/projects_controller.dart';

class CreateProjectBottomSheet extends ConsumerStatefulWidget {
  const CreateProjectBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateProjectBottomSheet(),
    );
  }

  @override
  ConsumerState<CreateProjectBottomSheet> createState() => _CreateProjectBottomSheetState();
}

class _CreateProjectBottomSheetState extends ConsumerState<CreateProjectBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController(text: 'Flutter, Mobile, Dart');
  final _goalsController = TextEditingController(text: 'Design UI, Connect API, Deploy');

  int? _selectedClassId;
  int? _selectedTeamId;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classesNotifierProvider.notifier).fetchClassesAndTeams().then((_) {
        if (!mounted) return;
        final classes = ref.read(classesNotifierProvider).classes;
        if (classes.isNotEmpty) {
          setState(() {
            _selectedClassId = classes.first.id;
            _updateMatchingTeam(classes.first.id);
          });
        }
      });
    });
  }

  void _updateMatchingTeam(int classId) {
    final teams = ref.read(classesNotifierProvider).teams;
    final matching = teams.where((t) => t.classId == classId).toList();
    if (matching.isNotEmpty) {
      _selectedTeamId = matching.first.id;
    } else {
      _selectedTeamId = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Project title is required');
      return;
    }
    if (desc.isEmpty) {
      setState(() => _error = 'Project description is required');
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final goals = _goalsController.text
        .split(RegExp(r'[,;\n]'))
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(projectsNotifierProvider.notifier).createProject(
          name: name,
          description: desc,
          classId: _selectedClassId,
          teamId: _selectedTeamId,
          tags: tags,
          goals: goals,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Project "$name" created successfully!');
      } else {
        final err = ref.read(projectsNotifierProvider).errorMessage;
        setState(() => _error = err ?? 'Failed to create project');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesNotifierProvider);
    final classes = classesState.classes;
    final teams = classesState.teams;
    final filteredTeams = _selectedClassId != null
        ? teams.where((t) => t.classId == _selectedClassId).toList()
        : teams;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.folderPlus, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Project',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Launch a student capstone initiative',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Form inputs
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                hintText: 'e.g. Distributed Task Scheduler',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Brief summary of objectives and stack...',
              ),
            ),
            const SizedBox(height: 14),

            // Class Dropdown
            if (classes.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _selectedClassId ?? classes.first.id,
                decoration: const InputDecoration(
                  labelText: 'Class / Course',
                ),
                dropdownColor: AppTheme.surfaceElevated,
                items: classes.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedClassId = val;
                    if (val != null) _updateMatchingTeam(val);
                  });
                },
              ),
            const SizedBox(height: 14),

            // Team Dropdown
            if (filteredTeams.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _selectedTeamId != null && filteredTeams.any((t) => t.id == _selectedTeamId)
                    ? _selectedTeamId
                    : filteredTeams.first.id,
                decoration: const InputDecoration(
                  labelText: 'Team',
                ),
                dropdownColor: AppTheme.surfaceElevated,
                items: filteredTeams.map((t) {
                  return DropdownMenuItem<int>(
                    value: t.id,
                    child: Text(t.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedTeamId = val);
                },
              ),
            const SizedBox(height: 14),

            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tech Tags (comma separated)',
                hintText: 'e.g. Go, Docker, React',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _goalsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Project Goals (comma separated)',
                hintText: 'e.g. Design DB, Setup CI/CD, Build Frontend',
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Project', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
