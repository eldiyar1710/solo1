import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/chat_list_tile.dart';

class ChatCenterPage extends ConsumerStatefulWidget {
  final bool asOverlay;
  const ChatCenterPage({super.key, this.asOverlay = false});
  @override
  ConsumerState<ChatCenterPage> createState() => _ChatCenterPageState();
}

class _ChatCenterPageState extends ConsumerState<ChatCenterPage> {
  @override
  Widget build(BuildContext context) {
    final agentId = ref.watch(authControllerProvider).agent?.agentId ?? 'AG-XXXXXX';
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => widget.asOverlay ? Navigator.of(context).pop() : context.go(AppRoutes.mainHome),
        ),
        title: null,
        flexibleSpace: GlassContainer(
          blur: 12,
          opacity: 0.15,
          withBorder: true,
          child: const SizedBox.expand(),
        ),
      ),
      body: ListView(children: [
        ChatListTile(title: 'Модератор', role: 'moderator', agentId: agentId),
        ChatListTile(title: 'Админ', role: 'admin', agentId: agentId),
      ]),
    );
  }
}