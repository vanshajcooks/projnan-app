import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/project_model.dart';
import '../controllers/project_detail_controller.dart';
import '../controllers/projects_controller.dart';

class EditProjectDialog extends ConsumerStatefulWidget {
  final ProjectModel project;

  const EditProjectDialog({super.key, required this.project});

  static Future<void> show(BuildContext context, ProjectModel project) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EditProjectDialog(project: project),
    );
  }

  @override
  ConsumerState<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends ConsumerState<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _tagController;
  late String _selectedStatus;
  late List<String> _tags;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descController = TextEditingController(text: widget.project.description);
    _tagController = TextEditingController();
    _selectedStatus = widget.project.status;
    _tags = List.from(widget.project.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _tagController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(projectDetailNotifierProvider(widget.project.id).notifier)
        .updateProjectDetails(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _selectedStatus,
          tags: _tags,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ref.read(projectsNotifierProvider.notifier).fetchProjects();
        AppToast.showSuccess(context, 'Project updated successfully!');
        Navigator.of(context).pop();
      } else {
        final err = ref.read(projectDetailNotifierProvider(widget.project.id)).errorMessage;
        AppToast.showError(context, err ?? 'Failed to update project');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.settings, size: 20, color: AppTheme.primaryLight),
                        SizedBox(width: 10),
                        Text(
                          'Project Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Project Name Field
                TextFormField(
                  controller: _nameController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Project name is required' : null,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Project Description Field
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                  decoration: InputDecoration(
                    labelText: 'Project Description',
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus.toLowerCase(),
                  decoration: InputDecoration(
                    labelText: 'Project Status',
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  dropdownColor: AppTheme.surfaceElevated,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active / In Development')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const SizedBox(height: 16),

                // Tech Tags Field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        onSubmitted: (_) => _addTag(),
                        decoration: InputDecoration(
                          labelText: 'Add Tech Tag',
                          hintText: 'e.g. Flutter, Node.js',
                          filled: true,
                          fillColor: AppTheme.surfaceElevated,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                      onPressed: _addTag,
                      icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppTheme.surfaceElevated,
                        deleteIcon: const Icon(LucideIcons.x, size: 12),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
