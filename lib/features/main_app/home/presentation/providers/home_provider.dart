import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/home/data/datasource/home_local_datasource.dart';
import 'package:solo1/features/main_app/home/data/repository/home_repository_impl.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_banner.dart';
import 'package:solo1/features/main_app/home/domain/usecases/fetch_home_banners.dart';
import 'package:solo1/features/main_app/home/domain/repository/home_repository.dart';

final homeRepositoryProvider = Provider((ref) => HomeRepositoryImpl(local: HomeLocalDataSource()));

class HomeState {
  final List<HomeBanner> banners;
  final bool loading;
  const HomeState({this.banners = const [], this.loading = false});
  HomeState copyWith({List<HomeBanner>? banners, bool? loading}) => HomeState(banners: banners ?? this.banners, loading: loading ?? this.loading);
}

class HomeController extends StateNotifier<HomeState> {
  final FetchHomeBanners fetch;
  HomeController(this.fetch) : super(const HomeState());
  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final data = await fetch();
      state = HomeState(banners: data, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }
  Future<void> addBanner({required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) async {
    final repo = _repo;
    await repo.addBanner(title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl, type: type, description: description);
    await load();
  }
  Future<void> updateBanner(String id, {required String title, required String imageUrl, required bool active, required int priority, String? linkUrl, String? type, String? description}) async {
    final repo = _repo;
    await repo.updateBanner(id, title: title, imageUrl: imageUrl, active: active, priority: priority, linkUrl: linkUrl, type: type, description: description);
    await load();
  }
  Future<void> deleteBanner(String id) async {
    final repo = _repo;
    await repo.deleteBanner(id);
    await load();
  }
  late final HomeRepository _repo;
}

final homeProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  final repo = ref.read(homeRepositoryProvider);
  final c = HomeController(FetchHomeBanners(repo));
  c._repo = repo;
  return c;
});