import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/auth/data/models/user_model.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}
class MockTasksRepository extends Mock implements ITasksRepository {}

class FakeAuthNotifier extends Notifier<AuthState> implements AuthNotifier {
  final UserModel? initialUser;
  FakeAuthNotifier(this.initialUser);

  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      user: initialUser,
    );
  }

  @override
  Future<void> checkAuthStatus() async {}
  @override
  void clearError() {}
  @override
  void handleUnauthorized() {}
  @override
  Future<bool> login(String email, String password) async => true;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    String? classCode,
  }) async => true;
}

void main() {
  late MockProjectsRepository mockProjects;
  late MockTasksRepository mockTasks;

  const testUser = UserModel(
    id: 1,
    name: 'Aryan Patel',
    username: 'aryan',
    email: 'aryan@example.com',
    role: 'student',
    xp: 350,
    rank: 'Contributor Level 2',
  );

  const sampleProjects = [
    ProjectModel(id: 1, name: 'AI Tutor', status: 'Active', progress: 50),
  ];

  const sampleTasks = [
    TaskModel(id: 1, projectId: 1, title: 'Build UI Component', status: 'In Progress'),
  ];

  setUp(() {
    mockProjects = MockProjectsRepository();
    mockTasks = MockTasksRepository();

    when(() => mockProjects.getUserProjects()).thenAnswer((_) async => sampleProjects);
    when(() => mockTasks.getMyTasks()).thenAnswer((_) async => sampleTasks);
  });

  Widget buildDashboardWidget() {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(testUser)),
        projectsRepositoryProvider.overrideWithValue(mockProjects),
        tasksRepositoryProvider.overrideWithValue(mockTasks),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders navigation destinations and user overview', (tester) async {
      await tester.pumpWidget(buildDashboardWidget());
      await tester.pumpAndSettle();

      // Navigation Bar labels
      expect(find.widgetWithText(NavigationDestination, 'Overview'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Projects'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Tasks'), findsOneWidget);
      expect(find.widgetWithText(NavigationDestination, 'Profile'), findsOneWidget);

      // User Overview Card
      expect(find.text('Aryan Patel'), findsOneWidget);
      expect(find.text('350'), findsOneWidget); // XP
      expect(find.text('Contributor Level 2'), findsOneWidget);

      // Metric tiles
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('switches to Projects tab on tap', (tester) async {
      await tester.pumpWidget(buildDashboardWidget());
      await tester.pumpAndSettle();

      // Tap Projects destination
      await tester.tap(find.widgetWithText(NavigationDestination, 'Projects'));
      await tester.pumpAndSettle();

      // Should display Projects AppBar and project card
      expect(find.text('Active'), findsWidgets);
      expect(find.text('AI Tutor'), findsOneWidget);
    });

    testWidgets('switches to Tasks tab on tap', (tester) async {
      await tester.pumpWidget(buildDashboardWidget());
      await tester.pumpAndSettle();

      // Tap Tasks destination
      await tester.tap(find.widgetWithText(NavigationDestination, 'Tasks'));
      await tester.pumpAndSettle();

      // Should display Task card
      expect(find.text('Build UI Component'), findsOneWidget);
    });

    testWidgets('switches to Profile tab on tap and shows user details', (tester) async {
      await tester.pumpWidget(buildDashboardWidget());
      await tester.pumpAndSettle();

      // Tap Profile destination
      await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
      await tester.pumpAndSettle();

      expect(find.text('@aryan'), findsOneWidget);
      expect(find.text('aryan@example.com'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('respects initialTab parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() => FakeAuthNotifier(testUser)),
            projectsRepositoryProvider.overrideWithValue(mockProjects),
            tasksRepositoryProvider.overrideWithValue(mockTasks),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const DashboardScreen(initialTab: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Build UI Component'), findsOneWidget);
    });
  });
}
