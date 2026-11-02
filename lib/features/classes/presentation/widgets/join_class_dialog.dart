import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../controllers/classes_controller.dart';

class JoinClassDialog extends ConsumerStatefulWidget {
  const JoinClassDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const JoinClassDialog(),
    );
  }

  @override
  ConsumerState<JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends ConsumerState<JoinClassDialog> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a 6-digit class code');
      return;
    }
    if (code.length < 4) {
      setState(() => _error = 'Class code must be at least 4 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(classesNotifierProvider.notifier).joinClass(code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Also refresh projects so newly accessible class projects show up
        ref.read(projectsNotifierProvider.notifier).fetchProjects();
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Successfully joined class!');
      } else {
        final err = ref.read(classesNotifierProvider).errorMessage;
        setState(() => _error = err ?? 'Failed to join class. Verify code.');
      }
    }
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
                  child: const Icon(LucideIcons.graduationCap, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join a Class',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Enter 6-digit instructor code',
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
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'e.g. DBDE10',
                hintStyle: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2.0,
                  color: AppTheme.textSecondary.withAlpha(100),
                ),
                counterText: '',
                prefixIcon: const Icon(LucideIcons.keyRound, size: 18, color: AppTheme.textSecondary),
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
                    onPressed: _isLoading ? null : _handleJoin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Join Class'),
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
