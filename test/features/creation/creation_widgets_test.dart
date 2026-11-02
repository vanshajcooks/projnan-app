import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/classes/data/models/class_model.dart';
import 'package:probon_app/features/classes/data/models/team_model.dart';
import 'package:probon_app/features/classes/data/repositories/classes_repository.dart';
import 'package:probon_app/features/classes/presentation/controllers/classes_controller.dart';
import 'package:probon_app/features/classes/presentation/widgets/join_class_dialog.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/widgets/create_project_bottom_sheet.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/widgets/create_task_bottom_sheet.dart';

class MockClassesRepository extends Mock implements IClassesRepository {}
class MockProjectsRepository extends Mock implements IProjectsRepository {}
class MockTasksRepository extends Mock implements ITasksRepository {}

void main() {
  late MockClassesRepository mockClasses;
  late MockProjectsRepository mockProjects;
  late MockTasksRepository mockTasks;

  const sampleClass = ClassModel(
    id: 1,
    name: 'CS450: Distributed Systems',
    code: 'DBDE10',
  );

  const sampleTeam = TeamModel(
    id: 10,
    name: 'Cloud Ninjas',
    classId: 1,
  );

  const sampleProject = ProjectModel(
    id: 101,
    name: 'Cloud Monitor Platform',
    status: 'Active',
    progress: 30,
  );

  setUp(() {
    mockClasses = MockClassesRepository();
    mockProjects = MockProjectsRepository();
    mockTasks = MockTasksRepository();

    when(() => mockClasses.getUserClasses()).thenAnswer((_) async => [sampleClass]);
    when(() => mockClasses.getUserTeams()).thenAnswer((_) async => [sampleTeam]);
    when(() => mockProjects.getUserProjects()).thenAnswer((_) async => [sampleProject]);
    when(() => mockTasks.getMyTasks()).thenAnswer((_) async => []);
  });

  group('Creation & Class Management Widgets Tests', () {
    testWidgets('JoinClassDialog renders and handles code submission', (tester) async {
      when(() => mockClasses.joinClass('DBDE10')).thenAnswer((_) async => sampleClass);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            classesRepositoryProvider.overrideWithValue(mockClasses),
            projectsRepositoryProvider.overrideWithValue(mockProjects),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: JoinClassDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Join a Class'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter code
      await tester.enterText(find.byType(TextField), 'dbde10');
      await tester.tap(find.text('Join Class'));
      await tester.pumpAndSettle();

      verify(() => mockClasses.joinClass('DBDE10')).called(1);
    });

    testWidgets('CreateProjectBottomSheet renders inputs and creates project', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockProjects.createProject(
            name: any(named: 'name'),
            description: any(named: 'description'),
            teamId: any(named: 'teamId'),
            classId: any(named: 'classId'),
            tags: any(named: 'tags'),
            goals: any(named: 'goals'),
          )).thenAnswer((_) async => sampleProject);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            classesRepositoryProvider.overrideWithValue(mockClasses),
            projectsRepositoryProvider.overrideWithValue(mockProjects),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: CreateProjectBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New Project'), findsOneWidget);
      expect(find.text('Project Name *'), findsOneWidget);

      // Fill in Name and Description
      await tester.enterText(find.widgetWithText(TextField, 'Project Name *'), 'AI Tutor Platform');
      await tester.enterText(find.widgetWithText(TextField, 'Description *'), 'Intelligent tutoring system');

      // Scroll and Tap Create Project
      await tester.ensureVisible(find.text('Create Project'));
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      verify(() => mockProjects.createProject(
            name: 'AI Tutor Platform',
            description: 'Intelligent tutoring system',
            teamId: any(named: 'teamId'),
            classId: any(named: 'classId'),
            tags: any(named: 'tags'),
            goals: any(named: 'goals'),
          )).called(1);
    });

    testWidgets('CreateTaskBottomSheet renders priority chips and creates task', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockTasks.createTask(
            projectId: any(named: 'projectId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            taskType: any(named: 'taskType'),
            xpValue: any(named: 'xpValue'),
          )).thenAnswer((_) async => const TaskModel(id: 1, title: 'Write Tests', projectId: 101));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsRepositoryProvider.overrideWithValue(mockProjects),
            tasksRepositoryProvider.overrideWithValue(mockTasks),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: CreateTaskBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New Task'), findsOneWidget);
      expect(find.text('Task Title *'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);

      // Select High priority
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Enter task title
      await tester.enterText(find.widgetWithText(TextField, 'Task Title *'), 'Build Auth Middleware');

      // Scroll and Submit
      await tester.ensureVisible(find.text('Create Task'));
      await tester.tap(find.text('Create Task'));
      await tester.pumpAndSettle();

      verify(() => mockTasks.createTask(
            projectId: 101,
            title: 'Build Auth Middleware',
            description: any(named: 'description'),
            priority: 'high',
            taskType: any(named: 'taskType'),
            xpValue: any(named: 'xpValue'),
          )).called(1);
    });
  });
}
