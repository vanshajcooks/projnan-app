import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';

class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  final int? preselectedProjectId;

  const CreateTaskBottomSheet({super.key, this.preselectedProjectId});

  static Future<void> show(BuildContext context, {int? projectId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskBottomSheet(preselectedProjectId: projectId),
    );
  }

  @override
  ConsumerState<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  int? _selectedProjectId;
  String _selectedPriority = 'medium';
  String _selectedTaskType = 'weekly';
  int _xpValue = 50;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preselectedProjectId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var projects = ref.read(projectsNotifierProvider).projects;
      if (projects.isEmpty) {
        await ref.read(projectsNotifierProvider.notifier).fetchProjects();
        if (!mounted) return;
        projects = ref.read(projectsNotifierProvider).projects;
      }
      if (_selectedProjectId == null && projects.isNotEmpty) {
        setState(() => _selectedProjectId = projects.first.id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Task title is required');
      return;
    }
    if (_selectedProjectId == null) {
      setState(() => _error = 'Please select a project for this task');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(tasksNotifierProvider.notifier).createTask(
          projectId: _selectedProjectId!,
          title: title,
          description: _descController.text.trim(),
          priority: _selectedPriority,
          taskType: _selectedTaskType,
          xpValue: _xpValue,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Task "$title" created (+$_xpValue XP)!');
      } else {
        final err = ref.read(tasksNotifierProvider).errorMessage;
        setState(() => _error = err ?? 'Failed to create task');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsNotifierProvider);
    final projects = projectsState.projects;
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
                  child: const Icon(LucideIcons.listPlus, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Assign sprint task or milestone deliverable',
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

            // Project Dropdown
            if (projects.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _selectedProjectId != null && projects.any((p) => p.id == _selectedProjectId)
                    ? _selectedProjectId
                    : projects.first.id,
                decoration: const InputDecoration(
                  labelText: 'Assigned Project *',
                ),
                dropdownColor: AppTheme.surfaceElevated,
                items: projects.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedProjectId = val);
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No active projects found. Create or join a project first.',
                  style: TextStyle(fontSize: 12, color: AppTheme.warning),
                ),
              ),
            const SizedBox(height: 14),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'e.g. Implement OAuth Flow',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Acceptance criteria and technical details...',
              ),
            ),
            const SizedBox(height: 18),

            // Priority Chips
            const Text(
              'Priority',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChoiceChip('low', 'Low', const Color(0xFF6B7280)),
                const SizedBox(width: 8),
                _buildChoiceChip('medium', 'Medium', const Color(0xFFFBBF24)),
                const SizedBox(width: 8),
                _buildChoiceChip('high', 'High', const Color(0xFFF97316)),
                const SizedBox(width: 8),
                _buildChoiceChip('urgent', 'Urgent', const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 18),

            // Task Type Chips
            const Text(
              'Cadence',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('daily', 'Daily'),
                const SizedBox(width: 8),
                _buildTypeChip('weekly', 'Weekly'),
                const SizedBox(width: 8),
                _buildTypeChip('monthly', 'Monthly'),
              ],
            ),
            const SizedBox(height: 18),

            // XP Value
            Row(
              children: [
                const Icon(LucideIcons.zap, size: 16, color: Color(0xFFFBBF24)),
                const SizedBox(width: 8),
                const Text(
                  'XP Reward:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Text(
                  '$_xpValue XP',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
                ),
              ],
            ),
            Slider(
              value: _xpValue.toDouble(),
              min: 25,
              max: 200,
              divisions: 7,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.border,
              onChanged: (val) => setState(() => _xpValue = val.round()),
            ),
            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _isLoading || projects.isEmpty ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Task', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String value, String label, Color color) {
    final isSelected = _selectedPriority == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _selectedPriority = value),
      selectedColor: color.withAlpha(45),
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? color : AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? color : AppTheme.border),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _selectedTaskType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _selectedTaskType = value),
      selectedColor: AppTheme.primary.withAlpha(45),
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
      ),
    );
  }
}
