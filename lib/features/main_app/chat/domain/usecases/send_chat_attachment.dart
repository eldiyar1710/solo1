import '../repository/chat_repository.dart';

class SendChatAttachment {
  final ChatRepository repo;
  SendChatAttachment(this.repo);
  Future<void> call(String agentId, String role,
      {String? saleId, required String kind, String? url, String? path, String? name, String? mime, int? size, String? text}) {
    return repo.sendAttachment(agentId, role, saleId: saleId, kind: kind, url: url, path: path, name: name, mime: mime, size: size, text: text);
  }
}