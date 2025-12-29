import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/core/utils/agent_id_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:solo1/core/utils/formatters.dart';
import 'package:solo1/core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _agreedToTerms = false;
  String? _generatedAgentId;

  void _showTopToast(String message) {
    final entry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                borderRadius: BorderRadius.circular(18),
                opacity: 0.18,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(message, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }


  void _register() async {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState!.validate() && _agreedToTerms && _passwordController.text == _confirmPasswordController.text) {
      setState(() => _isLoading = true);

      final container = ProviderScope.containerOf(context, listen: false);
      final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      final ok = await container.read(authControllerProvider.notifier).register(
        fullName: _nameController.text.trim(),
        phone: phoneDigits,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _generatedAgentId = AgentIdGenerator.generateUniqueId(7);

      if (!mounted) return;
      setState(() => _isLoading = false);
      if (ok) {
        final container = ProviderScope.containerOf(context, listen: false);
        await container.read(authControllerProvider.notifier).sync();
        _showSuccessDialog();
      } else {
        final container = ProviderScope.containerOf(context, listen: false);
        final st = container.read(authControllerProvider);
        if (st.errorCode == 'email-already-in-use') {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Email уже зарегистрирован'),
                content: const Text('Войдите в аккаунт с этим email или укажите другой.'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
                  TextButton(onPressed: () { Navigator.of(ctx).pop(); context.go(AppRoutes.login); }, child: const Text('Войти')),
                ],
              );
            },
          );
        } else {
          _showTopToast(st.error ?? 'Ошибка регистрации');
        }
      }
    } else if (!_agreedToTerms) {
      _showTopToast(l10n.register_agree_warning);
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showTopToast(l10n.register_password_mismatch);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.register_success_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.register_success_message),
              const SizedBox(height: 10),
              SelectableText('${l10n.register_your_id}: $_generatedAgentId',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
              const SizedBox(height: 10),
              Text(l10n.register_id_use_info),
            ],
          ),
          actions: [
              TextButton(
                child: Text(l10n.register_success_button_go_main),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.go(AppRoutes.mainHome);
                },
              ),
            ],
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.register_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go(AppRoutes.preHome),
        ),
        actions: [
          TextButton(onPressed: () => context.go(AppRoutes.login), child: Text(l10n.register_login_button, style: const TextStyle(color: Colors.white)))
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                margin: const EdgeInsets.only(top: 50, bottom: 20),
                padding: const EdgeInsets.all(25),
                borderRadius: BorderRadius.circular(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.register_welcome, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 30),
                      _buildGlassTextField(
                        controller: _nameController,
                        label: l10n.register_fio_label,
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.register_field_required : null,
                      ),
                      _buildGlassTextField(
                        controller: _phoneController,
                        label: l10n.register_phone_label,
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l10n.register_field_required;
                          final s = v.replaceAll(' ', '');
                          return RegExp(r'^\d+ ?$').hasMatch(s) || RegExp(r'^\d+$').hasMatch(s) ? null : 'Введите номер только из цифр';
                        },
                      ),
                      _buildGlassTextField(
                        controller: _emailController,
                        label: l10n.register_email_label,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l10n.register_field_required;
                          return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim()) ? null : 'Введите корректный email';
                        },
                      ),
                      _buildGlassTextField(
                        controller: _passwordController,
                        label: l10n.register_password_label,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: !_showPassword,
                        suffix: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.register_field_required;
                          return v.length >= 6 ? null : 'Пароль должен быть не менее 6 символов';
                        },
                      ),
                      _buildGlassTextField(
                        controller: _confirmPasswordController,
                        label: l10n.register_confirm_password_label,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: !_showConfirmPassword,
                        suffix: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                        validator: (v) => (v == _passwordController.text) ? null : l10n.register_password_mismatch,
                      ),
                      const SizedBox(height: 15),
                      _buildAgreementCheckbox(l10n),
                      const SizedBox(height: 25),
                      _buildRegisterButton(l10n),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(onPressed: () => context.go(AppRoutes.login), child: Text(l10n.register_login_link, style: const TextStyle(color: Colors.white70))),
                      ),
                    ],
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

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? helperText,
    String? Function(String?)? validator,
    bool? obscure,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure ?? isPassword,
        inputFormatters: keyboardType == TextInputType.phone ? [KzPhoneFormatter()] : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70.withValues(alpha: 0.8)),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffix,
          helperText: helperText,
          helperStyle: const TextStyle(color: Colors.white54, fontSize: 10),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(color: Colors.white, width: 2)),
          hintText: keyboardType == TextInputType.phone ? '+7 777 000 0000' : null,
          hintStyle: const TextStyle(color: Colors.white24),
        ),
        validator: (value) {
          if (keyboardType == TextInputType.phone) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context).register_field_required;
            }
            return Validators.isKzPhoneFormatted(value.trim()) ? null : 'Введите номер в формате +7 *** *** ** **';
          }
          if (validator != null) {
            return validator(value);
          }
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context).register_field_required;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAgreementCheckbox(AppLocalizations l10n) {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: _isLoading ? null : (bool? newValue) {
            setState(() => _agreedToTerms = newValue ?? false);
          },
          activeColor: Colors.lightGreenAccent,
          checkColor: Colors.black,
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : () {
              setState(() => _agreedToTerms = !_agreedToTerms);
            },
            child: Text(l10n.register_terms_and_conditions, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purpleAccent.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: _isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
          : Text(l10n.register_button, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
