import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/chat/presentation/providers/chat_provider.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/liquid_progress_bar.dart';

class ChatThread extends ConsumerStatefulWidget {
  final String agentId;
  final String role;
  final String? saleId;
  final bool asOverlay;
  const ChatThread({super.key, required this.agentId, required this.role, this.saleId, this.asOverlay = false});
  @override
  ConsumerState<ChatThread> createState() => _ChatThreadState();
}

class _ChatThreadState extends ConsumerState<ChatThread> {
  final TextEditingController _ctrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _attachMenuVisible = false;
  final List<({String path, String? name, String? mime, bool isImage, int? size})> _drafts = [];
  final ScrollController _listCtrl = ScrollController();
  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatThreadProvider((agentId: widget.agentId, role: widget.role, saleId: widget.saleId)).notifier).watch();
    });
  }
  @override
  void dispose() {
    _ctrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }
  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _drafts.isEmpty) return;
    await ref.read(chatThreadProvider((agentId: widget.agentId, role: widget.role, saleId: widget.saleId)).notifier)
        .sendBundle(_drafts, text.isEmpty ? null : text);
    setState(() {
      _drafts.clear();
    });
    _ctrl.clear();
    _scrollToBottom();
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() {
        _attachMenuVisible = false;
      });
      FocusScope.of(context).unfocus();
      final x = await _picker.pickImage(source: ImageSource.camera);
      if (x != null) {
        _drafts.add((path: x.path, name: x.name, mime: 'image/jpeg', isImage: true, size: null));
        _scrollToBottom();
      }
    } catch (_) {}
  }
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _attachMenuVisible = false;
      });
      FocusScope.of(context).unfocus();
      final xs = await _picker.pickMultiImage();
      if (xs.isNotEmpty) {
        for (final x in xs) {
          _drafts.add((path: x.path, name: x.name, mime: 'image/jpeg', isImage: true, size: null));
        }
        _scrollToBottom();
      }
    } catch (_) {}
  }
  Future<void> _pickFile() async {
    try {
      setState(() {
        _attachMenuVisible = false;
      });
      FocusScope.of(context).unfocus();
      final fs = await openFiles();
      if (fs.isNotEmpty) {
        for (final f in fs) {
          final size = await File(f.path).length();
          _drafts.add((path: f.path, name: f.name, mime: null, isImage: _isImage(f.path), size: size));
        }
        _scrollToBottom();
      }
    } catch (_) {}
  }
  bool _isImage(String p) {
    final s = p.toLowerCase();
    return s.endsWith('.jpg') || s.endsWith('.jpeg') || s.endsWith('.png') || s.endsWith('.heic') || s.endsWith('.heif') || s.endsWith('.webp') || s.endsWith('.bmp') || s.endsWith('.tiff');
  }
  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(chatThreadProvider((agentId: widget.agentId, role: widget.role, saleId: widget.saleId)));
    const double inputH = 54;
    const double attachH = 88;
    const double previewH = 76;
    const double uploadH = 52;
    final double bottomPad = 12 +
        inputH +
        (_attachMenuVisible ? attachH : 0) +
        (_drafts.isNotEmpty ? previewH : 0) +
        (thread.uploading ? uploadH : 0);
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        titleSpacing: 0,
        title: Row(children: [
          const SizedBox(width: 8),
          const CircleAvatar(backgroundColor: Color(0xFF3A3A3A), child: Icon(Icons.person, color: Colors.white70)),
          const SizedBox(width: 8),
          Text(widget.role == 'moderator' ? 'Модератор' : (widget.saleId != null ? 'Админ • Продажа ${widget.saleId}' : 'Админ'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
        actions: const [],
        flexibleSpace: GlassContainer(
          blur: 12,
          opacity: 0.18,
          color: const Color(0xFF1A1442),
          withBorder: false,
          child: const SizedBox.expand(),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_attachMenuVisible) {
            setState(() => _attachMenuVisible = false);
          }
        },
        child: Stack(children: [
        Positioned.fill(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),
            controller: _listCtrl,
            reverse: true,
            physics: const ClampingScrollPhysics(),
            itemCount: thread.messages.length,
            itemBuilder: (ctx, i) {
              final m = thread.messages[thread.messages.length - 1 - i];
              final isMine = m.from == 'agent';
              final at = m.at;
              final time = at != 0 ? DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(at)) : '';
              Widget content;
              if (m.kind == 'image') {
                final String? p = m.path;
                if (p != null && p.isNotEmpty && File(p).existsSync()) {
                  final String localPath = p;
                  content = ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(localPath), width: 220, height: 160, fit: BoxFit.cover));
                } else if (m.url != null && m.url!.isNotEmpty) {
                  content = ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(m.url!, width: 220, height: 160, fit: BoxFit.cover));
                } else {
                  content = Container(
                    width: 220,
                    height: 160,
                    decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                    child: Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.photo, color: Colors.white54),
                        const SizedBox(width: 6),
                        Flexible(child: Text(m.text.isNotEmpty ? m.text : 'Фото', style: const TextStyle(color: Colors.white70))),
                      ]),
                    ),
                  );
                }
              } else if (m.kind == 'file') {
                final name = m.name ?? 'Файл';
                content = InkWell(
                  onTap: () async {
                    final p = m.path;
                    if (p != null && p.isNotEmpty) {
                      final uri = Uri.file(p);
                      await launchUrl(uri);
                    }
                  },
                  child: Row(children: [
                    const Icon(Icons.insert_drive_file, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name, style: const TextStyle(color: Colors.white))),
                  ]),
                );
              } else {
                content = Text(m.text, style: const TextStyle(color: Colors.white));
              }
              return Align(
                alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<int>(at),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: child!)),
                        child: GlassContainer(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          opacity: 0.15,
                          withBorder: true,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        content,
                        const SizedBox(height: 4),
                        Row(children: [
                          const Spacer(),
                          Text(time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ]),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (thread.uploading)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: GlassContainer(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                opacity: 0.15,
                withBorder: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  const Icon(Icons.cloud_upload, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: LiquidProgressBar(value: thread.uploadProgress)),
                ]),
              ),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _drafts.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: GlassContainer(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      opacity: 0.15,
                      withBorder: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          for (int i = 0; i < _drafts.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _drafts[i].isImage
                                      ? Image.file(File(_drafts[i].path), width: 80, height: 60, fit: BoxFit.cover)
                                      : Container(
                                          width: 80,
                                          height: 60,
                                          color: const Color(0x332A184B),
                                          child: Center(
                                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                                              const Icon(Icons.insert_drive_file, color: Colors.white70, size: 18),
                                              const SizedBox(width: 4),
                                              Flexible(child: Text(_drafts[i].name ?? 'Файл', style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                            ]),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _drafts.removeAt(i);
                                      });
                                      _scrollToBottom();
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(color: Color(0xAA000000), shape: BoxShape.circle),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                        ]),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _attachMenuVisible = !_attachMenuVisible;
                    });
                    _scrollToBottom();
                  },
                  icon: const Icon(Icons.add, color: Colors.white70)),
              Expanded(
                child: GlassContainer(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  opacity: 0.15,
                  withBorder: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Сообщение',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: (_ctrl.text.trim().isEmpty && _drafts.isEmpty) ? null : _send,
                child: AnimatedScale(
                  scale: (_ctrl.text.trim().isEmpty && _drafts.isEmpty) ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (_ctrl.text.trim().isEmpty && _drafts.isEmpty) ? const Color(0xFF3A3A3A) : const Color(0xFF6A1B9A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _attachMenuVisible
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                    child: GlassContainer(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      opacity: 0.15,
                      withBorder: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(children: [
                        Expanded(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: _pickFromCamera, icon: const Icon(Icons.camera_alt, color: Colors.white70)),
                            const SizedBox(height: 2),
                            const Text('Камера', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                        ),
                        Expanded(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library, color: Colors.white70)),
                            const SizedBox(height: 2),
                            const Text('Галерея', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                        ),
                        Expanded(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: _pickFile, icon: const Icon(Icons.attach_file, color: Colors.white70)),
                            const SizedBox(height: 2),
                            const Text('Файл', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                        ),
                      ]),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ]))),
      ]),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listCtrl.hasClients) return;
      _listCtrl.jumpTo(0);
    });
  }
}