class AgentModel {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String agentId;
  final int createdAt;
  final String role;
  final String status;
  const AgentModel({required this.uid, required this.fullName, required this.phone, required this.email, required this.agentId, required this.createdAt, this.role = 'agent', this.status = 'active'});
  factory AgentModel.fromMap(Map<String, dynamic> m) => AgentModel(
        uid: m['uid'] as String,
        fullName: m['fullName'] as String,
        phone: m['phone'] as String,
        email: m['email'] as String,
        agentId: m['agentId'] as String,
        createdAt: m['createdAt'] as int,
        role: (m['role'] as String?) ?? 'agent',
        status: (m['status'] as String?) ?? 'active',
      );
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'agentId': agentId,
        'createdAt': createdAt,
        'role': role,
        'status': status,
      };
}