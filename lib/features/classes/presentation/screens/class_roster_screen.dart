import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/class_roster_model.dart';
import '../controllers/classes_controller.dart';
import '../widgets/create_team_dialog.dart';

class ClassRosterScreen extends ConsumerStatefulWidget {
  final int classId;

  const ClassRosterScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassRosterScreen> createState() => _ClassRosterScreenState();
}

class _ClassRosterScreenState extends ConsumerState<ClassRosterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyClassCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppToast.showSuccess(context, 'Class code $code copied to clipboard!');
  }

  Future<void> _confirmRemoveStudent(int studentId, String studentName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Remove Student',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove $studentName from this class? They will lose access to class teams and projects.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(classRosterNotifierProvider(widget.classId).notifier)
          .removeStudent(studentId);

      if (mounted) {
        if (success) {
          AppToast.showSuccess(context, '$studentName removed from class');
        } else {
          AppToast.showError(context, 'Failed to remove student');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rosterState = ref.watch(classRosterNotifierProvider(widget.classId));
    final currentUser = ref.watch(authNotifierProvider).user;

    if (rosterState.isLoading && rosterState.roster == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          title: const Text('Class Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final roster = rosterState.roster;
    if (roster == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          title: const Text('Class Details'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertCircle, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                rosterState.errorMessage ?? 'Failed to load class information',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(classRosterNotifierProvider(widget.classId).notifier)
                    .fetchRoster(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isTeacherOrOwner = (currentUser?.isTeacher ?? false) ||
        (roster.teacherId != null && roster.teacherId == currentUser?.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          roster.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(classRosterNotifierProvider(widget.classId).notifier)
                .fetchRoster(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: () async {
          await ref
              .read(classRosterNotifierProvider(widget.classId).notifier)
              .fetchRoster();
        },
        child: Column(
          children: [
            // Class Hero Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roster.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Instructor: ${roster.teacherName ?? "Faculty"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyClassCode(roster.code),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primary.withAlpha(90)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.copy, size: 13, color: AppTheme.primaryLight),
                              const SizedBox(width: 6),
                              Text(
                                roster.code,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (roster.description != null && roster.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      roster.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Summary stats row
                  Row(
                    children: [
                      _buildHeaderChip(
                        icon: LucideIcons.users,
                        label: '${roster.members.length} Students',
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderChip(
                        icon: LucideIcons.network,
                        label: '${roster.teams.length} Teams',
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderChip(
                        icon: LucideIcons.folderKanban,
                        label: '${roster.projects.length} Projects',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: AppTheme.surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primaryLight,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: [
                  Tab(text: 'Students (${roster.members.length})'),
                  Tab(text: 'Teams (${roster.teams.length})'),
                  Tab(text: 'Projects (${roster.projects.length})'),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStudentsList(roster, isTeacherOrOwner),
                  _buildTeamsList(roster),
                  _buildProjectsList(roster),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(ClassRosterDetailModel roster, bool isTeacher) {
    if (roster.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.userX, size: 40, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'No Students Enrolled',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Share code "${roster.code}" with students to join.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: roster.members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = roster.members[index];
        final isOwner = member.role.toLowerCase() == 'teacher';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withAlpha(45),
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOwner
                                ? AppTheme.primary.withAlpha(40)
                                : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isOwner
                                  ? AppTheme.primary.withAlpha(90)
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            isOwner ? 'TEACHER' : 'STUDENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isOwner ? AppTheme.primaryLight : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.email} · ${member.xp} XP',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isTeacher && !isOwner)
                IconButton(
                  icon: const Icon(LucideIcons.userMinus, size: 16, color: AppTheme.error),
                  tooltip: 'Remove Student',
                  onPressed: () => _confirmRemoveStudent(member.id, member.name),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamsList(ClassRosterDetailModel roster) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Teams (${roster.teams.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Team', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => CreateTeamDialog(initialClassId: roster.id),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: roster.teams.isEmpty
              ? const Center(
                  child: Text(
                    'No teams formed yet in this class.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: roster.teams.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final team = roster.teams[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.users, size: 18, color: AppTheme.primaryLight),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Leader: ${team.leaderName ?? "Not assigned"} · ${team.memberCount} members · ${team.projectCount} projects',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProjectsList(ClassRosterDetailModel roster) {
    if (roster.projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects registered in this class yet.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: roster.projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final project = roster.projects[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(LucideIcons.folderGit2, size: 18, color: AppTheme.primaryLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Team: ${project.teamName ?? "General"}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (project.status ?? 'active').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
