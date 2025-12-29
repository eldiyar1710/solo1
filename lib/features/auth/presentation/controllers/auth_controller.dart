import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/usecases/register_agent_use_case.dart';
import 'package:solo1/features/auth/domain/usecases/login_agent_use_case.dart';
import 'package:solo1/features/auth/domain/usecases/get_current_agent_use_case.dart';
import 'package:solo1/features/auth/domain/usecases/sync_agent_data_use_case.dart';
import 'package:solo1/features/auth/data/repositories/agent_repository_impl.dart';

class AuthUiState {
  final AgentEntity? agent;
  final bool loading;
  final String? error;
  final String? errorCode;
  const AuthUiState({this.agent, this.loading = false, this.error, this.errorCode});
  AuthUiState copyWith({AgentEntity? agent, bool? loading, String? error, String? errorCode}) =>
      AuthUiState(agent: agent ?? this.agent, loading: loading ?? this.loading, error: error, errorCode: errorCode ?? this.errorCode);
}

final agentRepositoryProvider = Provider((ref) => AgentRepositoryImpl());

class AuthController extends StateNotifier<AuthUiState> {
  final RegisterAgentUseCase registerUseCase;
  final LoginAgentUseCase loginUseCase;
  final GetCurrentAgentUseCase currentUseCase;
  final SyncAgentDataUseCase syncUseCase;
  AuthController({required this.registerUseCase, required this.loginUseCase, required this.currentUseCase, required this.syncUseCase}) : super(const AuthUiState());

  String _readableError(Object e) {
    if (e is fba.FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Этот email уже зарегистрирован. Войдите в аккаунт.';
        case 'invalid-email':
          return 'Некорректный email.';
        case 'weak-password':
          return 'Слишком слабый пароль. Минимум 6 символов.';
        case 'network-request-failed':
          return 'Нет сети. Проверьте подключение к интернету.';
        case 'too-many-requests':
          return 'Слишком много попыток. Попробуйте позже.';
        case 'operation-not-allowed':
          return 'Регистрация по email отключена.';
        case 'user-not-found':
          return 'Аккаунт не найден.';
        case 'wrong-password':
          return 'Неверный пароль.';
        default:
          return e.message ?? 'Ошибка авторизации.';
      }
    }
    return e.toString();
  }

  Future<bool> register({required String fullName, required String phone, required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final agent = await registerUseCase(fullName: fullName, phone: phone, email: email, password: password);
      state = const AuthUiState(agent: null, loading: false, error: null, errorCode: null);
      state = AuthUiState(agent: agent, loading: false, error: null, errorCode: null);
      return true;
    } catch (e) {
      final code = e is fba.FirebaseAuthException ? e.code : null;
      state = AuthUiState(agent: null, loading: false, error: _readableError(e), errorCode: code);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final agent = await loginUseCase(email: email, password: password);
      state = AuthUiState(agent: agent, loading: false, error: null, errorCode: null);
      return true;
    } catch (e) {
      final code = e is fba.FirebaseAuthException ? e.code : null;
      state = AuthUiState(agent: null, loading: false, error: _readableError(e), errorCode: code);
      return false;
    }
  }

  Future<void> loadCurrent() async {
    final agent = await currentUseCase();
    state = state.copyWith(agent: agent, error: null, errorCode: null);
  }

  Future<void> sync() async {
    try {
      await syncUseCase();
      final agent = await currentUseCase();
      state = state.copyWith(agent: agent, error: null, errorCode: null);
    } catch (_) {}
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(loading: true, error: null, errorCode: null);
    try {
      await fba.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = state.copyWith(loading: false, error: null, errorCode: null);
      return true;
    } catch (e) {
      final code = e is fba.FirebaseAuthException ? e.code : null;
      state = state.copyWith(loading: false, error: _readableError(e), errorCode: code);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true, error: null, agent: null);
    try {
      try {
        await fba.FirebaseAuth.instance.signOut();
      } catch (_) {}
      try {
        final box = Hive.box('userBox');
        await box.delete('agent');
      } catch (_) {}
    } finally {
      state = const AuthUiState(agent: null, loading: false, error: null, errorCode: null);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthUiState>((ref) {
  final repo = ref.read(agentRepositoryProvider);
  return AuthController(
    registerUseCase: RegisterAgentUseCase(repo),
    loginUseCase: LoginAgentUseCase(repo),
    currentUseCase: GetCurrentAgentUseCase(repo),
    syncUseCase: SyncAgentDataUseCase(repo),
  );
});