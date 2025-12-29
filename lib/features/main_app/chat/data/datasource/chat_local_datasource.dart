import 'package:hive/hive.dart';

class ChatLocalDataSource {
  int? getLastSeenModerator() {
    final box = Hive.box('users');
    return box.get('chat_last_seen_moderator') as int?;
  }
  int? getLastSeenAdmin(String saleId) {
    final box = Hive.box('users');
    return box.get('chat_last_seen_admin_$saleId') as int?;
  }
  Future<void> setLastSeenModerator(int ts) async {
    final box = Hive.box('users');
    await box.put('chat_last_seen_moderator', ts);
  }
  Future<void> setLastSeenAdmin(String saleId, int ts) async {
    final box = Hive.box('users');
    await box.put('chat_last_seen_admin_$saleId', ts);
  }
}