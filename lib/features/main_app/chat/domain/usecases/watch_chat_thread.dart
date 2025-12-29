import '../entities/chat_message.dart';
import '../repository/chat_repository.dart';

class WatchChatThread {
  final ChatRepository repo;
  WatchChatThread(this.repo);
  Stream<List<ChatMessage>> call(String agentId, String role, {String? saleId}) => repo.watchThread(agentId, role, saleId: saleId);
}