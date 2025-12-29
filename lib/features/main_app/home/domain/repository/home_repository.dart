import '../entities/home_banner.dart';
import '../entities/home_notification_entity.dart';
import '../entities/agent_rank_entity.dart';

abstract class HomeRepository {
  Future<List<HomeBanner>> getBanners();
  Future<void> saveBanners(List<HomeBanner> banners);
  Future<String> addBanner({required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description});
  Future<void> updateBanner(String id, {required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description});
  Future<void> deleteBanner(String id);
  Future<List<HomeNotificationEntity>> getNotifications();
  Stream<List<HomeNotificationEntity>> watchNotifications();
  Future<void> updateNotification({required String id, required String title, required String message, required DateTime date});
  Future<void> deleteNotification({required String id});
  Future<List<AgentRankEntity>> getLeaderboard(String period);
  Future<void> addNotification({required String title, required String message, required DateTime date});
}