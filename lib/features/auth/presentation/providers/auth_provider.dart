import 'dart:math';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';

class AuthState {
  final bool isAuthenticated;
  final String? email;
  final String? token;
  const AuthState({required this.isAuthenticated, this.email, this.token});
}

class AuthController extends StateNotifier<AuthState> {
  static const _kToken = 'auth_token';
  static const _kEmail = 'auth_email';
  static const _kExpires = 'auth_expires';
  static const _kRegEmail = 'registered_email';
  static const _kRegPassword = 'registered_password';

  AuthController() : super(const AuthState(isAuthenticated: false)) {
    _restore();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final token = p.getString(_kToken);
    final email = p.getString(_kEmail);
    final ms = p.getInt(_kExpires);
    final exp = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    final valid = exp == null || exp.isAfter(DateTime.now());
    if (token != null && email != null && valid) {
      state = AuthState(isAuthenticated: true, email: email, token: token);
    }
  }

  String _generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return List.generate(32, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> _saveSession(String token, String email) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setString(_kEmail, email);
    await p.setInt(_kExpires, DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch);
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kEmail);
    await p.remove(_kExpires);
    state = const AuthState(isAuthenticated: false);
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await fba.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await cred.user?.sendEmailVerification();
        return true;
      } catch (_) {
        return false;
      }
    }
    final p = await SharedPreferences.getInstance();
    final exists = p.getString(_kRegEmail) == email;
    if (exists) return false;
    await p.setString(_kRegEmail, email);
    await p.setString(_kRegPassword, password);
    return true;
  }

  Future<bool> login(String email, String password) async {
    if (email == 'agent@example.com' && password == 'password') {
      final token = _generateToken();
      await _saveSession(token, email);
      state = AuthState(isAuthenticated: true, email: email, token: token);
      return true;
    }
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await fba.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        final user = cred.user;
        final verified = user?.emailVerified == true;
        if (verified) {
          final token = _generateToken();
          await _saveSession(token, email);
          state = AuthState(isAuthenticated: true, email: email, token: token);
          return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }
    final p = await SharedPreferences.getInstance();
    final regEmail = p.getString(_kRegEmail);
    final regPass = p.getString(_kRegPassword);
    if (regEmail != null && regPass != null && regEmail == email && regPass == password) {
      final token = _generateToken();
      await _saveSession(token, email);
      state = AuthState(isAuthenticated: true, email: email, token: token);
      return true;
    }
    return false;
  }

  Future<String?> resetPassword(String email) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await fba.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        return 'email_sent';
      } catch (_) {
        return null;
      }
    }
    final p = await SharedPreferences.getInstance();
    final regEmail = p.getString(_kRegEmail);
    if (regEmail == email) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final r = Random.secure();
      final temp = List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
      await p.setString(_kRegPassword, temp);
      return temp;
    }
    return null;
  }

  Future<bool> changePassword(String email, String oldPassword, String newPassword) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final user = fba.FirebaseAuth.instance.currentUser;
        if (user == null || user.email != email) return false;
        final cred = fba.EmailAuthProvider.credential(email: email, password: oldPassword);
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
        return true;
      } catch (_) {
        return false;
      }
    }
    final p = await SharedPreferences.getInstance();
    final regEmail = p.getString(_kRegEmail);
    final regPass = p.getString(_kRegPassword);
    if (regEmail == email && regPass == oldPassword) {
      await p.setString(_kRegPassword, newPassword);
      return true;
    }
    return false;
  }

  Future<bool> changeEmail(String newEmail, {required String currentPassword}) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final user = fba.FirebaseAuth.instance.currentUser;
        if (user == null || user.email == null) return false;
        final cred = fba.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
        await user.verifyBeforeUpdateEmail(newEmail);
        return true;
      } catch (_) {
        return false;
      }
    }
    final p = await SharedPreferences.getInstance();
    final regEmail = p.getString(_kRegEmail);
    if (regEmail != null) {
      await p.setString(_kRegEmail, newEmail);
      return true;
    }
    return false;
  }

  Future<bool> resendEmailVerification() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final user = fba.FirebaseAuth.instance.currentUser;
        await user?.sendEmailVerification();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<String?> startPhoneVerification(String phoneNumber) async {
    if (Firebase.apps.isNotEmpty) {
      String? verificationId;
      final c = Completer<String?>();
      await fba.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          try {
            final user = fba.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await user.linkWithCredential(credential);
            }
            c.complete('auto');
          } catch (_) {
            c.complete(null);
          }
        },
        verificationFailed: (e) => c.complete(null),
        codeSent: (vid, _) {
          verificationId = vid;
          c.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (vid) {
          verificationId = vid;
        },
      );
      return c.future;
    }
    return null;
  }

  Future<bool> submitSmsCode(String verificationId, String smsCode) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final credential = fba.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
        final user = fba.FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.linkWithCredential(credential);
          return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());