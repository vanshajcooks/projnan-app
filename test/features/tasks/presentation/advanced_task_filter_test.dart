import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/screens/tasks_tab.dart';

class MockTasksRepository extends Mock implements ITasksRepository {}

void main() {
  late MockTasksRepository mockTasksRepository;

  final sampleTasks = [
    const TaskModel(
      id: 1,
      projectId: 10,
      projectName: 'Probon Platform',
      title: 'Fix authentication memory leak',
      description: 'Profile leak in stream listener',
      status: 'Planned',
      priority: 'urgent',
      taskType: 'weekly',
      xpValue: 150,
    ),
    const TaskModel(
      id: 2,
      projectId: 10,
      projectName: 'Probon Platform',
      title: 'Design UI dark theme components',
      description: 'Implement AMOLED theme',
      status: 'In Progress',
      priority: 'medium',
      taskType: 'quick',
      xpValue: 50,
    ),
    const TaskModel(
      id: 3,
      projectId: 20,
      projectName: 'Campus App',
      title: 'Add automated tests for payment API',
      description: 'Write mock unit tests',
      status: 'Planned',
      priority: 'high',
      taskType: 'milestone',
      xpValue: 120,
    ),
  ];

  setUp(() {
    mockTasksRepository = MockTasksRepository();
    when(() => mockTasksRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
    when(() => mockTasksRepository.getAllTasks()).thenAnswer((_) async => sampleTasks);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(mockTasksRepository),
      ],
      child: const MaterialApp(
        home: TasksTab(),
      ),
    );
  }

  testWidgets('TasksTab filters tasks by search keyword in real time', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify all 3 tasks initially present
    expect(find.text('Fix authentication memory leak'), findsOneWidget);
    expect(find.text('Design UI dark theme components'), findsOneWidget);
    expect(find.text('Add automated tests for payment API'), findsOneWidget);

    // Type search query
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'memory leak');
    await tester.pumpAndSettle();

    // Only memory leak task should be visible
    expect(find.text('Fix authentication memory leak'), findsOneWidget);
    expect(find.text('Design UI dark theme components'), findsNothing);
    expect(find.text('Add automated tests for payment API'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    expect(find.text('Fix authentication memory leak'), findsOneWidget);
    expect(find.text('Design UI dark theme components'), findsOneWidget);
  });

  testWidgets('TasksTab filters tasks by priority chip', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Ensure 'Urgent' priority chip is visible in the horizontal scroll view
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Urgent'));
    await tester.pumpAndSettle();

    // Tap 'Urgent' priority chip
    await tester.tap(find.widgetWithText(FilterChip, 'Urgent'));
    await tester.pumpAndSettle();

    expect(find.text('Fix authentication memory leak'), findsOneWidget);
    expect(find.text('Design UI dark theme components'), findsNothing);
    expect(find.text('Add automated tests for payment API'), findsNothing);
  });
}
