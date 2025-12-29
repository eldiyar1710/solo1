import '../repository/chat_repository.dart';

class SendChatMessage {
  final ChatRepository repo;
  SendChatMessage(this.repo);
  Future<void> call(String agentId, String role, String text, {String? saleId}) => repo.send(agentId, role, text, saleId: saleId);
}