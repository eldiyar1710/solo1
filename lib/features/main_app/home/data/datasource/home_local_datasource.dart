import 'package:hive/hive.dart';
import 'package:solo1/features/main_app/home/data/models/home_banner_model.dart';

class HomeLocalDataSource {
  static const _box = 'banners';
  List<HomeBannerModel> _cache = const [];
  Future<List<HomeBannerModel>> load() async {
    final box = Hive.box(_box);
    final raw = (box.get('items') as List?) ?? [];
    _cache = raw.map((e) => HomeBannerModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    if (_cache.isEmpty) {
      _cache = const [
        HomeBannerModel(id: 'b1', title: 'Топ агенты получают +1%', imageUrl: '', active: true, priority: 3, linkUrl: '', type: 'banner', description: 'Продавайте больше всех!'),
        HomeBannerModel(id: 'b2', title: 'Новая акция: кешбэк', imageUrl: '', active: true, priority: 2, linkUrl: '', type: 'banner', description: 'Узнайте подробности в новостях'),
        HomeBannerModel(id: 'b3', title: 'Добро пожаловать', imageUrl: '', active: true, priority: 1, linkUrl: '', type: 'banner', description: ''),
      ];
    }
    return _cache;
  }
  Future<void> save(List<HomeBannerModel> banners) async {
    _cache = banners;
    final box = Hive.box(_box);
    await box.put('items', banners.map((e) => e.toJson()).toList());
  }
}