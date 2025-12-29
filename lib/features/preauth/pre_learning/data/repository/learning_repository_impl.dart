import '../../domain/repository/learning_repository.dart';
import '../../domain/entities/test_result.dart';
import '../datasource/learning_local_datasource.dart';
import '../models/test_result_model.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningLocalDataSource ds;
  LearningRepositoryImpl(this.ds);
  @override
  TestResult? get last => ds.last;
  @override
  void save(TestResult result) => ds.save(TestResultModel(score: result.score, passed: result.passed, at: result.at));
  @override
  Future<void> load() => ds.load();
}