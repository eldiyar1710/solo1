import 'package:hive/hive.dart';
import '../models/agent_rank_model.dart';

class HomeLeaderboardLocalDataSource {
  static const _box = 'users';
  Future<List<AgentRankModel>> load(String period) async {
    final box = Hive.box(_box);
    final key = 'leaderboard_$period';
    final raw = (box.get(key) as List?) ?? [];
    if (raw.isNotEmpty) {
      return raw.map((e) => AgentRankModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    final demo = [
      AgentRankModel(id: 'a1', name: 'Ayman М.', sales: 15, bonusPercent: 1.0, rank: 1),
      AgentRankModel(id: 'a2', name: 'Sunqar К.', sales: 12, bonusPercent: 0.5, rank: 2),
      AgentRankModel(id: 'a3', name: 'Eldar С.', sales: 10, bonusPercent: 0.3, rank: 3),
    ];
    return demo;
  }
  Future<void> save(String period, List<AgentRankModel> ranks) async {
    final box = Hive.box(_box);
    final key = 'leaderboard_$period';
    await box.put(key, ranks.map((e) => e.toJson()).toList());
  }
}