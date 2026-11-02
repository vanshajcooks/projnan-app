import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/classes_controller.dart';

class CreateTeamDialog extends ConsumerStatefulWidget {
  final int? initialClassId;

  const CreateTeamDialog({super.key, this.initialClassId});

  static Future<void> show(BuildContext context, {int? initialClassId}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CreateTeamDialog(initialClassId: initialClassId),
    );
  }

  @override
  ConsumerState<CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends ConsumerState<CreateTeamDialog> {
  final _nameController = TextEditingController();
  int? _selectedClassId;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.initialClassId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedClassId == null) {
        final classes = ref.read(classesNotifierProvider).classes;
        if (classes.isNotEmpty) {
          setState(() => _selectedClassId = classes.first.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a team name');
      return;
    }
    if (_selectedClassId == null) {
      setState(() => _error = 'Please select a class for this team');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(classesNotifierProvider.notifier).createTeam(
          name,
          _selectedClassId!,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Team created successfully!');
      } else {
        final err = ref.read(classesNotifierProvider).errorMessage;
        setState(() => _error = err ?? 'Failed to create team');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesNotifierProvider);
    final classes = classesState.classes;

    return Dialog(
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.users, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Team',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Form a group within your enrolled class',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
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

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                hintText: 'e.g. Cloud Ninjas',
              ),
            ),
            const SizedBox(height: 14),

            if (classes.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _selectedClassId ?? classes.first.id,
                decoration: const InputDecoration(
                  labelText: 'Class',
                ),
                dropdownColor: AppTheme.surfaceElevated,
                items: classes.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedClassId = val);
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No classes found. Join or create a class first.',
                  style: TextStyle(fontSize: 12, color: AppTheme.warning),
                ),
              ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || classes.isEmpty ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Team'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
