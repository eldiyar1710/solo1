class ModerationRequestEntity {
  final String id;
  final String agentId;
  final String title;
  final DateTime createdAt;
  final String status;
  final String? comment;
  const ModerationRequestEntity({required this.id, required this.agentId, required this.title, required this.createdAt, required this.status, this.comment});
}