import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/chat/data/datasource/chat_remote_datasource.dart';
import 'package:solo1/features/main_app/chat/data/datasource/chat_local_datasource.dart';

class ChatPreviewState {
  final String preview;
  final String time;
  final int unreadCount;
  final bool loading;
  final String? kind;
  const ChatPreviewState({this.preview = '', this.time = '', this.unreadCount = 0, this.loading = false, this.kind});
  ChatPreviewState copyWith({String? preview, String? time, int? unreadCount, bool? loading, String? kind}) =>
      ChatPreviewState(preview: preview ?? this.preview, time: time ?? this.time, unreadCount: unreadCount ?? this.unreadCount, loading: loading ?? this.loading, kind: kind ?? this.kind);
}

class ChatPreviewController extends StateNotifier<ChatPreviewState> {
  final ChatRemoteDataSource remote;
  final ChatLocalDataSource local;
  final String agentId;
  final String role;
  StreamSubscription? _sub;
  ChatPreviewController({required this.remote, required this.local, required this.agentId, required this.role}) : super(const ChatPreviewState());
  void watch() {
    state = state.copyWith(loading: true);
    _sub?.cancel();
    if (role == 'moderator') {
      _sub = remote.watchThread(agentId, role).listen((list) {
        final latest = list.isNotEmpty ? list.last : null;
        final lastSeen = local.getLastSeenModerator() ?? 0;
        final unread = list.where((m) => m.from != 'agent' && m.at > lastSeen).length;
        final t = latest == null ? '' : _formatTime(latest.at);
        final p = latest?.text ?? '';
        final k = latest?.kind;
        state = ChatPreviewState(preview: p, time: t, unreadCount: unread, loading: false, kind: k);
      }, onError: (_) {
        state = const ChatPreviewState();
      });
      return;
    }
    _sub = remote.watchAdminRoot(agentId).listen((map) {
      String preview = '';
      String time = '';
      int latestAt = 0;
      int unread = 0;
      String? kind;
      map.forEach((saleId, msgs) {
        final lastSeen = local.getLastSeenAdmin(saleId) ?? 0;
        unread += msgs.where((m) => m.from != 'agent' && m.at > lastSeen).length;
        if (msgs.isNotEmpty) {
          final last = msgs.last;
          if (last.at > latestAt) {
            latestAt = last.at;
            preview = last.text;
            time = _formatTime(last.at);
            kind = last.kind;
          }
        }
      });
      state = ChatPreviewState(preview: preview, time: time, unreadCount: unread, loading: false, kind: kind);
    }, onError: (_) {
      state = const ChatPreviewState();
    });
  }
  String _formatTime(int at) {
    final dt = DateTime.fromMillisecondsSinceEpoch(at);
    final now = DateTime.now();
    final sameDay = DateTime(now.year, now.month, now.day) == DateTime(dt.year, dt.month, dt.day);
    return sameDay ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}' : 'Вчера';
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatPreviewProvider = StateNotifierProvider.family<ChatPreviewController, ChatPreviewState, ({String agentId, String role})>((ref, params) {
  return ChatPreviewController(remote: ChatRemoteDataSource(), local: ChatLocalDataSource(), agentId: params.agentId, role: params.role);
});