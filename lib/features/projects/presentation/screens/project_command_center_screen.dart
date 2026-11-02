import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../../tasks/presentation/widgets/create_task_bottom_sheet.dart';
import '../controllers/project_detail_controller.dart';
import '../widgets/add_feedback_dialog.dart';
import '../widgets/add_milestone_dialog.dart';
import '../widgets/connect_repo_dialog.dart';

class ProjectCommandCenterScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectCommandCenterScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectCommandCenterScreen> createState() => _ProjectCommandCenterScreenState();
}

class _ProjectCommandCenterScreenState extends ConsumerState<ProjectCommandCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _githubSubTab = 0; // 0: Commits, 1: PRs, 2: Issues

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

  Future<void> _handleSync() async {
    final success = await ref
        .read(projectDetailNotifierProvider(widget.projectId).notifier)
        .syncGithub();
    if (mounted) {
      if (success) {
        AppToast.showSuccess(context, 'Repository telemetry synced from GitHub!');
      } else {
        final err = ref.read(projectDetailNotifierProvider(widget.projectId)).errorMessage;
        AppToast.showError(context, err ?? 'Failed to sync repository');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectDetailNotifierProvider(widget.projectId));
    final project = state.project;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(project?.name ?? 'Project Command Center'),
        actions: [
          if (state.isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 19),
              tooltip: 'Sync GitHub Telemetry',
              onPressed: _handleSync,
            ),
          IconButton(
            icon: const Icon(LucideIcons.messageSquare, size: 20),
            tooltip: 'Team Chat',
            onPressed: () {
              context.push('/projects/${widget.projectId}/chat?name=${Uri.encodeComponent(project?.name ?? 'Project')}');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 20),
            color: AppTheme.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.border),
            ),
            onSelected: (val) {
              if (val == 'repo') ConnectRepoDialog.show(context, widget.projectId);
              if (val == 'milestone') AddMilestoneDialog.show(context, widget.projectId);
              if (val == 'review') AddFeedbackDialog.show(context, widget.projectId);
              if (val == 'task') CreateTaskBottomSheet.show(context, projectId: widget.projectId);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'task',
                child: Row(
                  children: [
                    Icon(LucideIcons.plusSquare, size: 16, color: AppTheme.primaryLight),
                    SizedBox(width: 10),
                    Text('New Task', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'milestone',
                child: Row(
                  children: [
                    Icon(LucideIcons.flag, size: 16, color: Color(0xFFFBBF24)),
                    SizedBox(width: 10),
                    Text('Add Milestone', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'repo',
                child: Row(
                  children: [
                    Icon(LucideIcons.gitBranch, size: 16, color: AppTheme.accent),
                    SizedBox(width: 10),
                    Text('Connect Repository', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'review',
                child: Row(
                  children: [
                    Icon(LucideIcons.star, size: 16, color: Color(0xFFFBBF24)),
                    SizedBox(width: 10),
                    Text('Post Evaluation', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateTaskBottomSheet.show(context, projectId: widget.projectId),
        backgroundColor: AppTheme.primary,
        icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.isLoading && project == null
          ? const Center(child: CircularProgressIndicator())
          : project == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle, size: 48, color: AppTheme.error),
                      const SizedBox(height: 12),
                      Text(state.errorMessage ?? 'Project not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(projectDetailNotifierProvider(widget.projectId).notifier)
                            .loadDetails(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Class & Team row
                              Row(
                                children: [
                                  if (project.className != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withAlpha(35),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        project.className!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryLight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (project.teamName != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceElevated,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.users, size: 12, color: AppTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.teamName!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: project.isCompleted
                                          ? AppTheme.success.withAlpha(35)
                                          : const Color(0xFFF97316).withAlpha(35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      project.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: project.isCompleted ? AppTheme.success : const Color(0xFFF97316),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Project Title
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Description
                              Text(
                                project.description ?? 'No description provided.',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 16),

                              // Progress Bar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Capstone Progress',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  Text(
                                    '${project.progress}%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: project.progress / 100,
                                  backgroundColor: AppTheme.surfaceElevated,
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tech Tags
                              if (project.tags.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: project.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            indicatorColor: AppTheme.primary,
                            indicatorWeight: 3,
                            labelColor: AppTheme.primaryLight,
                            unselectedLabelColor: AppTheme.textSecondary,
                            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            tabs: const [
                              Tab(text: 'Milestones'),
                              Tab(text: 'GitHub Hub'),
                              Tab(text: 'Evaluations'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMilestonesTab(project, state),
                      _buildGitHubTab(project, state),
                      _buildFeedbackTab(state),
                    ],
                  ),
                ),
    );
  }

  // TAB 1: Milestones & Goals
  Widget _buildMilestonesTab(dynamic project, ProjectDetailState state) {
    final milestones = project.milestones;
    final goals = project.goals;
    final members = project.members;

    return RefreshIndicator(
      onRefresh: () => ref.read(projectDetailNotifierProvider(widget.projectId).notifier).loadDetails(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Goals Section
          if (goals.isNotEmpty) ...[
            const Text(
              'Sprint Goals',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: goals.map<Widget>((goal) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.checkCircle2, size: 16, color: AppTheme.success),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              goal,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Milestones Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Milestones Timeline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              TextButton.icon(
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Milestone', style: TextStyle(fontSize: 12)),
                onPressed: () => AddMilestoneDialog.show(context, widget.projectId),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (milestones.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(LucideIcons.flag, size: 32, color: AppTheme.textSecondary),
                      const SizedBox(height: 8),
                      const Text(
                        'No milestones defined yet.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => AddMilestoneDialog.show(context, widget.projectId),
                        child: const Text('Add first milestone'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...milestones.map<Widget>((m) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            m.isCompleted ? LucideIcons.checkCircle : LucideIcons.circleDashed,
                            size: 18,
                            color: m.isCompleted ? AppTheme.success : const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.zap, size: 12, color: Color(0xFFFBBF24)),
                                const SizedBox(width: 3),
                                Text(
                                  '+${m.xpReward} XP',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFBBF24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (m.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          m.description,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: m.progressPercentage,
                          backgroundColor: AppTheme.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation(
                            m.isCompleted ? AppTheme.success : AppTheme.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),

          // Team Roster Section
          if (members.isNotEmpty) ...[
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: members.map<Widget>((mem) {
                  final name = mem['name']?.toString() ?? 'Contributor';
                  final role = mem['team_role']?.toString() ?? 'member';
                  final xp = mem['xp']?.toString() ?? '0';
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withAlpha(45),
                      child: Text(
                        (name.isNotEmpty ? name[0] : 'U').toUpperCase(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(role.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    trailing: Text('$xp XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TAB 2: GitHub Hub
  Widget _buildGitHubTab(dynamic project, ProjectDetailState state) {
    final repo = project.repository;

    return RefreshIndicator(
      onRefresh: () => ref.read(projectDetailNotifierProvider(widget.projectId).notifier).loadDetails(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Repo Connection Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: repo != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.gitBranch, size: 20, color: AppTheme.primaryLight),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    repo['repo_name']?.toString() ?? repo['url']?.toString() ?? 'Repository',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Branch: ${repo['default_branch'] ?? 'main'} · Synced: ${repo['last_synced_at'] ?? 'just now'}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: state.isSyncing ? null : _handleSync,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              icon: const Icon(LucideIcons.refreshCw, size: 13),
                              label: const Text('Sync', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(LucideIcons.gitFork, size: 36, color: AppTheme.textSecondary),
                        const SizedBox(height: 10),
                        const Text(
                          'No GitHub repository connected yet',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ConnectRepoDialog.show(context, widget.projectId),
                          icon: const Icon(LucideIcons.link, size: 15),
                          label: const Text('Connect Repository'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(180, 40),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // Sub Tab Switcher: Commits / PRs / Issues
          Row(
            children: [
              _buildSubTabChip(0, 'Commits (${state.commits.length})', LucideIcons.gitCommit),
              const SizedBox(width: 8),
              _buildSubTabChip(1, 'Pull Requests (${state.pullRequests.length})', LucideIcons.gitPullRequest),
              const SizedBox(width: 8),
              _buildSubTabChip(2, 'Issues (${state.issues.length})', LucideIcons.alertCircle),
            ],
          ),
          const SizedBox(height: 14),

          // Activity List
          if (_githubSubTab == 0) _buildCommitsList(state.commits),
          if (_githubSubTab == 1) _buildPullsList(state.pullRequests),
          if (_githubSubTab == 2) _buildIssuesList(state.issues),
        ],
      ),
    );
  }

  Widget _buildSubTabChip(int index, String label, IconData icon) {
    final isSelected = _githubSubTab == index;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.textSecondary),
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _githubSubTab = index),
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
      ),
    );
  }

  Widget _buildCommitsList(List<dynamic> commits) {
    if (commits.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Center(
            child: Text('No commits synced yet.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
        ),
      );
    }
    return Column(
      children: commits.map<Widget>((c) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.gitCommit, size: 16, color: AppTheme.primaryLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c.authorUsername} · ${c.commitHash != null ? c.commitHash!.substring(0, 7) : 'commit'}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPullsList(List<dynamic> pulls) {
    if (pulls.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Center(
            child: Text('No pull requests recorded.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
        ),
      );
    }
    return Column(
      children: pulls.map<Widget>((pr) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(LucideIcons.gitPullRequest, size: 18, color: AppTheme.success),
            title: Text(pr.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('Author: ${pr.authorUsername}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIssuesList(List<dynamic> issues) {
    if (issues.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Center(
            child: Text('No active issues found.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
        ),
      );
    }
    return Column(
      children: issues.map<Widget>((iss) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(LucideIcons.alertCircle, size: 18, color: Color(0xFFF97316)),
            title: Text(iss.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('Reported by: ${iss.authorUsername}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ),
        );
      }).toList(),
    );
  }

  // TAB 3: Reviews & Evaluations
  Widget _buildFeedbackTab(ProjectDetailState state) {
    final feedbacks = state.feedbacks;

    return RefreshIndicator(
      onRefresh: () => ref.read(projectDetailNotifierProvider(widget.projectId).notifier).loadDetails(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Instructor & Peer Reviews',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              ElevatedButton.icon(
                onPressed: () => AddFeedbackDialog.show(context, widget.projectId),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Write Review', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (feedbacks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(LucideIcons.star, size: 36, color: AppTheme.textSecondary),
                      const SizedBox(height: 10),
                      const Text(
                        'No evaluation reviews submitted yet.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => AddFeedbackDialog.show(context, widget.projectId),
                        child: const Text('Submit first evaluation'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...feedbacks.map<Widget>((f) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primary.withAlpha(45),
                            child: Text(
                              f.authorAvatar ?? (f.authorName.isNotEmpty ? f.authorName[0] : 'R'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.authorName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                                Text(
                                  f.authorRole.toUpperCase(),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // Rating Stars
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                LucideIcons.star,
                                size: 14,
                                color: index < f.rating ? const Color(0xFFFBBF24) : AppTheme.border,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        f.comment,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return false;
  }
}
