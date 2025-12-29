import 'package:firebase_database/firebase_database.dart';
import '../models/moderator_request_model.dart';

class ModeratorRemoteDataSource {
  final FirebaseDatabase db;
  ModeratorRemoteDataSource({FirebaseDatabase? database}) : db = database ?? FirebaseDatabase.instance;
  Future<List<ModeratorRequestModel>> fetchIncoming() async {
    final snap = await db.ref('/moderation/requests').get();
    if (!snap.exists) return [];
    final raw = Map<String, dynamic>.from(snap.value as Map);
    return raw.entries
        .map((e) => ModeratorRequestModel.fromJson({'id': e.key, ...Map<String, dynamic>.from(e.value)}))
        .toList();
  }
  Future<void> setStatus(String id, String status, {String? comment}) async {
    await db.ref('/moderation/requests/$id/status').set(status);
    if (comment != null) {
      await db.ref('/moderation/requests/$id/comment').set(comment);
    }
  }
}