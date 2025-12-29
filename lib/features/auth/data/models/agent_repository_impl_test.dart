import 'package:flutter_test/flutter_test.dart';
import 'package:solo1/features/auth/data/datasources/local/agent_local_datasource.dart';
import 'package:solo1/features/auth/data/datasources/remote/agent_remote_datasource.dart';
import 'package:solo1/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:solo1/features/auth/data/models/agent_model.dart';
import 'package:solo1/features/auth/data/repositories/agent_repository_impl.dart';

class FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  @override
  Future<String> register(String email, String password) async => 'uid-123';
  @override
  Future<String> login(String email, String password) async => 'uid-123';
  @override
  String? currentUid() => 'uid-123';
}

class FakeAgentRemoteDataSource extends AgentRemoteDataSource {
  final Map<String, Map<String, dynamic>> _store = {};
  @override
  Future<void> saveAgent(AgentModel model) async {
    _store[model.uid] = model.toMap();
  }

  @override
  Future<AgentModel?> getAgent(String uid) async {
    final m = _store[uid];
    if (m == null) return null;
    final map = Map<String, dynamic>.from(m);
    map['uid'] = uid;
    return AgentModel.fromMap(map);
  }
}

class FakeAgentLocalDataSource extends AgentLocalDataSource {
  Map<String, dynamic>? _local;
  @override
  Future<void> saveLocal(AgentModel m) async {
    _local = m.toMap();
  }

  @override
  Future<AgentModel?> loadLocal() async {
    final raw = _local;
    if (raw == null) return null;
    return AgentModel.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> clear() async {
    _local = null;
  }
}

void main() {
  test('AgentRepositoryImpl.register creates and returns AgentEntity with defaults', () async {
    final repo = AgentRepositoryImpl(
      local: FakeAgentLocalDataSource(),
      auth: FakeAuthRemoteDataSource(),
      remote: FakeAgentRemoteDataSource(),
    );
    final agent = await repo.register(fullName: 'Иван Иванов', phone: '7770000000', email: 'agent@example.com', password: 'password');
    expect(agent.uid, 'uid-123');
    expect(agent.role, 'agent');
    expect(agent.status, 'active');
  });

  test('AgentRepositoryImpl.login returns local data when available', () async {
    final local = FakeAgentLocalDataSource();
    final auth = FakeAuthRemoteDataSource();
    final remote = FakeAgentRemoteDataSource();
    final repo = AgentRepositoryImpl(local: local, auth: auth, remote: remote);

    final now = DateTime.now().millisecondsSinceEpoch;
    await local.saveLocal(AgentModel(uid: 'uid-123', fullName: 'Иван Иванов', phone: '7770000000', email: 'agent@example.com', agentId: 'AGT-$now', createdAt: now, role: 'agent', status: 'active'));

    final agent = await repo.login(email: 'agent@example.com', password: 'password');
    expect(agent.uid, 'uid-123');
    expect(agent.fullName, 'Иван Иванов');
  });

  test('AgentRepositoryImpl.login fetches remote when local missing', () async {
    final local = FakeAgentLocalDataSource();
    final auth = FakeAuthRemoteDataSource();
    final remote = FakeAgentRemoteDataSource();
    final repo = AgentRepositoryImpl(local: local, auth: auth, remote: remote);

    final now = DateTime.now().millisecondsSinceEpoch;
    await remote.saveAgent(AgentModel(uid: 'uid-123', fullName: 'Петр Петров', phone: '7700000000', email: 'agent@example.com', agentId: 'AGT-$now', createdAt: now));

    final agent = await repo.login(email: 'agent@example.com', password: 'password');
    expect(agent.uid, 'uid-123');
    expect(agent.fullName, 'Петр Петров');
  });
}