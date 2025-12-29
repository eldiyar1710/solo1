import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/home/domain/entities/agent_rank_entity.dart';
import 'package:solo1/features/main_app/home/domain/usecases/get_leaderboard_use_case.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_provider.dart';

class HomeLeaderboardState {
  final List<AgentRankEntity> ranks;
  final bool loading;
  final String period;
  final String? error;
  const HomeLeaderboardState({this.ranks = const [], this.loading = false, this.period = 'week', this.error});
  HomeLeaderboardState copyWith({List<AgentRankEntity>? ranks, bool? loading, String? period, String? error}) =>
      HomeLeaderboardState(ranks: ranks ?? this.ranks, loading: loading ?? this.loading, period: period ?? this.period, error: error);
}

class HomeLeaderboardController extends StateNotifier<HomeLeaderboardState> {
  final GetLeaderboardUseCase getLeaderboard;
  HomeLeaderboardController(this.getLeaderboard) : super(const HomeLeaderboardState());
  Future<void> load([String? period]) async {
    final p = period ?? state.period;
    state = state.copyWith(loading: true, error: null, period: p);
    try {
      final data = await getLeaderboard(p);
      state = state.copyWith(ranks: data, loading: false, error: null);
    } catch (_) {
      state = state.copyWith(ranks: const [], loading: false, error: 'Ошибка загрузки');
    }
  }
}

final homeLeaderboardProvider = StateNotifierProvider<HomeLeaderboardController, HomeLeaderboardState>((ref) {
  final repo = ref.read(homeRepositoryProvider);
  return HomeLeaderboardController(GetLeaderboardUseCase(repo));
});