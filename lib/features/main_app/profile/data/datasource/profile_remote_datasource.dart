import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:solo1/core/data/remote/firebase_remote_datasource.dart';
import 'package:solo1/features/main_app/profile/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseRemoteDataSource remote;
  ProfileRemoteDataSource({FirebaseRemoteDataSource? remote}) : remote = remote ?? FirebaseRemoteDataSource();
  Future<ProfileModel?> fetchCurrent() async {
    final uid = fba.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final raw = await remote.fetchAgent(uid);
    if (raw == null) return null;
    final name = (raw['fullName'] ?? raw['firstName'] ?? '').toString();
    final agentId = (raw['agentId'] ?? '').toString();
    return ProfileModel(name: name.isEmpty ? 'Агент' : name, agentId: agentId);
  }
}