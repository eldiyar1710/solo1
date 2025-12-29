import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
const _adminEmail = 'admin@solo1.app';
const _moderatorEmail = 'moderator@solo1.app';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'agent@example.com');
  final _passwordController = TextEditingController(text: 'password');
  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final ok = await container.read(authControllerProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ok ? null : container.read(authControllerProvider).error ?? 'Неверные данные для входа';
    });
    if (ok) {
      await container.read(authControllerProvider.notifier).sync();
      final a = container.read(authControllerProvider).agent;
      final role = a?.role;
      final email = (a?.email ?? _emailController.text.trim()).toLowerCase();
      if (mounted) {
        if (email == _moderatorEmail || role == 'moderator') {
          context.go(AppRoutes.moderatorHome);
        } else if (email == _adminEmail || role == 'admin') {
          context.go(AppRoutes.adminHome);
        } else {
          context.go(AppRoutes.mainHome);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go(AppRoutes.preHome),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF141227), Color(0xFF2A184B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  onTap: () => FocusScope.of(context).unfocus(),
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        const SizedBox(height: 12),
                        const CircleAvatar(radius: 28, backgroundColor: Color(0xFF6A1B9A), child: Icon(Icons.login, color: Colors.white)),
                        const SizedBox(height: 16),
                        Text(l10n.login_title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(l10n.login_subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 20),
                        _field(label: l10n.login_email_label, controller: _emailController, keyboardType: TextInputType.emailAddress),
                        _field(label: l10n.login_password_label, controller: _passwordController, isPassword: true),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(l10n.login_button),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                        ],
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _loading ? null : _resetPassword,
                          child: const Text('Забыли пароль?', style: TextStyle(color: Color(0xFF9C27B0))),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: Text(l10n.login_register_link, style: const TextStyle(color: Color(0xFF9C27B0))),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _field({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? !_showPassword : false,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF000000).withValues(alpha: 0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                )
              : null,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return ' ';
          if (keyboardType == TextInputType.emailAddress) {
            return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim()) ? null : 'Введите корректный email';
          }
          if (isPassword) {
            return v.length >= 6 ? null : 'Пароль должен быть не менее 6 символов';
          }
          return null;
        },
      ),
    );
  }
  void _resetPassword() async {
    final email = _emailController.text.trim();
    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!valid) {
      setState(() => _error = 'Введите корректный email');
      return;
    }
    setState(() => _loading = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final ok = await container.read(authControllerProvider.notifier).resetPassword(email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Письмо отправлено'),
          content: const Text('Проверьте почту и следуйте инструкции для сброса пароля.'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ок'))],
        ),
      );
    } else {
      setState(() => _error = container.read(authControllerProvider).error ?? 'Не удалось отправить письмо');
    }
  }
}