import '../../domain/entities/chat_message.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasource/chat_remote_datasource.dart';
import '../datasource/chat_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  final ChatLocalDataSource local;
  ChatRepositoryImpl({ChatRemoteDataSource? remote, ChatLocalDataSource? local})
      : remote = remote ?? ChatRemoteDataSource(),
        local = local ?? ChatLocalDataSource();
  @override
  Stream<List<ChatMessage>> watchThread(String agentId, String role, {String? saleId}) {
    return remote.watchThread(agentId, role, saleId: saleId).map((list) => list
        .map((m) => ChatMessage(
              id: m.id,
              from: m.from,
              text: m.text,
              at: m.at,
              kind: m.kind,
              url: m.url,
              path: m.path,
              name: m.name,
              mime: m.mime,
              size: m.size,
            ))
        .toList());
  }
  @override
  Future<void> send(String agentId, String role, String text, {String? saleId}) {
    final at = DateTime.now().millisecondsSinceEpoch;
    return remote.send(agentId, role, saleId: saleId, text: text, at: at, from: 'agent');
  }
  @override
  Future<void> sendAttachment(String agentId, String role,
      {String? saleId,
      required String kind,
      String? url,
      String? path,
      String? name,
      String? mime,
      int? size,
      String? text}) {
    final at = DateTime.now().millisecondsSinceEpoch;
    return remote.sendAttachment(agentId, role, saleId: saleId, at: at, from: 'agent', kind: kind, url: url, path: path, name: name, mime: mime, size: size, text: text);
  }
  @override
  Future<void> markRead(String role, int latestNotMine, {String? saleId}) {
    if (role == 'moderator') {
      return local.setLastSeenModerator(latestNotMine);
    }
    return local.setLastSeenAdmin(saleId ?? '', latestNotMine);
  }
  @override
  int? getLastSeen(String role, {String? saleId}) {
    if (role == 'moderator') {
      return local.getLastSeenModerator();
    }
    return local.getLastSeenAdmin(saleId ?? '');
  }
}