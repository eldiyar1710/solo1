import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/chat/presentation/providers/chat_preview_provider.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/chat_overlay.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/chat_thread.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/admin_sales_chat_list.dart';

class ChatListTile extends ConsumerStatefulWidget {
  final String title;
  final String role;
  final String agentId;
  const ChatListTile({super.key, required this.title, required this.role, required this.agentId});
  @override
  ConsumerState<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends ConsumerState<ChatListTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatPreviewProvider((agentId: widget.agentId, role: widget.role)).notifier).watch();
    });
  }
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(chatPreviewProvider((agentId: widget.agentId, role: widget.role)));
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      opacity: 0.15,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      withBorder: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: const Center(child: Icon(Icons.person, color: Colors.white)),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: st.preview.isEmpty
            ? null
            : Row(children: [
                if (st.kind == 'image') ...[
                  const Icon(Icons.photo, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                ]
                else if (st.kind == 'file') ...[
                  const Icon(Icons.insert_drive_file, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(child: Text(st.preview, style: const TextStyle(color: Colors.white70)))
              ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(st.time, style: const TextStyle(color: Colors.white54)),
          if (st.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF25D366)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Text('${st.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ]),
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black54,
            pageBuilder: (ctx, _, __) => ChatOverlay(
              child: widget.role == 'admin'
                  ? AdminSalesChatList(agentId: widget.agentId, asOverlay: true)
                  : ChatThread(agentId: widget.agentId, role: widget.role, asOverlay: true),
            ),
          ));
        },
      ),
    );
  }
}