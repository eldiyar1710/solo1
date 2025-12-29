import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';

class LoginAgentUseCase {
  final AgentRepository repo;
  LoginAgentUseCase(this.repo);
  Future<AgentEntity> call({required String email, required String password}) {
    return repo.login(email: email, password: password);
  }
}