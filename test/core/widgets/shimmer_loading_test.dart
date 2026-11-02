import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/widgets/shimmer_loading.dart';
import 'package:probon_app/features/projects/presentation/widgets/project_card_skeleton.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card_skeleton.dart';

void main() {
  group('Shimmer & Skeletons Tests', () {
    testWidgets('ShimmerLoading renders child correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              child: Text('Shimmering content'),
            ),
          ),
        ),
      );

      expect(find.text('Shimmering content'), findsOneWidget);
    });

    testWidgets('ProjectCardSkeleton renders without layout errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(ProjectCardSkeleton), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('TaskCardSkeleton renders without layout errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(TaskCardSkeleton), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });
}
