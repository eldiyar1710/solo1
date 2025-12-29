import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/profile_local_datasource.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/load_profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepositoryImpl(local: ProfileLocalDataSource()));

class ProfileState {
  final Profile profile;
  final bool loading;
  const ProfileState({this.profile = const Profile(name: 'Агент'), this.loading = false});
  ProfileState copyWith({Profile? profile, bool? loading}) => ProfileState(profile: profile ?? this.profile, loading: loading ?? this.loading);
}

class ProfileController extends StateNotifier<ProfileState> {
  final LoadProfile loadProfile;
  ProfileController(this.loadProfile) : super(const ProfileState());
  Future<void> load() async {
    state = state.copyWith(loading: true);
    final p = await loadProfile();
    state = ProfileState(profile: p, loading: false);
  }
}

final profileProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return ProfileController(LoadProfile(repo));
});