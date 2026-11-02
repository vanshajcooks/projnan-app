import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/project_detail_controller.dart';

class ConnectRepoDialog extends ConsumerStatefulWidget {
  final int projectId;

  const ConnectRepoDialog({super.key, required this.projectId});

  static Future<void> show(BuildContext context, int projectId) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConnectRepoDialog(projectId: projectId),
    );
  }

  @override
  ConsumerState<ConnectRepoDialog> createState() => _ConnectRepoDialogState();
}

class _ConnectRepoDialogState extends ConsumerState<ConnectRepoDialog> {
  final _urlController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _branchController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a GitHub repository URL');
      return;
    }
    if (!url.contains('github.com')) {
      setState(() => _error = 'Must be a valid GitHub URL (e.g. https://github.com/owner/repo)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(projectDetailNotifierProvider(widget.projectId).notifier)
        .connectGithub(
          url,
          defaultBranch: _branchController.text.trim(),
          token: _tokenController.text.trim().isEmpty ? null : _tokenController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'GitHub repository linked successfully!');
      } else {
        final err = ref.read(projectDetailNotifierProvider(widget.projectId)).errorMessage;
        setState(() => _error = err ?? 'Failed to connect repository');
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
                  child: const Icon(LucideIcons.gitBranch, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link GitHub Repository',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sync commits, PRs, and team telemetry',
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
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Repository URL *',
                hintText: 'https://github.com/organization/repo',
                prefixIcon: Icon(LucideIcons.link, size: 18),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _branchController,
              decoration: const InputDecoration(
                labelText: 'Default Branch',
                hintText: 'main',
                prefixIcon: Icon(LucideIcons.gitCommit, size: 18),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Personal Access Token (Optional)',
                hintText: 'ghp_xxxx for private repositories',
                prefixIcon: Icon(LucideIcons.shieldCheck, size: 18),
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
                    onPressed: _isLoading ? null : _handleConnect,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Connect'),
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
