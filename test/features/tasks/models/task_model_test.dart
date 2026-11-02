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
    };

    test('parses accurately from backend JSON schema', () {
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
    });

    test('isCompleted returns true when status is Completed', () {
      final task = TaskModel.fromJson({
        ...sampleJson,
        'status': 'Completed',
      });

      expect(task.isCompleted, true);
      expect(task.isInProgress, false);
    });

    test('copyWith updates specified fields only', () {
      final task = TaskModel.fromJson(sampleJson);
      final updated = task.copyWith(status: 'Completed', xpValue: 100);

      expect(updated.status, 'Completed');
      expect(updated.xpValue, 100);
      expect(updated.id, task.id);
      expect(updated.title, task.title);
    });
  });
}
