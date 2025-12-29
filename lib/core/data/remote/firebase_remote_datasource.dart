import 'package:firebase_database/firebase_database.dart';

class FirebaseRemoteDataSource {
  final FirebaseDatabase db;
  FirebaseRemoteDataSource({FirebaseDatabase? database}) : db = database ?? FirebaseDatabase.instance;

  List<Map<String, dynamic>> _listFromSnapshot(DataSnapshot snap) {
    if (!snap.exists) return [];
    if (snap.children.isNotEmpty) {
      return snap.children.map((c) {
        final key = c.key ?? '';
        final val = (c.value is Map) ? Map<String, dynamic>.from(c.value as Map) : <String, dynamic>{'value': c.value};
        return {'id': key, ...val};
      }).toList();
    }
    if (snap.value is Map) {
      final raw = Map<String, dynamic>.from(snap.value as Map);
      return raw.entries.map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)}).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchBanners() async {
    final snap = await db.ref('/banners').get().timeout(const Duration(seconds: 10));
    return _listFromSnapshot(snap);
  }
  Future<String> addBanner({required String title, required String imageUrl, required bool active, required int priority}) async {
    final ref = db.ref('/banners').push();
    await ref.set({'title': title, 'imageUrl': imageUrl, 'active': active, 'priority': priority}).timeout(const Duration(seconds: 10));
    return ref.key!;
  }
  Future<void> updateBanner(String id, {required String title, required String imageUrl, required bool active, required int priority}) async {
    await db.ref('/banners/$id').set({'title': title, 'imageUrl': imageUrl, 'active': active, 'priority': priority}).timeout(const Duration(seconds: 10));
  }
  Future<void> deleteBanner(String id) async {
    await db.ref('/banners/$id').remove().timeout(const Duration(seconds: 10));
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final snap = await db.ref('/notifications').get().timeout(const Duration(seconds: 10));
    return _listFromSnapshot(snap);
  }

  Future<void> addNotification({required String title, required String message, required int date}) async {
    final ref = db.ref('/notifications').push();
    await ref.set({'title': title, 'message': message, 'date': date}).timeout(const Duration(seconds: 10));
  }
  Future<void> updateNotification(String id, {required String title, required String message, required int date}) async {
    await db.ref('/notifications/$id').set({'title': title, 'message': message, 'date': date}).timeout(const Duration(seconds: 10));
  }
  Future<void> deleteNotification(String id) async {
    await db.ref('/notifications/$id').remove().timeout(const Duration(seconds: 10));
  }

  Future<void> createSale(Map<String, dynamic> sale) async {
    final saleId = sale['saleId'] as String;
    await db.ref('/sales/$saleId').set(sale);
  }

  Stream<List<Map<String, dynamic>>> bannersStream() {
    return db.ref('/banners').onValue.map((e) => _listFromSnapshot(e.snapshot));
  }

  Stream<List<Map<String, dynamic>>> notificationsStream() {
    return db.ref('/notifications').onValue.map((e) => _listFromSnapshot(e.snapshot));
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final snap = await db.ref('/users/$uid').get();
    if (!snap.exists) return null;
    final raw = Map<String, dynamic>.from(snap.value as Map);
    raw['uid'] = uid;
    return raw;
  }

  Future<Map<String, dynamic>?> fetchAgent(String uid) async {
    final snap = await db.ref('/agents/$uid').get();
    if (!snap.exists) return null;
    final raw = Map<String, dynamic>.from(snap.value as Map);
    raw['uid'] = uid;
    return raw;
  }

  Future<List<Map<String, dynamic>>> salesByAgent(String agentId) async {
    final snap = await db.ref('/sales').orderByChild('agentId').equalTo(agentId).get();
    if (!snap.exists) return [];
    final raw = Map<String, dynamic>.from(snap.value as Map);
    return raw.entries.map((e) => {'saleId': e.key, ...Map<String, dynamic>.from(e.value)}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchSalesAll() async {
    final snap = await db.ref('/sales').get();
    if (!snap.exists) return [];
    final raw = Map<String, dynamic>.from(snap.value as Map);
    return raw.entries.map((e) => {'saleId': e.key, ...Map<String, dynamic>.from(e.value)}).toList();
  }
}