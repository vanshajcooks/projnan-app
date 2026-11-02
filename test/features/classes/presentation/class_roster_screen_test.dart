import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/auth/data/models/user_model.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/classes/data/models/class_roster_model.dart';
import 'package:probon_app/features/classes/data/repositories/classes_repository.dart';
import 'package:probon_app/features/classes/presentation/controllers/classes_controller.dart';
import 'package:probon_app/features/classes/presentation/screens/class_roster_screen.dart';

class MockClassesRepository extends Mock implements IClassesRepository {}

void main() {
  late MockClassesRepository mockClassesRepository;

  const testTeacher = UserModel(
    id: 1,
    name: 'Prof. Davis',
    username: 'davis',
    email: 'davis@example.com',
    role: 'teacher',
  );

  const testRoster = ClassRosterDetailModel(
    id: 1,
    name: 'Advanced Software Capstone',
    code: 'CS401',
    description: 'Senior capstone project engineering course.',
    teacherId: 1,
    teacherName: 'Prof. Davis',
    teacherEmail: 'davis@example.com',
    members: [
      ClassMemberModel(
        id: 1,
        name: 'Prof. Davis',
        username: 'davis',
        email: 'davis@example.com',
        role: 'teacher',
        xp: 1500,
        points: 400,
      ),
      ClassMemberModel(
        id: 102,
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
        role: 'student',
        xp: 850,
        points: 120,
      ),
    ],
    teams: [
      ClassTeamSummaryModel(
        id: 10,
        name: 'Team Falcon',
        leaderId: 102,
        leaderName: 'John Doe',
        memberCount: 4,
        projectCount: 1,
      ),
    ],
    projects: [
      ClassProjectSummaryModel(
        id: 20,
        name: 'Autonomous Drone Fleet',
        status: 'active',
        teamName: 'Team Falcon',
      ),
    ],
  );

  setUp(() {
    mockClassesRepository = MockClassesRepository();
    when(() => mockClassesRepository.getClassRoster(1)).thenAnswer((_) async => testRoster);
    when(() => mockClassesRepository.removeStudentFromClass(1, 102)).thenAnswer((_) async => true);
    when(() => mockClassesRepository.getUserClasses()).thenAnswer((_) async => []);
    when(() => mockClassesRepository.getUserTeams()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        classesRepositoryProvider.overrideWithValue(mockClassesRepository),
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(testTeacher)),
      ],
      child: const MaterialApp(
        home: ClassRosterScreen(classId: 1),
      ),
    );
  }

  testWidgets('ClassRosterScreen renders class details and removes student on confirmation', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Class details
    expect(find.text('Advanced Software Capstone'), findsAtLeastNWidgets(1));
    expect(find.text('CS401'), findsOneWidget);
    expect(find.text('Instructor: Prof. Davis'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com · 850 XP'), findsOneWidget);

    // Tap Remove student icon button
    expect(find.byTooltip('Remove Student'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Student'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Remove Student'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Are you sure you want to remove John Doe'), findsOneWidget);

    // Confirm removal
    await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
    await tester.pumpAndSettle();

    verify(() => mockClassesRepository.removeStudentFromClass(1, 102)).called(1);
  });

  testWidgets('ClassRosterScreen switches to Teams and Projects tabs', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Switch to Teams tab
    await tester.tap(find.text('Teams (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Team Falcon'), findsOneWidget);
    expect(find.textContaining('Leader: John Doe'), findsOneWidget);

    // Switch to Projects tab
    await tester.tap(find.text('Projects (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Autonomous Drone Fleet'), findsOneWidget);
    expect(find.text('Team: Team Falcon'), findsOneWidget);
  });
}

class FakeAuthNotifier extends Notifier<AuthState> implements AuthNotifier {
  final UserModel? initialUser;
  FakeAuthNotifier(this.initialUser);

  @override
  AuthState build() => AuthState(status: AuthStatus.authenticated, user: initialUser);

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
  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async => {'success': true};
  @override
  Future<Map<String, dynamic>> resendVerification() async => {'success': true};
}
