class ModerationRequestModel {
  final String id;
  final String agentId;
  final String title;
  final int createdAt;
  final String status;
  final String? comment;
  const ModerationRequestModel({required this.id, required this.agentId, required this.title, required this.createdAt, required this.status, this.comment});
  factory ModerationRequestModel.fromJson(Map<String, dynamic> m) => ModerationRequestModel(
        id: (m['id'] ?? m['requestId']) as String,
        agentId: (m['agentId'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        createdAt: (m['createdAt'] ?? 0) as int,
        status: (m['status'] ?? 'pending') as String,
        comment: m['comment'] as String?,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'agentId': agentId,
        'title': title,
        'createdAt': createdAt,
        'status': status,
        'comment': comment,
      };
}