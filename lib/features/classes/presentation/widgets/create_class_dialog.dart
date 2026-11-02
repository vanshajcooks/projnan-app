import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/class_model.dart';
import '../controllers/classes_controller.dart';

class CreateClassDialog extends ConsumerStatefulWidget {
  const CreateClassDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const CreateClassDialog(),
    );
  }

  @override
  ConsumerState<CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends ConsumerState<CreateClassDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  ClassModel? _createdClass;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a class name');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final newClass = await ref.read(classesNotifierProvider.notifier).createClass(
          name,
          _descController.text.trim(),
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (newClass != null) {
          _createdClass = newClass;
        } else {
          _error = ref.read(classesNotifierProvider).errorMessage ?? 'Failed to create class';
        }
      });
    }
  }

  void _copyClassCode() {
    if (_createdClass == null) return;
    Clipboard.setData(ClipboardData(text: _createdClass!.code));
    AppToast.showSuccess(context, 'Class code copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _createdClass != null ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
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
              child: const Icon(LucideIcons.bookOpen, size: 22, color: AppTheme.primaryLight),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Class',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'For instructors and capstone leads',
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
            labelText: 'Class Name',
            hintText: 'e.g. CS450: Distributed Systems',
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _descController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Course overview and semester focus...',
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
                onPressed: _isLoading ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create Class'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(35),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.checkCircle2, size: 36, color: AppTheme.success),
        ),
        const SizedBox(height: 16),
        Text(
          _createdClass!.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Share this class code with your students:',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withAlpha(90)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _createdClass!.code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  color: AppTheme.primaryLight,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 20, color: AppTheme.primaryLight),
                tooltip: 'Copy Code',
                onPressed: _copyClassCode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
