import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_detail_bottom_sheet.dart';

void main() {
  const sampleTask = TaskModel(
    id: 99,
    projectId: 1,
    projectName: 'AI Studio',
    title: 'Write Unit Tests for Phase 4',
    description: 'Ensure 100% test pass on polish features',
    priority: 'urgent',
    xpValue: 80,
    status: 'Planned',
  );

  testWidgets('TaskDetailBottomSheet displays task details and triggers status update', (tester) async {
    int? updatedTaskId;
    String? newUpdatedStatus;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => TaskDetailBottomSheet.show(
                ctx,
                task: sampleTask,
                onStatusChange: (id, status) async {
                  updatedTaskId = id;
                  newUpdatedStatus = status;
                  return true;
                },
              ),
              child: const Text('Open Task Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Task Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Write Unit Tests for Phase 4'), findsOneWidget);
    expect(find.text('AI Studio'), findsOneWidget);
    expect(find.text('Ensure 100% test pass on polish features'), findsOneWidget);
    expect(find.text('+80 XP'), findsOneWidget);

    // Tap "Start Task"
    await tester.tap(find.text('Start Task'));
    await tester.pumpAndSettle();

    expect(updatedTaskId, 99);
    expect(newUpdatedStatus, 'In Progress');
  });
}
