import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
const _adminEmail = 'admin@solo1.app';
const _moderatorEmail = 'moderator@solo1.app';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future(() async {
      final box = Hive.box('userBox');
      final exists = box.get('agent') != null;
      if (!mounted) return;
      Future<void> goByRole() async {
        final container = ProviderScope.containerOf(context, listen: false);
        final a = container.read(authControllerProvider).agent;
        final role = a?.role;
        final email = (a?.email ?? '').toLowerCase();
        if (!mounted) return;
        if (email == _moderatorEmail || role == 'moderator') {
          context.go(AppRoutes.moderatorHome);
        } else if (email == _adminEmail || role == 'admin') {
          context.go(AppRoutes.adminHome);
        } else {
          context.go(AppRoutes.mainHome);
        }
      }
      if (exists) {
        final container = ProviderScope.containerOf(context, listen: false);
        await container.read(authControllerProvider.notifier).loadCurrent();
        await goByRole();
      } else {
        final user = fba.FirebaseAuth.instance.currentUser;
        if (user != null) {
          final container = ProviderScope.containerOf(context, listen: false);
          await container.read(authControllerProvider.notifier).sync();
          if (!mounted) return;
          await goByRole();
        } else {
          context.go(AppRoutes.preHome);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}