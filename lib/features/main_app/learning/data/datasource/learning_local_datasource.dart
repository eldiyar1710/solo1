import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_progress_model.dart';

class LearningLocalDataSource {
  static const _kKey = 'learning_progress';
  static const _kLessonsKey = 'learning_lessons_progress';
  Future<LearningProgressModel> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_kKey) ?? 0;
    return LearningProgressModel(percent: v);
  }
  Future<void> save(LearningProgressModel m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kKey, m.percent);
  }
  Future<Map<String, int>> loadLessonsProgress() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kLessonsKey);
    if (s == null || s.isEmpty) return {};
    final map = <String, int>{};
    for (final part in s.split(',')) {
      final kv = part.split(':');
      if (kv.length == 2) {
        final id = kv[0];
        final val = int.tryParse(kv[1]) ?? 0;
        map[id] = val;
      }
    }
    return map;
  }
  Future<void> saveLessonProgress(String id, int percent) async {
    final p = await SharedPreferences.getInstance();
    final current = await loadLessonsProgress();
    current[id] = percent.clamp(0, 100);
    final s = current.entries.map((e) => '${e.key}:${e.value}').join(',');
    await p.setString(_kLessonsKey, s);
  }
}