import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_result_model.dart';

class LearningLocalDataSource {
  TestResultModel? _last;
  TestResultModel? get last => _last;
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasScore = prefs.containsKey('learning_test_score');
    final hasPassed = prefs.containsKey('learning_test_passed');
    if (hasScore && hasPassed) {
      _last = TestResultModel(
        score: prefs.getDouble('learning_test_score') ?? 0.0,
        passed: prefs.getBool('learning_test_passed') ?? false,
        at: DateTime.fromMillisecondsSinceEpoch(prefs.getInt('learning_test_at') ?? DateTime.now().millisecondsSinceEpoch),
      );
    }
  }
  void save(TestResultModel model) {
    _last = model;
    SharedPreferences.getInstance().then((p) {
      p.setDouble('learning_test_score', model.score);
      p.setBool('learning_test_passed', model.passed);
      p.setInt('learning_test_at', model.at.millisecondsSinceEpoch);
    });
  }
}