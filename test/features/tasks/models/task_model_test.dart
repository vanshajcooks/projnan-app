import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskModel Tests', () {
    final sampleJson = {
      'id': 201,
      'project_id': 101,
      'project_name': 'AI Learning Platform',
      'milestone_id': 1,
      'milestone_title': 'Sprint 1',
      'title': 'Implement Auth Interceptors',
      'description': 'Attach JWT token and handle 401',
      'assigned_to_id': 42,
      'assigned_to_name': 'Aryan Patel',
      'priority': 'high',
      'deadline': '2026-11-10',
      'task_type': 'weekly',
      'status': 'In Progress',
      'xp_value': 75,
      'verification_status': null,
      'completion_evidence': 'PR #42: https://github.com/org/repo/pull/42',
    };

    test('parses accurately from backend JSON schema with evidence', () {
      final task = TaskModel.fromJson(sampleJson);

      expect(task.id, 201);
      expect(task.projectId, 101);
      expect(task.projectName, 'AI Learning Platform');
      expect(task.title, 'Implement Auth Interceptors');
      expect(task.priority, 'high');
      expect(task.status, 'In Progress');
      expect(task.isInProgress, true);
      expect(task.isCompleted, false);
      expect(task.xpValue, 75);
      expect(task.hasEvidence, true);
      expect(task.completionEvidence, 'PR #42: https://github.com/org/repo/pull/42');
    });

    test('isCompleted returns true when status is Completed', () {
      final task = TaskModel.fromJson({
        ...sampleJson,
        'status': 'Completed',
        'verification_status': 'verified',
      });

      expect(task.isCompleted, true);
      expect(task.isInProgress, false);
      expect(task.isVerified, true);
      expect(task.isRejected, false);
    });

    test('isPendingVerification and isRejected return true correctly', () {
      final pendingTask = TaskModel.fromJson({
        ...sampleJson,
        'status': 'Verification Pending',
        'verification_status': 'pending',
      });
      expect(pendingTask.isPendingVerification, true);

      final rejectedTask = TaskModel.fromJson({
        ...sampleJson,
        'status': 'In Progress',
        'verification_status': 'rejected',
      });
      expect(rejectedTask.isRejected, true);
    });

    test('copyWith updates specified fields only', () {
      final task = TaskModel.fromJson(sampleJson);
      final updated = task.copyWith(
        status: 'Completed',
        xpValue: 100,
        completionEvidence: 'Updated PR #45',
      );

      expect(updated.status, 'Completed');
      expect(updated.xpValue, 100);
      expect(updated.id, task.id);
      expect(updated.title, task.title);
      expect(updated.completionEvidence, 'Updated PR #45');
    });
  });
}
