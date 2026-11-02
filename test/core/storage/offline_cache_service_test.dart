import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/network/api_client.dart';
import 'package:probon_app/core/storage/offline_cache_service.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineCacheService Tests', () {
    test('cacheJsonList and getCachedJsonList stores and retrieves JSON maps', () async {
      final prefs = await SharedPreferences.getInstance();
      final cacheService = OfflineCacheService(prefs: prefs);

      final sampleData = [
        {'id': 1, 'name': 'Project Alpha'},
        {'id': 2, 'name': 'Project Beta'},
      ];

      await cacheService.cacheJsonList('test_projects', sampleData);

      final retrieved = await cacheService.getCachedJsonList('test_projects');
      expect(retrieved, isNotNull);
      expect(retrieved!.length, 2);
      expect(retrieved[0]['name'], 'Project Alpha');
      expect(retrieved[1]['id'], 2);
    });

    test('cacheJsonObject and getCachedJsonObject stores and retrieves single map', () async {
      final prefs = await SharedPreferences.getInstance();
      final cacheService = OfflineCacheService(prefs: prefs);

      final sampleObject = {'userId': 101, 'role': 'teacher'};

      await cacheService.cacheJsonObject('test_user', sampleObject);

      final retrieved = await cacheService.getCachedJsonObject('test_user');
      expect(retrieved, isNotNull);
      expect(retrieved!['role'], 'teacher');

      await cacheService.clearCache('test_user');
      final cleared = await cacheService.getCachedJsonObject('test_user');
      expect(cleared, isNull);
    });
  });

  group('Repository Offline Fallback Tests', () {
    test('ProjectsRepository falls back to cached data when network fails', () async {
      final prefs = await SharedPreferences.getInstance();
      final cacheService = OfflineCacheService(prefs: prefs);

      // Pre-seed cache
      await cacheService.cacheJsonList('cached_user_projects', [
        {
          'id': 99,
          'name': 'Offline Cached Project',
          'description': 'Cached description',
          'status': 'active',
          'progress': 45,
          'tags': ['flutter'],
          'goals': ['test'],
        }
      ]);

      // Mock API to throw network exception
      when(() => mockApiClient.get('/projects/my')).thenThrow(Exception('No internet'));
      when(() => mockApiClient.get('/projects')).thenThrow(Exception('No internet'));

      final repo = ProjectsRepository(apiClient: mockApiClient, cacheService: cacheService);
      final projects = await repo.getUserProjects();

      expect(projects.length, 1);
      expect(projects.first.id, 99);
      expect(projects.first.name, 'Offline Cached Project');
    });

    test('TasksRepository falls back to cached data when network fails', () async {
      final prefs = await SharedPreferences.getInstance();
      final cacheService = OfflineCacheService(prefs: prefs);

      // Pre-seed cache
      await cacheService.cacheJsonList('cached_my_tasks', [
        {
          'id': 501,
          'title': 'Offline Cached Task',
          'description': 'Offline task description',
          'status': 'Planned',
          'priority': 'high',
          'xp_value': 100,
        }
      ]);

      when(() => mockApiClient.get('/tasks/my')).thenThrow(Exception('Connection timeout'));
      when(() => mockApiClient.get('/tasks')).thenThrow(Exception('Connection timeout'));

      final repo = TasksRepository(apiClient: mockApiClient, cacheService: cacheService);
      final tasks = await repo.getMyTasks();

      expect(tasks.length, 1);
      expect(tasks.first.id, 501);
      expect(tasks.first.title, 'Offline Cached Task');
    });
  });
}
