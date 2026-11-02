import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/screens/tasks_tab.dart';
import 'package:probon_app/features/tasks/presentation/widgets/submit_evidence_dialog.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:probon_app/features/tasks/presentation/widgets/verify_task_dialog.dart';

class MockTasksRepository extends Mock implements ITasksRepository {}

void main() {
  late MockTasksRepository mockRepository;

  const sampleEvidenceTask = TaskModel(
    id: 101,
    projectId: 1,
    projectName: 'Cloud Monitor',
    title: 'Implement Prometheus Exporter',
    description: 'Metrics endpoint on :9090',
    status: 'Verification Pending',
    verificationStatus: 'pending',
    completionEvidence: 'PR #42: https://github.com/cloudninjas/monitor-daemon/pull/42',
    xpValue: 120,
  );

  setUp(() {
    mockRepository = MockTasksRepository();
  });

  Widget buildScoped(Widget child) {
    return ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('SubmitEvidenceDialog submits evidence and shows toast', (tester) async {
    when(() => mockRepository.submitEvidence(101, any())).thenAnswer((_) async => sampleEvidenceTask);

    await tester.pumpWidget(
      buildScoped(
        Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => SubmitEvidenceDialog.show(ctx, taskId: 101, taskTitle: 'Prometheus Exporter'),
            child: const Text('Open Submit Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Submit Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Task Evidence'), findsOneWidget);
    expect(find.textContaining('Prometheus Exporter'), findsOneWidget);

    // Enter evidence
    final input = find.byType(TextFormField);
    await tester.enterText(input, 'PR #42 merged: https://github.com/cloudninjas/monitor-daemon/pull/42');
    await tester.pumpAndSettle();

    // Tap Submit
    await tester.tap(find.text('Submit Evidence'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.submitEvidence(
          101,
          'PR #42 merged: https://github.com/cloudninjas/monitor-daemon/pull/42',
        )).called(1);
    expect(find.text('Submit Task Evidence'), findsNothing);
  });

  testWidgets('VerifyTaskDialog approves task and invokes repository', (tester) async {
    final verified = sampleEvidenceTask.copyWith(status: 'Completed', verificationStatus: 'verified');
    when(() => mockRepository.verifyTask(
          101,
          approved: true,
          feedbackNote: any(named: 'feedbackNote'),
        )).thenAnswer((_) async => verified);

    await tester.pumpWidget(
      buildScoped(
        Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => VerifyTaskDialog.show(ctx, task: sampleEvidenceTask),
            child: const Text('Open Verify Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Verify Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Teacher Verification'), findsOneWidget);
    expect(find.text(sampleEvidenceTask.completionEvidence!), findsOneWidget);

    // Approve is selected by default
    await tester.tap(find.text('Confirm Approval'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.verifyTask(101, approved: true, feedbackNote: '')).called(1);
    expect(find.text('Teacher Verification'), findsNothing);
  });

  testWidgets('TaskCard displays pending review badge and completion evidence snippet', (tester) async {
    await tester.pumpWidget(
      buildScoped(
        const TaskCard(task: sampleEvidenceTask),
      ),
    );

    expect(find.text('Pending Review'), findsOneWidget);
    expect(find.text(sampleEvidenceTask.completionEvidence!), findsOneWidget);
    expect(find.text('+120 XP'), findsOneWidget);
  });

  testWidgets('TasksTab allows switching between My Tasks and All Team Tasks', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepository.getMyTasks()).thenAnswer((_) async => [sampleEvidenceTask]);
    when(() => mockRepository.getAllTasks()).thenAnswer((_) async => [sampleEvidenceTask]);

    await tester.pumpWidget(buildScoped(const TasksTab()));
    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('All Team Tasks'), findsOneWidget);

    // Tap All Team Tasks
    await tester.tap(find.text('All Team Tasks'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.getAllTasks()).called(1);
  });
}
