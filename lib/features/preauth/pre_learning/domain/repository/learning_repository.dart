import '../entities/test_result.dart';
abstract class LearningRepository {
  TestResult? get last;
  void save(TestResult result);
  Future<void> load();
}