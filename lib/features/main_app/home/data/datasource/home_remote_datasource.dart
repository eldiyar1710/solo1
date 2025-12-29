import 'package:solo1/core/data/remote/firebase_remote_datasource.dart';
import '../models/home_banner_model.dart';
import '../models/home_notification_model.dart';
import '../models/agent_rank_model.dart';

class HomeRemoteDataSource {
  final FirebaseRemoteDataSource remote;
  HomeRemoteDataSource({FirebaseRemoteDataSource? remote}) : remote = remote ?? FirebaseRemoteDataSource();
  Future<List<HomeBannerModel>> fetch() async {
    final raw = await remote.fetchBanners();
    return raw.map((e) => HomeBannerModel.fromJson(e)).toList();
  }
  Future<String> addBanner({required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) {
    return remote.addBanner(title: title, imageUrl: imageUrl, active: active, priority: priority);
  }
  Future<void> updateBanner(String id, {required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) {
    return remote.updateBanner(id, title: title, imageUrl: imageUrl, active: active, priority: priority);
  }
  Future<void> deleteBanner(String id) {
    return remote.deleteBanner(id);
  }
  Future<List<HomeNotificationModel>> getNotifications() async {
    final raw = await remote.fetchNotifications();
    return raw.map((e) => HomeNotificationModel.fromJson(e)).toList();
  }

  Future<void> addNotification(String title, String message, int date) {
    return remote.addNotification(title: title, message: message, date: date);
  }
  Future<void> updateNotification(String id, String title, String message, int date) {
    return remote.updateNotification(id, title: title, message: message, date: date);
  }
  Future<void> deleteNotification(String id) {
    return remote.deleteNotification(id);
  }

  Future<List<AgentRankModel>> fetchLeaderboard(String period) async {
    final sales = await remote.fetchSalesAll();
    final now = DateTime.now();
    DateTime from;
    switch (period) {
      case 'week':
        from = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        from = DateTime(now.year, now.month, 1);
        break;
      case 'year':
      default:
        from = DateTime(now.year, 1, 1);
        break;
    }
    final Map<String, int> counts = {};
    final Map<String, String> names = {};
    for (final s in sales) {
      final t = (s['createdAt'] ?? now.millisecondsSinceEpoch) as int;
      final d = DateTime.fromMillisecondsSinceEpoch(t);
      if (d.isBefore(from)) continue;
      final agentId = (s['agentId'] ?? 'unknown').toString();
      counts[agentId] = (counts[agentId] ?? 0) + 1;
      final n = (s['agentName'] ?? '').toString();
      if (n.isNotEmpty) names[agentId] = n;
    }
    final items = counts.entries
        .map((e) => AgentRankModel(
              id: e.key,
              name: names[e.key] ?? 'Агент',
              sales: e.value,
              bonusPercent: e.value >= 45 ? 2.0 : e.value >= 38 ? 1.5 : e.value >= 35 ? 1.0 : e.value >= 15 ? 1.0 : 0.5,
              rank: 0,
            ))
        .toList();
    items.sort((a, b) => b.sales.compareTo(a.sales));
    for (var i = 0; i < items.length; i++) {
      items[i] = AgentRankModel(id: items[i].id, name: items[i].name, sales: items[i].sales, bonusPercent: items[i].bonusPercent, rank: i + 1);
    }
    return items;
  }

  Stream<List<HomeNotificationModel>> notificationsStream() {
    return remote.notificationsStream().map((list) => list.map((e) => HomeNotificationModel.fromJson(e)).toList());
  }
}