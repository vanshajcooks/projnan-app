import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';

void main() {
  group('ProjectModel Tests', () {
    final sampleJson = {
      'id': 101,
      'name': 'AI Learning Platform',
      'description': 'Building next-gen educational software',
      'team_id': 5,
      'team_name': 'Alpha Team',
      'class_id': 2,
      'class_name': 'CS401 Senior Project',
      'status': 'Active',
      'progress': 65,
      'goals': ['Design UI', 'Setup Dio', 'Write Tests'],
      'tags': ['Flutter', 'Node.js', 'AI'],
      'task_count': 12,
      'completed_task_count': 8,
      'created_at': '2026-10-01T12:00:00Z',
    };

    test('parses accurately from backend JSON schema', () {
      final project = ProjectModel.fromJson(sampleJson);

      expect(project.id, 101);
      expect(project.name, 'AI Learning Platform');
      expect(project.teamName, 'Alpha Team');
      expect(project.className, 'CS401 Senior Project');
      expect(project.progress, 65);
      expect(project.isCompleted, false);
      expect(project.goals.length, 3);
      expect(project.tags.contains('Flutter'), true);
      expect(project.taskCount, 12);
      expect(project.completedTaskCount, 8);
    });

    test('isCompleted returns true if status is completed or progress is 100', () {
      final doneProject = ProjectModel.fromJson({
        ...sampleJson,
        'status': 'Completed',
        'progress': 100,
      });

      expect(doneProject.isCompleted, true);
    });

    test('serializes to JSON matching backend fields', () {
      final project = ProjectModel.fromJson(sampleJson);
      final json = project.toJson();

      expect(json['id'], 101);
      expect(json['team_id'], 5);
      expect(json['progress'], 65);
      expect(json['status'], 'Active');
    });
  });
}
