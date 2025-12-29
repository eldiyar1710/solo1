import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/chat/domain/entities/chat_message.dart';
import 'package:solo1/features/main_app/chat/domain/usecases/watch_chat_thread.dart';
import 'package:solo1/features/main_app/chat/domain/usecases/send_chat_message.dart';
import 'package:solo1/features/main_app/chat/domain/usecases/mark_chat_read.dart';
import 'package:solo1/features/main_app/chat/domain/usecases/send_chat_attachment.dart';
import 'package:solo1/features/main_app/chat/data/repository/chat_repository_impl.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepositoryImpl());

class ChatThreadState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final bool uploading;
  final double uploadProgress;
  const ChatThreadState({this.messages = const [], this.loading = false, this.error, this.uploading = false, this.uploadProgress = 0});
  ChatThreadState copyWith({List<ChatMessage>? messages, bool? loading, String? error, bool? uploading, double? uploadProgress}) =>
      ChatThreadState(messages: messages ?? this.messages, loading: loading ?? this.loading, error: error, uploading: uploading ?? this.uploading, uploadProgress: uploadProgress ?? this.uploadProgress);
}

class ChatThreadController extends StateNotifier<ChatThreadState> {
  final WatchChatThread watchUseCase;
  final SendChatMessage sendUseCase;
  final SendChatAttachment sendAttachmentUseCase;
  final MarkChatRead markUseCase;
  final String agentId;
  final String role;
  final String? saleId;
  StreamSubscription? _sub;
  ChatThreadController({required this.watchUseCase, required this.sendUseCase, required this.sendAttachmentUseCase, required this.markUseCase, required this.agentId, required this.role, this.saleId}) : super(const ChatThreadState());
  void watch() {
    state = state.copyWith(loading: true, error: null);
    _sub?.cancel();
    _sub = watchUseCase(agentId, role, saleId: saleId).listen((msgs) async {
      state = ChatThreadState(messages: msgs, loading: false, error: null);
      final latestNotMine = msgs.where((m) => m.from != 'agent').map((m) => m.at).fold<int>(0, (p, e) => e > p ? e : p);
      if (latestNotMine > 0) {
        await markUseCase(role, latestNotMine, saleId: saleId);
      }
    }, onError: (_) {
      state = ChatThreadState(messages: const [], loading: false, error: 'error');
    });
  }
  Future<void> send(String text) {
    return sendUseCase(agentId, role, text, saleId: saleId);
  }
  Future<void> sendBundle(List<({String path, String? name, String? mime, bool isImage, int? size})> drafts, String? text) async {
    final total = drafts.length + ((text != null && text.trim().isNotEmpty) ? 1 : 0);
    if (total == 0) return;
    state = state.copyWith(uploading: true, uploadProgress: 0);
    int sent = 0;
    for (final d in drafts) {
      await sendAttachmentUseCase(agentId, role, saleId: saleId, kind: d.isImage ? 'image' : 'file', path: d.path, name: d.name, mime: d.mime, size: d.size, text: d.isImage ? 'Фото' : (d.name != null ? 'Файл: ${d.name}' : 'Файл'));
      sent++;
      state = state.copyWith(uploadProgress: sent / total);
    }
    if (text != null && text.trim().isNotEmpty) {
      await sendUseCase(agentId, role, text.trim(), saleId: saleId);
      sent++;
      state = state.copyWith(uploadProgress: sent / total);
    }
    state = state.copyWith(uploading: false);
  }
  Future<void> sendAttachment({required String kind, String? url, String? path, String? name, String? mime, int? size, String? text}) {
    return sendAttachmentUseCase(agentId, role, saleId: saleId, kind: kind, url: url, path: path, name: name, mime: mime, size: size, text: text);
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatThreadProvider = StateNotifierProvider.family<ChatThreadController, ChatThreadState, ({String agentId, String role, String? saleId})>((ref, params) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatThreadController(
    watchUseCase: WatchChatThread(repo),
    sendUseCase: SendChatMessage(repo),
    sendAttachmentUseCase: SendChatAttachment(repo),
    markUseCase: MarkChatRead(repo),
    agentId: params.agentId,
    role: params.role,
    saleId: params.saleId,
  );
});