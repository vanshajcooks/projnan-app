import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/network/api_client.dart';
import 'package:probon_app/features/classes/data/repositories/classes_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ClassesRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = ClassesRepository(apiClient: mockApiClient);
  });

  group('ClassesRepository Tests', () {
    test('getUserClasses parses and returns list of ClassModel', () async {
      when(() => mockApiClient.get('/classes')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/classes'),
          data: {
            'success': true,
            'data': [
              {
                'id': 1,
                'name': 'CS450: Distributed Systems',
                'code': 'DBDE10',
                'description': 'Cloud computing course',
                'student_count': 12,
              }
            ],
          },
        ),
      );

      final classes = await repository.getUserClasses();
      expect(classes.length, 1);
      expect(classes.first.name, 'CS450: Distributed Systems');
      expect(classes.first.code, 'DBDE10');
      expect(classes.first.studentCount, 12);
    });

    test('joinClass submits uppercase code and returns ClassModel', () async {
      when(() => mockApiClient.post('/classes/join', data: {'code': 'DBDE10'})).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/classes/join'),
          data: {
            'success': true,
            'data': {
              'id': 1,
              'name': 'CS450: Distributed Systems',
              'code': 'DBDE10',
            },
          },
        ),
      );

      final joined = await repository.joinClass('dbde10');
      expect(joined.id, 1);
      expect(joined.code, 'DBDE10');
      verify(() => mockApiClient.post('/classes/join', data: {'code': 'DBDE10'})).called(1);
    });

    test('createClass sends name and description and returns ClassModel', () async {
      when(() => mockApiClient.post('/classes', data: {
            'name': 'Software Engineering',
            'description': 'Senior capstone',
          })).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/classes'),
          data: {
            'success': true,
            'data': {
              'id': 2,
              'name': 'Software Engineering',
              'code': 'SE2026',
            },
          },
        ),
      );

      final created = await repository.createClass('Software Engineering', 'Senior capstone');
      expect(created.id, 2);
      expect(created.code, 'SE2026');
    });

    test('getUserTeams parses and returns list of TeamModel', () async {
      when(() => mockApiClient.get('/teams')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/teams'),
          data: {
            'success': true,
            'data': [
              {
                'id': 10,
                'name': 'Cloud Ninjas',
                'class_id': 1,
                'member_count': 4,
              }
            ],
          },
        ),
      );

      final teams = await repository.getUserTeams();
      expect(teams.length, 1);
      expect(teams.first.name, 'Cloud Ninjas');
      expect(teams.first.classId, 1);
      expect(teams.first.memberCount, 4);
    });

    test('createTeam sends name and classId and returns TeamModel', () async {
      when(() => mockApiClient.post('/teams', data: {
            'name': 'Alpha Devs',
            'classId': 1,
          })).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/teams'),
          data: {
            'success': true,
            'data': {
              'id': 11,
              'name': 'Alpha Devs',
              'class_id': 1,
            },
          },
        ),
      );

      final created = await repository.createTeam('Alpha Devs', 1);
      expect(created.id, 11);
      expect(created.name, 'Alpha Devs');
    });
  });
}
