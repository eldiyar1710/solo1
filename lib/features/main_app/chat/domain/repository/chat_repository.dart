import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchThread(String agentId, String role, {String? saleId});
  Future<void> send(String agentId, String role, String text, {String? saleId});
  Future<void> sendAttachment(String agentId, String role, {String? saleId, required String kind, String? url, String? path, String? name, String? mime, int? size, String? text});
  Future<void> markRead(String role, int latestNotMine, {String? saleId});
  int? getLastSeen(String role, {String? saleId});
}