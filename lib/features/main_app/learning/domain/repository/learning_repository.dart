import '../entities/learning_progress.dart';

abstract class LearningRepository {
  Future<LearningProgress> getProgress();
  Future<void> setProgress(LearningProgress p);
  Future<Map<String, int>> getLessonsProgress();
  Future<void> setLessonProgress(String id, int percent);
}