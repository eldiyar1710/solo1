import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';

class RegisterAgentUseCase {
  final AgentRepository repo;
  RegisterAgentUseCase(this.repo);
  Future<AgentEntity> call({required String fullName, required String phone, required String email, required String password}) {
    return repo.register(fullName: fullName, phone: phone, email: email, password: password);
  }
}