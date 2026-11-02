import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/presentation/widgets/project_detail_bottom_sheet.dart';

void main() {
  const sampleProject = ProjectModel(
    id: 1,
    name: 'Collaborative Code Studio',
    description: 'An advanced real-time pair programming mobile app',
    className: 'Software Engineering',
    teamName: 'Team Nova',
    progress: 75,
    status: 'Active',
    goals: ['Implement Auth', 'Build Task Board'],
    tags: ['Flutter', 'Node.js'],
  );

  testWidgets('ProjectDetailBottomSheet displays all project information', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ProjectDetailBottomSheet.show(ctx, sampleProject),
              child: const Text('Open Project Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Project Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Collaborative Code Studio'), findsOneWidget);
    expect(find.text('Team Nova'), findsOneWidget);
    expect(find.text('Software Engineering'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('An advanced real-time pair programming mobile app'), findsOneWidget);
    expect(find.text('Implement Auth'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });
}
