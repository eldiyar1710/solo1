import 'package:firebase_auth/firebase_auth.dart' as fba;

class AuthRemoteDataSource {
  Future<String> register(String email, String password) async {
    final cred = await fba.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }
  Future<String> login(String email, String password) async {
    final cred = await fba.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }
  String? currentUid() => fba.FirebaseAuth.instance.currentUser?.uid;
}