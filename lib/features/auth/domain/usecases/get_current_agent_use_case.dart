import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';

class GetCurrentAgentUseCase {
  final AgentRepository repo;
  GetCurrentAgentUseCase(this.repo);
  Future<AgentEntity?> call() => repo.getCurrent();
}