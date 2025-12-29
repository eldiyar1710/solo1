import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/learning/data/datasource/learning_local_datasource.dart';
import 'package:solo1/features/main_app/learning/data/repository/learning_repository_impl.dart';
import 'package:solo1/features/main_app/learning/domain/entities/learning_progress.dart';
import 'package:solo1/features/main_app/learning/domain/usecases/get_learning_progress.dart';
import 'package:solo1/features/main_app/learning/domain/repository/learning_repository.dart';

final learningRepositoryProvider = Provider((ref) => LearningRepositoryImpl(local: LearningLocalDataSource()));

class LearningState {
  final LearningProgress progress;
  final bool loading;
  const LearningState({this.progress = const LearningProgress(percent: 0), this.loading = false});
  LearningState copyWith({LearningProgress? progress, bool? loading}) => LearningState(progress: progress ?? this.progress, loading: loading ?? this.loading);
}

class LearningController extends StateNotifier<LearningState> {
  final GetLearningProgress getProgress;
  final LearningRepository _repo;
  LearningController(this.getProgress, this._repo) : super(const LearningState());
  Future<void> load() async {
    state = state.copyWith(loading: true);
    final p = await getProgress();
    state = LearningState(progress: p, loading: false);
  }
  Future<void> setLessonPercent(String lessonId, int percent) async {
    await _repo.setLessonProgress(lessonId, percent);
    final map = await _repo.getLessonsProgress();
    if (map.isNotEmpty) {
      final avg = map.values.isEmpty ? 0 : (map.values.reduce((a, b) => a + b) / map.values.length).round();
      await _repo.setProgress(LearningProgress(percent: avg));
      state = state.copyWith(progress: LearningProgress(percent: avg));
    }
  }
}

final learningProvider = StateNotifierProvider<LearningController, LearningState>((ref) {
  final repo = ref.read(learningRepositoryProvider);
  return LearningController(GetLearningProgress(repo), repo);
});

final lessonsProgressProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(learningProvider); // обновлять список уроков при изменении общего прогресса
  final repo = ref.read(learningRepositoryProvider);
  return repo.getLessonsProgress();
});

final activeLessonIdProvider = StateProvider<String?>((ref) => null);
final toastProvider = StateProvider<String?>((ref) => null);
final sendDocsOverlayVisibleProvider = StateProvider<bool>((ref) => false);
final docsSubmittedProvider = StateProvider<bool>((ref) => false);
final docsFilesProvider = StateProvider<Map<String, String?>>((ref) => {
  'front': null,
  'back': null,
  'selfie': null,
});
