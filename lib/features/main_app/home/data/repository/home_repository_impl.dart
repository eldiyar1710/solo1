import 'package:solo1/features/main_app/home/domain/entities/home_banner.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_notification_entity.dart';
import 'package:solo1/features/main_app/home/domain/entities/agent_rank_entity.dart';
import 'package:solo1/features/main_app/home/domain/repository/home_repository.dart';
import 'package:solo1/features/main_app/home/data/datasource/home_local_datasource.dart';
import 'package:solo1/features/main_app/home/data/datasource/home_notifications_local_datasource.dart';
import 'package:solo1/features/main_app/home/data/datasource/home_leaderboard_local_datasource.dart';
import 'package:solo1/features/main_app/home/data/datasource/home_remote_datasource.dart';
import 'package:solo1/features/main_app/home/data/models/home_banner_model.dart';
import 'package:solo1/features/main_app/home/data/models/home_notification_model.dart';
import 'package:solo1/features/main_app/home/data/models/agent_rank_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource local;
  final HomeNotificationsLocalDataSource notificationsLocal;
  final HomeLeaderboardLocalDataSource leaderboardLocal;
  final HomeRemoteDataSource remote;
  HomeRepositoryImpl({required this.local, HomeRemoteDataSource? remote, HomeNotificationsLocalDataSource? notificationsLocal, HomeLeaderboardLocalDataSource? leaderboardLocal})
      : remote = remote ?? HomeRemoteDataSource(),
        notificationsLocal = notificationsLocal ?? HomeNotificationsLocalDataSource(),
        leaderboardLocal = leaderboardLocal ?? HomeLeaderboardLocalDataSource();
  @override
  Future<List<HomeBanner>> getBanners() async {
    try {
      final remoteData = await remote.fetch();
      if (remoteData.isNotEmpty) {
        await local.save(remoteData);
      }
      final data = remoteData.isNotEmpty ? remoteData : await local.load();
      final items = data
          .map((e) => HomeBanner(id: e.id, title: e.title, imageUrl: e.imageUrl, active: e.active, priority: e.priority, linkUrl: e.linkUrl, type: e.type, description: e.description))
          .toList();
      items.sort((a, b) => b.priority.compareTo(a.priority));
      return items;
    } catch (_) {
      final data = await local.load();
      final items = data
          .map((e) => HomeBanner(id: e.id, title: e.title, imageUrl: e.imageUrl, active: e.active, priority: e.priority, linkUrl: e.linkUrl, type: e.type, description: e.description))
          .toList();
      items.sort((a, b) => b.priority.compareTo(a.priority));
      return items;
    }
  }
  @override
  Future<void> saveBanners(List<HomeBanner> banners) {
    final models = banners
        .map((e) => HomeBannerModel(id: e.id, title: e.title, imageUrl: e.imageUrl, active: e.active, priority: e.priority, linkUrl: e.linkUrl, type: e.type, description: e.description))
        .toList();
    return local.save(models);
  }
  @override
  Future<String> addBanner({required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) async {
    final id = await remote.addBanner(title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl ?? '', type: type ?? 'banner', description: description ?? '');
    final current = await getBanners();
    final updated = [
      ...current,
      HomeBanner(id: id, title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl ?? '', type: type ?? 'banner', description: description ?? ''),
    ];
    await saveBanners(updated);
    return id;
  }
  @override
  Future<void> updateBanner(String id, {required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) async {
    await remote.updateBanner(id, title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl ?? '', type: type ?? 'banner', description: description ?? '');
    final current = await getBanners();
    final updated = current
        .map((e) => e.id == id
            ? HomeBanner(id: id, title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl ?? '', type: type ?? 'banner', description: description ?? '')
            : e)
        .toList();
    await saveBanners(updated);
  }
  @override
  Future<void> deleteBanner(String id) async {
    await remote.deleteBanner(id);
    final current = await getBanners();
    final updated = current.where((e) => e.id != id).toList();
    await saveBanners(updated);
  }

  @override
  Future<List<HomeNotificationEntity>> getNotifications() async {
    List<HomeNotificationModel> data = const [];
    try {
      data = await remote.getNotifications();
      if (data.isNotEmpty) {
        await notificationsLocal.save(data);
      } else {
        data = await notificationsLocal.load();
      }
    } catch (_) {
      data = await notificationsLocal.load();
    }
    return data
        .map((e) => HomeNotificationEntity(id: e.id, title: e.title, message: e.message, date: DateTime.fromMillisecondsSinceEpoch(e.date)))
        .toList();
  }

  @override
  Future<void> addNotification({required String title, required String message, required DateTime date}) async {
    await remote.addNotification(title, message, date.millisecondsSinceEpoch);
  }

  @override
  Future<void> updateNotification({required String id, required String title, required String message, required DateTime date}) async {
    await remote.updateNotification(id, title, message, date.millisecondsSinceEpoch);
  }

  @override
  Future<void> deleteNotification({required String id}) async {
    await remote.deleteNotification(id);
  }

  @override
  Future<List<AgentRankEntity>> getLeaderboard(String period) async {
    List<AgentRankModel> data = const [];
    try {
      data = await remote.fetchLeaderboard(period);
      if (data.isNotEmpty) {
        await leaderboardLocal.save(period, data);
      } else {
        data = await leaderboardLocal.load(period);
      }
    } catch (_) {
      data = await leaderboardLocal.load(period);
    }
    return data.map((e) => AgentRankEntity(id: e.id, name: e.name, sales: e.sales, bonusPercent: e.bonusPercent, rank: e.rank)).toList();
  }


  @override
  Stream<List<HomeNotificationEntity>> watchNotifications() {
    return remote
        .notificationsStream()
        .map((list) => list.map((e) => HomeNotificationEntity(id: e.id, title: e.title, message: e.message, date: DateTime.fromMillisecondsSinceEpoch(e.date))).toList());
  }
}