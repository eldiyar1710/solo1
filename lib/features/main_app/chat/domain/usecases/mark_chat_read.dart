import '../repository/chat_repository.dart';

class MarkChatRead {
  final ChatRepository repo;
  MarkChatRead(this.repo);
  Future<void> call(String role, int latestNotMine, {String? saleId}) => repo.markRead(role, latestNotMine, saleId: saleId);
}