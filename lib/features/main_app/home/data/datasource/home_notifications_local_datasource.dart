import 'package:hive/hive.dart';
import '../models/home_notification_model.dart';

class HomeNotificationsLocalDataSource {
  static const _box = 'notifications';
  List<HomeNotificationModel> _cache = const [];
  Future<List<HomeNotificationModel>> load() async {
    final box = Hive.box(_box);
    final raw = (box.get('items') as List?) ?? [];
    _cache = raw.map((e) => HomeNotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    if (_cache.isEmpty) {
      _cache = [
        HomeNotificationModel(
          id: 'n1',
          title: 'Важное уведомление',
          message: 'Система будет обновлена 15 декабря. Пожалуйста, завершите все активные сделки.',
          date: DateTime.now().millisecondsSinceEpoch,
        ),
        HomeNotificationModel(
          id: 'n2',
          title: 'Пригласи друзей',
          message: 'За каждого приглашенного агента +0.5% к комиссии',
          date: DateTime.now().millisecondsSinceEpoch - 86400000,
        ),
      ];
    }
    return _cache;
  }
  Future<void> save(List<HomeNotificationModel> notifications) async {
    _cache = notifications;
    final box = Hive.box(_box);
    await box.put('items', notifications.map((e) => e.toJson()).toList());
  }
}