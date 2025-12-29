import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/sales/presentation/providers/sales_provider.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/chat_thread.dart';

class AdminSalesChatList extends ConsumerStatefulWidget {
  final String agentId;
  final bool asOverlay;
  const AdminSalesChatList({super.key, required this.agentId, this.asOverlay = false});
  @override
  ConsumerState<AdminSalesChatList> createState() => _AdminSalesChatListState();
}

class _AdminSalesChatListState extends ConsumerState<AdminSalesChatList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesProvider.notifier).load();
    });
  }
  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.asOverlay ? IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()) : null,
        title: const Text('Чаты по продажам', style: TextStyle(color: Colors.white)),
        flexibleSpace: GlassContainer(
          blur: 12,
          opacity: 0.15,
          withBorder: true,
          child: const SizedBox.expand(),
        ),
      ),
      body: salesState.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: salesState.items.length,
              itemBuilder: (context, i) {
                final s = salesState.items[i];
                return GlassContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  opacity: 0.15,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  withBorder: true,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.point_of_sale, color: Colors.white70),
                    title: Text('Продажа ${s.saleId}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Лицензий: ${s.quantity}', style: const TextStyle(color: Colors.white54)),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        builder: (ctx) {
                          final size = MediaQuery.of(ctx).size;
                          return Center(
                            child: GlassContainer(
                              borderRadius: const BorderRadius.all(Radius.circular(24)),
                              blur: 12,
                              opacity: 0.15,
                              withBorder: true,
                              child: SizedBox(
                                width: size.width * 0.92,
                                height: size.height * 0.82,
                                child: ChatThread(agentId: widget.agentId, role: 'admin', saleId: s.saleId, asOverlay: true),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}