import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_notification_entity.dart';
import 'package:solo1/features/main_app/home/domain/usecases/get_notifications_use_case.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_provider.dart';

class HomeNotificationsState {
  final List<HomeNotificationEntity> notifications;
  final bool loading;
  final String? error;
  const HomeNotificationsState({this.notifications = const [], this.loading = false, this.error});
  HomeNotificationsState copyWith({List<HomeNotificationEntity>? notifications, bool? loading, String? error}) =>
      HomeNotificationsState(notifications: notifications ?? this.notifications, loading: loading ?? this.loading, error: error);
}

class HomeNotificationsController extends StateNotifier<HomeNotificationsState> {
  final GetNotificationsUseCase getNotifications;
  final Ref ref;
  StreamSubscription? _sub;
  HomeNotificationsController(this.getNotifications, this.ref) : super(const HomeNotificationsState());
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await getNotifications();
      state = HomeNotificationsState(notifications: data, loading: false, error: null);
    } catch (_) {
      state = HomeNotificationsState(notifications: const [], loading: false, error: 'Ошибка загрузки');
    }
  }
  void watch() {
    final repo = ref.read(homeRepositoryProvider);
    _sub?.cancel();
    _sub = repo.watchNotifications().listen((items) {
      state = HomeNotificationsState(notifications: items, loading: false, error: null);
    }, onError: (_) {
      state = HomeNotificationsState(notifications: const [], loading: false, error: 'Ошибка загрузки');
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotificationsController, HomeNotificationsState>((ref) {
  final repo = ref.read(homeRepositoryProvider);
  return HomeNotificationsController(GetNotificationsUseCase(repo), ref);
});