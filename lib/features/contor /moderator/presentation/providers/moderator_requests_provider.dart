import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/contor%20/moderator/data/repository/moderator_repository_impl.dart';
import 'package:solo1/features/contor%20/moderator/domain/entities/moderator_request_entity.dart';
import 'package:solo1/features/contor%20/moderator/domain/usecases/get_incoming_requests.dart';
import 'package:solo1/features/contor%20/moderator/domain/usecases/approve_request.dart';
import 'package:solo1/features/contor%20/moderator/domain/usecases/reject_request.dart';

class ModeratorRequestsState {
  final List<ModeratorRequestEntity> items;
  final bool loading;
  final String? error;
  const ModeratorRequestsState({this.items = const [], this.loading = false, this.error});
  ModeratorRequestsState copyWith({List<ModeratorRequestEntity>? items, bool? loading, String? error}) =>
      ModeratorRequestsState(items: items ?? this.items, loading: loading ?? this.loading, error: error);
}

class ModeratorRequestsController extends StateNotifier<ModeratorRequestsState> {
  final GetIncomingModeratorRequestsUseCase incoming;
  final ApproveModeratorRequestUseCase approve;
  final RejectModeratorRequestUseCase reject;
  ModeratorRequestsController(this.incoming, this.approve, this.reject) : super(const ModeratorRequestsState());
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await incoming();
      state = ModeratorRequestsState(items: data, loading: false, error: null);
    } catch (_) {
      state = ModeratorRequestsState(items: const [], loading: false, error: 'Ошибка загрузки');
    }
  }
  Future<void> approveItem(String id) async {
    await approve(id);
    await load();
  }
  Future<void> rejectItem(String id) async {
    await reject(id);
    await load();
  }
}

final moderatorRepositoryProvider = Provider((ref) => ModeratorRepositoryImpl());
final moderatorRequestsProvider = StateNotifierProvider<ModeratorRequestsController, ModeratorRequestsState>((ref) {
  final repo = ref.read(moderatorRepositoryProvider);
  return ModeratorRequestsController(
    GetIncomingModeratorRequestsUseCase(repo),
    ApproveModeratorRequestUseCase(repo),
    RejectModeratorRequestUseCase(repo),
  );
});