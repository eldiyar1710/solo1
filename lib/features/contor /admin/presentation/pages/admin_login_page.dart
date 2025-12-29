import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
const _adminEmail = 'admin@solo1.app';
const _adminPassword = '87654321';
const _moderatorEmail = 'moderator@solo1.app';
const _moderatorPassword = '12345678';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});
  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final st = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.admin_panel_settings, color: Colors.white), SizedBox(width: 8), Text('Вход администратора', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: st.loading
                        ? null
                        : () async {
                            final inputEmail = _emailController.text.trim().toLowerCase();
                            final inputPassword = _passwordController.text;
                            if (inputEmail == _moderatorEmail && inputPassword == _moderatorPassword) {
                              final ok = await ref.read(authControllerProvider.notifier).login(email: inputEmail, password: inputPassword);
                              if (ok && context.mounted) {
                                context.go(AppRoutes.moderatorHome);
                              }
                              return;
                            }
                            if (inputEmail == _adminEmail && inputPassword == _adminPassword) {
                              final ok = await ref.read(authControllerProvider.notifier).login(email: inputEmail, password: inputPassword);
                              if (ok && context.mounted) {
                                context.go(AppRoutes.adminHome);
                              }
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверные учетные данные')));
                          },
                    child: Text(l10n.login_button),
                  ),
                ),
                if (st.loading) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
                if (st.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(st.error!, style: const TextStyle(color: Colors.redAccent))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}