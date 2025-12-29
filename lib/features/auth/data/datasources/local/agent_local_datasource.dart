import 'package:hive/hive.dart';
import 'package:solo1/features/auth/data/models/agent_model.dart';

class AgentLocalDataSource {
  static const boxName = 'userBox';
  Future<void> saveLocal(AgentModel m) async {
    final box = Hive.box(boxName);
    await box.put('agent', m.toMap());
  }
  Future<AgentModel?> loadLocal() async {
    final box = Hive.box(boxName);
    final raw = box.get('agent');
    if (raw is Map) {
      return AgentModel.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }
  Future<void> clear() async {
    final box = Hive.box(boxName);
    await box.delete('agent');
  }
}