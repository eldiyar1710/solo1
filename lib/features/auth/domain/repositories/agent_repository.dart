import 'package:solo1/features/auth/domain/entities/agent_entity.dart';

abstract class AgentRepository {
  Future<AgentEntity?> getCurrent();
  Future<AgentEntity> register({required String fullName, required String phone, required String email, required String password});
  Future<AgentEntity> login({required String email, required String password});
  Future<void> sync();
}