import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';

class SyncAgentDataUseCase {
  final AgentRepository repo;
  SyncAgentDataUseCase(this.repo);
  Future<void> call() => repo.sync();
}