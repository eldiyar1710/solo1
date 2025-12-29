import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:solo1/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/features/auth/presentation/pages/login_page.dart';
import 'package:solo1/features/auth/presentation/pages/register_page.dart';
import 'package:solo1/features/auth/presentation/screens/splash_screen.dart';
import 'package:solo1/features/preauth/pre_home/presentation/pages/pre_home_page.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/pages/pre_learning_page.dart';
import 'package:solo1/features/preauth/demo/presentation/pages/demo_page.dart';
import 'package:solo1/features/main_app/home/presentation/pages/main_home_page.dart';
import 'package:solo1/features/contor%20/admin/presentation/pages/admin_login_page.dart';
import 'package:solo1/features/contor%20/admin/presentation/pages/admin_home_page.dart';
import 'package:solo1/features/contor%20/moderator/presentation/pages/moderator_home_page.dart';
import 'package:solo1/core/app/lifecycle_sync_observer.dart';
import 'package:solo1/core/sync/sync_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
  await Hive.initFlutter();
  await Hive.openBox('banners');
  await Hive.openBox('notifications');
  await Hive.openBox('users');
  await Hive.openBox('sales');
  await Hive.openBox('sync_queue');
  await Hive.openBox('userBox');
  await initializeDateFormatting('ru');
  Intl.defaultLocale = 'ru';
  WidgetsBinding.instance.addObserver(LifecycleSyncObserver(SyncService()));
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
    GoRoute(path: AppRoutes.preHome, builder: (context, state) => const PreHomePage()),
    GoRoute(path: AppRoutes.preLearning, builder: (context, state) => const PreLearningPage()),
    GoRoute(path: AppRoutes.demo, builder: (context, state) => const DemoPage()),
    GoRoute(path: AppRoutes.mainHome, builder: (context, state) => const MainHomePage()),
    GoRoute(path: AppRoutes.adminLogin, builder: (context, state) => const AdminLoginPage()),
    GoRoute(path: AppRoutes.adminHome, builder: (context, state) => const AdminHomePage()),
    GoRoute(path: AppRoutes.moderatorHome, builder: (context, state) => const ModeratorHomePage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'JUIE Sales',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: _router,
      ),
    );
  }
}

Widget createAppForTest({String? initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation ?? AppRoutes.preHome,
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
      GoRoute(path: AppRoutes.preHome, builder: (context, state) => const PreHomePage()),
      GoRoute(path: AppRoutes.preLearning, builder: (context, state) => const PreLearningPage()),
      GoRoute(path: AppRoutes.demo, builder: (context, state) => const DemoPage()),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      title: 'JUIE Sales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    ),
  );
}
