import '../entities/test_result.dart';
import '../repository/learning_repository.dart';

class SaveTestResult {
  final LearningRepository repo;
  SaveTestResult(this.repo);
  void call(double score, bool passed) {
    repo.save(TestResult(score: score, passed: passed, at: DateTime.now()));
  }
}