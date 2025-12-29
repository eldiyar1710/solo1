import '../../data/datasource/learning_local_datasource.dart';
import '../../data/models/learning_progress_model.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/repository/learning_repository.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningLocalDataSource local;
  LearningRepositoryImpl({required this.local});
  @override
  Future<LearningProgress> getProgress() async {
    final m = await local.load();
    return LearningProgress(percent: m.percent);
  }
  @override
  Future<void> setProgress(LearningProgress p) {
    return local.save(LearningProgressModel(percent: p.percent));
  }
  @override
  Future<Map<String, int>> getLessonsProgress() {
    return local.loadLessonsProgress();
  }
  @override
  Future<void> setLessonProgress(String id, int percent) {
    return local.saveLessonProgress(id, percent);
  }
}