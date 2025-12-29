import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo1/features/main_app/profile/data/models/profile_model.dart';

class ProfileLocalDataSource {
  static const _kProfile = 'main_profile';
  Future<ProfileModel> load() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString(_kProfile) ?? 'Агент';
    final agentId = p.getString('${_kProfile}_agentId');
    return ProfileModel(name: name, agentId: agentId);
  }
  Future<void> save(ProfileModel m) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kProfile, m.name);
    if (m.agentId != null) {
      await p.setString('${_kProfile}_agentId', m.agentId!);
    }
  }
}