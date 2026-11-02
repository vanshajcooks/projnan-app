import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/screens/explore_projects_screen.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}

void main() {
  late MockProjectsRepository mockRepo;

  final sampleProjects = [
    const ProjectModel(
      id: 1,
      name: 'AI Learning Studio',
      description: 'Intelligent capstone tutor for students',
      status: 'Active',
      progress: 60,
      tags: ['AI', 'Flutter'],
    ),
    const ProjectModel(
      id: 2,
      name: 'Cloud Telemetry Engine',
      description: 'High throughput metrics collector',
      status: 'Completed',
      progress: 100,
      tags: ['Cloud', 'Node.js'],
    ),
  ];

  setUp(() {
    mockRepo = MockProjectsRepository();
    when(() => mockRepo.searchProjects(
          query: any(named: 'query'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => sampleProjects);
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        home: ExploreProjectsScreen(),
      ),
    );
  }

  testWidgets('renders ExploreProjectsScreen with search bar, tags, and projects', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Explore Capstones'), findsOneWidget);
    expect(find.text('AI Learning Studio'), findsOneWidget);
    expect(find.text('Cloud Telemetry Engine'), findsOneWidget);
    expect(find.text('2 Capstone Projects'), findsOneWidget);
  });

  testWidgets('filters projects in real time when typing in search bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Telemetry');
    await tester.pumpAndSettle();

    expect(find.text('Cloud Telemetry Engine'), findsOneWidget);
    expect(find.text('AI Learning Studio'), findsNothing);
    expect(find.text('1 Capstone Projects'), findsOneWidget);
  });

  testWidgets('filters projects by tech tag chip', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap AI tag chip
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.text('AI Learning Studio'), findsOneWidget);
    expect(find.text('Cloud Telemetry Engine'), findsNothing);
  });
}
