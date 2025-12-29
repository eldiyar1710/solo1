import 'package:flutter_test/flutter_test.dart';
import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';
import 'package:solo1/features/auth/domain/usecases/register_agent_use_case.dart';

class FakeRepo implements AgentRepository {
  @override
  Future<AgentEntity?> getCurrent() async => null;

  @override
  Future<AgentEntity> register({required String fullName, required String phone, required String email, required String password}) async {
    return AgentEntity(
      uid: 'uid-xyz',
      fullName: fullName,
      phone: phone,
      email: email,
      agentId: 'AGT-test',
      createdAt: DateTime.now(),
      role: 'agent',
      status: 'active',
    );
  }

  @override
  Future<AgentEntity> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sync() async {}
}

void main() {
  test('RegisterAgentUseCase returns AgentEntity with provided fields', () async {
    final useCase = RegisterAgentUseCase(FakeRepo());
    final agent = await useCase(fullName: 'Иван Иванов', phone: '7770000000', email: 'agent@example.com', password: 'password');
    expect(agent.fullName, 'Иван Иванов');
    expect(agent.phone, '7770000000');
    expect(agent.email, 'agent@example.com');
    expect(agent.role, 'agent');
    expect(agent.status, 'active');
  });
}