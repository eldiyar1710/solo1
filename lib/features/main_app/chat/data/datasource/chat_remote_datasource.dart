import 'package:firebase_database/firebase_database.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final FirebaseDatabase db;
  ChatRemoteDataSource({FirebaseDatabase? database}) : db = database ?? FirebaseDatabase.instance;
  DatabaseReference _ref(String agentId, String role, String? saleId) {
    return db.ref(saleId != null ? 'chats/$agentId/$role/$saleId' : 'chats/$agentId/$role');
  }
  Stream<List<ChatMessageModel>> watchThread(String agentId, String role, {String? saleId}) {
    return _ref(agentId, role, saleId).onValue.map((e) {
      final snap = e.snapshot;
      final list = <ChatMessageModel>[];
      for (final c in snap.children) {
        final m = Map<String, dynamic>.from(c.value as Map);
        list.add(ChatMessageModel.fromMap(c.key ?? '', m));
      }
      list.sort((a, b) => a.at.compareTo(b.at));
      return list;
    });
  }
  Future<void> send(String agentId, String role, {String? saleId, required String text, required int at, required String from}) async {
    await _ref(agentId, role, saleId).push().set({'from': from, 'text': text, 'at': at});
  }

  Stream<Map<String, List<ChatMessageModel>>> watchAdminRoot(String agentId) {
    return db.ref('chats/$agentId/admin').onValue.map((e) {
      final snap = e.snapshot;
      final result = <String, List<ChatMessageModel>>{};
      for (final sale in snap.children) {
        final saleId = sale.key ?? '';
        final list = <ChatMessageModel>[];
        if (sale.value is Map) {
          final msgsMap = Map<String, dynamic>.from(sale.value as Map);
          msgsMap.forEach((key, value) {
            final m = Map<String, dynamic>.from(value as Map);
            list.add(ChatMessageModel.fromMap(key, m));
          });
          list.sort((a, b) => a.at.compareTo(b.at));
        }
        result[saleId] = list;
      }
      return result;
    });
  }

  Future<void> sendAttachment(String agentId, String role,
      {String? saleId,
      required int at,
      required String from,
      required String kind,
      String? url,
      String? path,
      String? name,
      String? mime,
      int? size,
      String? text}) async {
    final payload = {
      'from': from,
      'at': at,
      'kind': kind,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
    };
    await _ref(agentId, role, saleId).push().set(payload);
  }
}