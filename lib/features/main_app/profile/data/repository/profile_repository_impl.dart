import '../../data/datasource/profile_local_datasource.dart';
import '../../data/datasource/profile_remote_datasource.dart';
import '../../data/models/profile_model.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl({required this.local, ProfileRemoteDataSource? remote}) : remote = remote ?? ProfileRemoteDataSource();
  @override
  Future<Profile> getProfile() async {
    var m = await local.load();
    final r = await remote.fetchCurrent();
    if (r != null) {
      await local.save(r);
      m = r;
    }
    return Profile(name: m.name, agentId: m.agentId);
  }
  @override
  Future<void> setProfile(Profile p) {
    return local.save(ProfileModel(name: p.name, agentId: p.agentId));
  }
}