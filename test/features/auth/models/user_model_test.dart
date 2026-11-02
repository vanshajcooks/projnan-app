import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final sampleJson = {
      'id': 42,
      'name': 'Deepak Sharma',
      'username': 'deepak',
      'email': 'deepak@example.com',
      'role': 'student',
      'avatar': 'https://example.com/avatar.png',
      'xp': 1500,
      'points': 250,
      'rank': 'Contributor Level 2',
      'bio': 'Passionate builder',
      'github_username': 'deepak-dev',
      'email_verified': 1,
      'created_at': '2026-09-15T10:00:00.000Z',
    };

    test('should parse correctly from backend JSON', () {
      final user = UserModel.fromJson(sampleJson);

      expect(user.id, 42);
      expect(user.name, 'Deepak Sharma');
      expect(user.username, 'deepak');
      expect(user.email, 'deepak@example.com');
      expect(user.role, 'student');
      expect(user.isStudent, true);
      expect(user.isTeacher, false);
      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.xp, 1500);
      expect(user.points, 250);
      expect(user.rank, 'Contributor Level 2');
      expect(user.bio, 'Passionate builder');
      expect(user.githubUsername, 'deepak-dev');
      expect(user.emailVerified, true);
      expect(user.createdAt, '2026-09-15T10:00:00.000Z');
    });

    test('should serialize to JSON correctly', () {
      final user = UserModel.fromJson(sampleJson);
      final json = user.toJson();

      expect(json['id'], 42);
      expect(json['name'], 'Deepak Sharma');
      expect(json['email'], 'deepak@example.com');
      expect(json['email_verified'], 1);
    });

    test('copyWith should update specified fields only', () {
      final user = UserModel.fromJson(sampleJson);
      final updated = user.copyWith(
        name: 'Updated Name',
        xp: 2000,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.xp, 2000);
      expect(updated.id, user.id);
      expect(updated.email, user.email);
    });

    test('role helper correctly identifies teacher', () {
      const teacher = UserModel(
        id: 1,
        name: 'Prof. Smith',
        username: 'psmith',
        email: 'smith@uni.edu',
        role: 'teacher',
      );

      expect(teacher.isTeacher, true);
      expect(teacher.isStudent, false);
    });
  });
}
