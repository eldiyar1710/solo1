import 'package:firebase_database/firebase_database.dart';
import 'package:solo1/features/auth/data/models/agent_model.dart';

abstract class AgentRemoteDataSourceBase {
  Future<void> saveAgent(AgentModel model);
  Future<AgentModel?> getAgent(String uid);
}

class AgentRemoteDataSource implements AgentRemoteDataSourceBase {
  final FirebaseDatabase db;
  AgentRemoteDataSource({FirebaseDatabase? database}) : db = database ?? FirebaseDatabase.instance;
  @override
  Future<void> saveAgent(AgentModel model) async {
    await db.ref('/agents/${model.uid}').set(model.toMap());
  }
  @override
  Future<AgentModel?> getAgent(String uid) async {
    try {
      final snap = await db.ref('/agents/$uid').get();
      if (!snap.exists) return null;
      final m = Map<String, dynamic>.from(snap.value as Map);
      m['uid'] = uid;
      return AgentModel.fromMap(m);
    } catch (_) {
      return null;
    }
  }
}