import '../entities/profile.dart';
import '../repository/profile_repository.dart';

class LoadProfile {
  final ProfileRepository repo;
  LoadProfile(this.repo);
  Future<Profile> call() => repo.getProfile();
}