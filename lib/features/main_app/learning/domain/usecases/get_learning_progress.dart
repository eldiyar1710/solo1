import '../entities/learning_progress.dart';
import '../repository/learning_repository.dart';

class GetLearningProgress {
  final LearningRepository repo;
  GetLearningProgress(this.repo);
  Future<LearningProgress> call() => repo.getProgress();
}