import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/contor%20/admin/data/repository/admin_repository_impl.dart';
import 'package:solo1/features/contor%20/admin/domain/entities/moderation_request_entity.dart';
import 'package:solo1/features/contor%20/admin/domain/usecases/get_incoming_requests.dart';
import 'package:solo1/features/contor%20/admin/domain/usecases/approve_request.dart';
import 'package:solo1/features/contor%20/admin/domain/usecases/reject_request.dart';

class AdminRequestsState {
  final List<ModerationRequestEntity> items;
  final bool loading;
  final String? error;
  const AdminRequestsState({this.items = const [], this.loading = false, this.error});
  AdminRequestsState copyWith({List<ModerationRequestEntity>? items, bool? loading, String? error}) =>
      AdminRequestsState(items: items ?? this.items, loading: loading ?? this.loading, error: error);
}

class AdminRequestsController extends StateNotifier<AdminRequestsState> {
  final GetIncomingRequestsUseCase incoming;
  final ApproveRequestUseCase approve;
  final RejectRequestUseCase reject;
  AdminRequestsController(this.incoming, this.approve, this.reject) : super(const AdminRequestsState());
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await incoming();
      state = AdminRequestsState(items: data, loading: false, error: null);
    } catch (_) {
      state = AdminRequestsState(items: const [], loading: false, error: 'Ошибка загрузки');
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

final adminRepositoryProvider = Provider((ref) => AdminRepositoryImpl());
final adminRequestsProvider = StateNotifierProvider<AdminRequestsController, AdminRequestsState>((ref) {
  final repo = ref.read(adminRepositoryProvider);
  return AdminRequestsController(GetIncomingRequestsUseCase(repo), ApproveRequestUseCase(repo), RejectRequestUseCase(repo));
});