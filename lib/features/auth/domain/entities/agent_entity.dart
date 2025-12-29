class AgentEntity {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String agentId;
  final DateTime createdAt;
  final String role;
  final String status;
  const AgentEntity({required this.uid, required this.fullName, required this.phone, required this.email, required this.agentId, required this.createdAt, this.role = 'agent', this.status = 'active'});
}