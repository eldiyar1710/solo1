import 'package:flutter_test/flutter_test.dart';
import 'package:solo1/features/auth/data/repositories/agent_repository_impl.dart';
import 'package:solo1/features/auth/data/models/agent_model.dart';
import 'package:solo1/features/auth/data/datasources/local/agent_local_datasource.dart';
import 'package:solo1/features/auth/data/datasources/remote/agent_remote_datasource.dart';

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

class FakeAgentRemoteDataSource implements AgentRemoteDataSourceBase {
  @override
  Future<void> saveAgent(AgentModel model) async {}
  @override
  Future<AgentModel?> getAgent(String uid) async => null;
}

void main() {
  test('Login with test account works locally and marked as test', () async {
    final local = FakeAgentLocalDataSource();
    final repo = AgentRepositoryImpl(local: local, remote: FakeAgentRemoteDataSource());
    final agent = await repo.login(email: 'test@solo1.app', password: '12345678');
    expect(agent.status, 'test');
    expect(agent.agentId.startsWith('TEST-'), true);
  });
}