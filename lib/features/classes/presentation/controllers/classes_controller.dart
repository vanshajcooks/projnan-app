import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/class_model.dart';
import '../../data/models/team_model.dart';
import '../../data/repositories/classes_repository.dart';

final classesRepositoryProvider = Provider<IClassesRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ClassesRepository(apiClient: client);
});

class ClassesState {
  final bool isLoading;
  final List<ClassModel> classes;
  final List<TeamModel> teams;
  final String? errorMessage;

  const ClassesState({
    this.isLoading = false,
    this.classes = const [],
    this.teams = const [],
    this.errorMessage,
  });

  ClassesState copyWith({
    bool? isLoading,
    List<ClassModel>? classes,
    List<TeamModel>? teams,
    String? errorMessage,
  }) {
    return ClassesState(
      isLoading: isLoading ?? this.isLoading,
      classes: classes ?? this.classes,
      teams: teams ?? this.teams,
      errorMessage: errorMessage,
    );
  }
}

class ClassesNotifier extends Notifier<ClassesState> {
  @override
  ClassesState build() {
    return const ClassesState(isLoading: false);
  }

  Future<void> fetchClassesAndTeams() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(classesRepositoryProvider);
      final results = await Future.wait([
        repo.getUserClasses(),
        repo.getUserTeams(),
      ]);

      state = state.copyWith(
        isLoading: false,
        classes: results[0] as List<ClassModel>,
        teams: results[1] as List<TeamModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> joinClass(String code) async {
    try {
      final repo = ref.read(classesRepositoryProvider);
      await repo.joinClass(code);
      await fetchClassesAndTeams();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<ClassModel?> createClass(String name, String description) async {
    try {
      final repo = ref.read(classesRepositoryProvider);
      final newClass = await repo.createClass(name, description);
      await fetchClassesAndTeams();
      return newClass;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> createTeam(String name, int classId) async {
    try {
      final repo = ref.read(classesRepositoryProvider);
      await repo.createTeam(name, classId);
      await fetchClassesAndTeams();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final classesNotifierProvider = NotifierProvider<ClassesNotifier, ClassesState>(() {
  return ClassesNotifier();
});
