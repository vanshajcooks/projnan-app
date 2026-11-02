import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/features/projects/data/models/feedback_model.dart';
import 'package:probon_app/features/projects/data/models/github_activity_model.dart';
import 'package:probon_app/features/projects/data/models/milestone_model.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';

void main() {
  group('Phase 7 Models Tests', () {
    test('MilestoneModel parses accurately from backend JSON', () {
      final json = {
        'id': 201,
        'project_id': 107,
        'title': 'Alpha Release Architecture',
        'description': 'Deliver core microservices and database schemas',
        'due_date': '2026-11-15T00:00:00.000Z',
        'status': 'completed',
        'xp_reward': 150,
        'task_count': 10,
        'completed_task_count': 6,
      };

      final milestone = MilestoneModel.fromJson(json);

      expect(milestone.id, 201);
      expect(milestone.projectId, 107);
      expect(milestone.title, 'Alpha Release Architecture');
      expect(milestone.description, 'Deliver core microservices and database schemas');
      expect(milestone.isCompleted, true);
      expect(milestone.xpReward, 150);
      expect(milestone.taskCount, 10);
      expect(milestone.completedTaskCount, 6);
      expect(milestone.progressPercentage, 0.6);
      expect(milestone.dueDate, '2026-11-15T00:00:00.000Z');

      final outJson = milestone.toJson();
      expect(outJson['title'], 'Alpha Release Architecture');
      expect(outJson['status'], 'completed');
    });

    test('GitHubActivityModel parses commits, PRs, and issues correctly', () {
      final commitJson = {
        'id': 1,
        'project_id': 107,
        'activity_type': 'commit',
        'title': 'feat: initial telemetry collector engine',
        'description': 'eBPF probes added',
        'commit_hash': 'abc1234567890',
        'author_username': 'Aryan Thakkar',
        'timestamp': '2026-11-01T14:32:00.000Z',
        'url': 'https://github.com/cloudninjas/monitor-daemon/commit/abc1234',
      };
      final commit = GitHubActivityModel.fromJson(commitJson);
      expect(commit.commitHash, 'abc1234567890');
      expect(commit.authorUsername, 'Aryan Thakkar');
      expect(commit.title, 'feat: initial telemetry collector engine');
      expect(commit.activityType, 'commit');

      final prJson = {
        'id': 2,
        'project_id': 107,
        'activity_type': 'pull_request',
        'title': 'Implement Prometheus Metrics Exporter',
        'pr_number': 42,
        'branch': 'feature/metrics',
        'author_username': 'Aryan Thakkar',
        'url': 'https://github.com/cloudninjas/monitor-daemon/pull/42',
        'timestamp': '2026-11-02T10:00:00.000Z',
      };
      final pr = GitHubActivityModel.fromJson(prJson);
      expect(pr.prNumber, 42);
      expect(pr.branch, 'feature/metrics');
      expect(pr.authorUsername, 'Aryan Thakkar');

      final issueJson = {
        'id': 3,
        'project_id': 107,
        'activity_type': 'issue',
        'title': 'Memory spike during high throughput telemetry burst',
        'author_username': 'Elena Vance',
        'url': 'https://github.com/cloudninjas/monitor-daemon/issues/15',
        'timestamp': '2026-11-02T08:15:00.000Z',
      };
      final issue = GitHubActivityModel.fromJson(issueJson);
      expect(issue.activityType, 'issue');
      expect(issue.authorUsername, 'Elena Vance');
      expect(issue.title, 'Memory spike during high throughput telemetry burst');
    });

    test('FeedbackModel parses ratings and reviewer info correctly', () {
      final feedbackJson = {
        'id': 501,
        'project_id': 107,
        'author_id': 10,
        'author_name': 'Dr. Elena Vance',
        'author_role': 'instructor',
        'rating': 5,
        'type': 'teacher_review',
        'comment': 'Outstanding architecture and thorough unit test coverage.',
        'created_at': '2026-11-02T12:00:00.000Z',
      };

      final feedback = FeedbackModel.fromJson(feedbackJson);
      expect(feedback.id, 501);
      expect(feedback.projectId, 107);
      expect(feedback.authorName, 'Dr. Elena Vance');
      expect(feedback.authorRole, 'instructor');
      expect(feedback.rating, 5);
      expect(feedback.comment, 'Outstanding architecture and thorough unit test coverage.');

      final outJson = feedback.toJson();
      expect(outJson['rating'], 5);
      expect(outJson['project_id'], 107);
    });

    test('ProjectModel embeds repository, members, milestones, and taskStats', () {
      final projectJson = {
        'id': 107,
        'name': 'Cloud Monitor Platform',
        'status': 'Active',
        'progress': 75,
        'repository': {
          'url': 'https://github.com/cloudninjas/monitor-daemon',
          'last_synced_at': '2026-11-02T16:00:00.000Z',
          'stars': 12,
          'forks': 3,
          'open_issues': 2,
        },
        'members': [
          {'id': 1, 'name': 'Aryan Thakkar', 'role': 'Lead Developer'},
          {'id': 2, 'name': 'Priya Patel', 'role': 'Frontend Specialist'},
        ],
        'milestones': [
          {
            'id': 1,
            'project_id': 107,
            'title': 'Sprint 1 MVP',
            'status': 'completed',
            'task_count': 5,
            'completed_task_count': 5,
          }
        ],
        'taskStats': {
          'total': 10,
          'completed': 7,
          'in_progress': 2,
          'review': 1,
        },
      };

      final project = ProjectModel.fromJson(projectJson);
      expect(project.id, 107);
      expect(project.repository?['url'], 'https://github.com/cloudninjas/monitor-daemon');
      expect(project.repository?['stars'], 12);
      expect(project.members.length, 2);
      expect(project.members[0]['name'], 'Aryan Thakkar');
      expect(project.milestones.length, 1);
      expect(project.milestones[0].isCompleted, true);
      expect(project.taskStats?['total'], 10);
      expect(project.taskStats?['completed'], 7);
      expect(project.taskStats?['in_progress'], 2);
    });
  });
}
