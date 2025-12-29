import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/learning/presentation/providers/learning_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:solo1/features/main_app/learning/presentation/widgets/liquid_progress_bar.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solo1/features/main_app/chat/data/datasource/chat_remote_datasource.dart';
import 'package:firebase_database/firebase_database.dart';

class DocsModal extends ConsumerStatefulWidget {
  const DocsModal({super.key});
  @override
  ConsumerState<DocsModal> createState() => _DocsModalState();
}

class _DocsModalState extends ConsumerState<DocsModal> {
  final ImagePicker _picker = ImagePicker();
  bool consent = false;
  String? choosing;
  CameraController? _cam;
  bool _camReady = false;
  double _light = 0;
  double _glare = 0;
  bool _cameraVisible = false;
  String? _cameraFor; // 'front' | 'back' | 'selfie'
  List<CameraDescription> _cams = [];
  int _camIndex = 0;
  bool _isFront = false;
  bool _lastWarnLow = false;
  bool _lastWarnGlare = false;
  bool _uploading = false;
  double _uploadProgress = 0;
  @override
  Widget build(BuildContext context) {
    final files = ref.watch(docsFilesProvider);
    final frontOk = files['front'] != null;
    final backOk = files['back'] != null;
    final selfieOk = files['selfie'] != null;
    return Stack(children: [
      Align(
        alignment: Alignment.center,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.verified_user, color: Colors.white), const SizedBox(width: 8), const Expanded(child: Text('Верификация документов', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))), IconButton(onPressed: () => ref.read(sendDocsOverlayVisibleProvider.notifier).state = false, icon: const Icon(Icons.close, color: Colors.white54))]),
            const SizedBox(height: 6),
            const Text('Загрузите удостоверение личности (обе стороны) и селфи с документом', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            _UploadTile(
                label: 'Лицевая сторона ID',
                done: frontOk,
                onTap: () => setState(() => choosing = 'front'),
                onArrowTap: () => setState(() => choosing = 'front'),
                onReplace: () => setState(() => choosing = 'front'),
                onDelete: () {
                  final m = Map<String, String?>.from(ref.read(docsFilesProvider));
                  m['front'] = null;
                  ref.read(docsFilesProvider.notifier).state = m;
                },
                previewPath: files['front']),
            if (choosing == 'front') _inlineChoicePanel(),
            const SizedBox(height: 10),
            _UploadTile(
                label: 'Обратная сторона ID',
                done: backOk,
                onTap: () => setState(() => choosing = 'back'),
                onArrowTap: () => setState(() => choosing = 'back'),
                onReplace: () => setState(() => choosing = 'back'),
                onDelete: () {
                  final m = Map<String, String?>.from(ref.read(docsFilesProvider));
                  m['back'] = null;
                  ref.read(docsFilesProvider.notifier).state = m;
                },
                previewPath: files['back']),
            if (choosing == 'back') _inlineChoicePanel(),
            const SizedBox(height: 10),
            _UploadTile(
                label: 'Селфи с документом',
                done: selfieOk,
                onTap: () => setState(() => choosing = 'selfie'),
                onArrowTap: () => setState(() => choosing = 'selfie'),
                onReplace: () => setState(() => choosing = 'selfie'),
                onDelete: () {
                  final m = Map<String, String?>.from(ref.read(docsFilesProvider));
                  m['selfie'] = null;
                  ref.read(docsFilesProvider.notifier).state = m;
                },
                previewPath: files['selfie']),
            if (choosing == 'selfie') _inlineChoicePanel(),
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: consent, onChanged: (v) => setState(() => consent = v ?? false)),
              const SizedBox(width: 6),
              const Expanded(child: Text('Я даю согласие на обработку моих персональных данных', style: TextStyle(color: Colors.white70)))
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (frontOk && backOk && selfieOk && consent)
                    ? () async {
                        await _simulateUpload();
                        ref.read(sendDocsOverlayVisibleProvider.notifier).state = false;
                        ref.read(docsSubmittedProvider.notifier).state = true;
                      }
                    : null,
                child: const Text('Отправить на проверку'),
              ),
            ),
          ]),
        ),
      ),
      if (_cameraVisible) _cameraOverlay(),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _uploading
            ? Align(
                alignment: Alignment.center,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.96, end: 1),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  builder: (context, s, child) => Transform.scale(scale: s, child: child!),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 320,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(children: const [
                          Icon(Icons.cloud_upload, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(child: Text('Отправка документов...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                        ]),
                        const SizedBox(height: 12),
                        LiquidProgressBar(value: _uploadProgress),
                      ]),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }
  Widget _inlineChoicePanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(onPressed: _openCustomCamera, icon: const Icon(Icons.camera_alt, color: Colors.white)),
          const SizedBox(width: 8),
          IconButton(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library, color: Colors.white)),
          const SizedBox(width: 8),
          IconButton(onPressed: _pickFile, icon: const Icon(Icons.attach_file, color: Colors.white)),
        ]),
      ),
    );
  }
  Future<void> _openCustomCamera() async {
    try {
      _cameraFor = choosing;
      _cams = await availableCameras();
      if (_cams.isEmpty) {
        ref.read(toastProvider.notifier).state = 'Камера недоступна';
        return;
      }
      CameraDescription target;
      if (_cameraFor == 'selfie') {
        target = _cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cams.first);
      } else {
        target = _cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cams.first);
      }
      _camIndex = _cams.indexOf(target);
      await _initCamera(target);
      setState(() => _cameraVisible = true);
    } catch (e) {
      ref.read(toastProvider.notifier).state = 'Не удалось открыть камеру';
    }
  }
  Future<void> _initCamera(CameraDescription desc) async {
    try {
      _cam?.dispose();
      CameraController? ok;
      for (final p in [ResolutionPreset.max, ResolutionPreset.veryHigh, ResolutionPreset.high]) {
        try {
          final c = CameraController(desc, p, enableAudio: false);
          await c.initialize();
          ok = c;
          break;
        } catch (_) {}
      }
      ok ??= CameraController(desc, ResolutionPreset.medium, enableAudio: false);
      if (!ok.value.isInitialized) await ok.initialize();
      _cam = ok;
      _camReady = true;
      _isFront = desc.lensDirection == CameraLensDirection.front;
      _light = 0;
      _glare = 0;
      await _cam!.startImageStream((image) {
        try {
          final plane = image.planes[0].bytes;
          int sum = 0;
          int bright = 0;
          final step = 1000;
          for (int i = 0; i < plane.length; i += step) {
            final v = plane[i];
            sum += v;
            if (v > 230) bright++;
          }
          final samples = (plane.length / step).floor().clamp(1, 100000);
          _light = sum / samples.toDouble();
          _glare = bright / samples.toDouble();
          final nl = _light < 40;
          final ng = _glare > 0.15;
          if ((nl && !_lastWarnLow) || (ng && !_lastWarnGlare)) {
            HapticFeedback.lightImpact();
          }
          if (!nl && !ng) {
            if (ref.read(toastProvider) != null && ref.read(toastProvider)!.isNotEmpty) {
              ref.read(toastProvider.notifier).state = null;
            }
          } else {
            final msg = nl && ng
                ? 'Слабое освещение и блик'
                : (nl
                    ? 'Слабое освещение'
                    : 'Блик на документе');
            if (ref.read(toastProvider) != msg) {
              ref.read(toastProvider.notifier).state = msg;
            }
          }
          _lastWarnLow = nl;
          _lastWarnGlare = ng;
          setState(() {});
        } catch (_) {}
      });
    } catch (_) {
      ref.read(toastProvider.notifier).state = 'Ошибка инициализации камеры';
    }
  }
  Future<void> _switchCamera() async {
    if (_cams.isEmpty || _cam == null) return;
    try {
      await _cam!.stopImageStream();
      CameraDescription? next;
      if (_isFront) {
        next = _cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cams[(_camIndex + 1) % _cams.length]);
      } else {
        next = _cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cams[(_camIndex + 1) % _cams.length]);
      }
      _camIndex = _cams.indexOf(next);
      await _initCamera(next);
      setState(() {});
    } catch (_) {
      ref.read(toastProvider.notifier).state = 'Не удалось переключить камеру';
    }
  }
  Future<void> _captureWithCustomCamera() async {
    if (_cam == null || !_camReady) return;
    try {
      await _cam!.stopImageStream();
      final x = await _cam!.takePicture();
      setState(() {
        _camReady = false;
        _cameraVisible = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _cam?.dispose();
        } catch (_) {}
        if (mounted) {
          setState(() => _cam = null);
        } else {
          _cam = null;
        }
      });
      final processed = await _analyzeAndCrop(x);
      _setPicked(processed ?? x);
      HapticFeedback.mediumImpact();
      ref.read(toastProvider.notifier).state = null;
    } catch (e) {
      ref.read(toastProvider.notifier).state = 'Не удалось сделать снимок';
    }
  }
  Future<XFile?> _analyzeAndCrop(XFile x) async {
    try {
      final bytes = await x.readAsBytes();
      final src = img.decodeImage(bytes);
      if (src == null) return null;
      final w = src.width;
      final h = src.height;
      final targetRatio = _cameraFor == 'selfie' ? 1.0 : 260 / 170;
      final imageRatio = w / h;
      double cropW, cropH;
      if (imageRatio > targetRatio) {
        cropH = h * 0.8;
        cropW = cropH * targetRatio;
      } else {
        cropW = w * 0.8;
        cropH = cropW / targetRatio;
      }
      final cx = ((w - cropW) / 2).round();
      final cy = ((h - cropH) / 2).round();
      final cropped = img.copyCrop(src, x: cx, y: cy, width: cropW.round(), height: cropH.round());
      final coverage = (cropW * cropH) / (w * h);
      if (coverage < 0.45) {
        ref.read(toastProvider.notifier).state = 'Подвиньте ближе к рамке';
      } else if (coverage > 0.9) {
        ref.read(toastProvider.notifier).state = 'Подвиньте чуть дальше от рамки';
      }
      final out = img.encodeJpg(cropped, quality: 92);
      final tmp = File('${Directory.systemTemp.path}/doc_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmp.writeAsBytes(out);
      return XFile(tmp.path);
    } catch (_) {
      return null;
    }
  }
  Widget _cameraOverlay() {
    final warnLow = _light < 40;
    final warnGlare = _glare > 0.15;
    final baseHint = _cameraFor == 'selfie' ? 'Держите документ рядом с лицом, чтобы фото на документе было видно' : 'Фото и данные документа должны быть видны целиком';
    final warn = warnLow && warnGlare
        ? 'Слабое освещение и блик'
        : (warnLow
            ? 'Слабое освещение'
            : (warnGlare ? 'Блик на документе' : ''));
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final w = sw * 0.92;
    final h = sh * 0.65;
    final r = 260 / 170;
    final frameW = w * 0.78;
    final frameH = frameW / r;
    return Align(
      alignment: Alignment.center,
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: w,
          height: h,
          child: Column(children: [
            Expanded(
              child: Stack(children: [
                if (_cam != null && _camReady && _cam!.value.isInitialized)
                  Transform(
                    alignment: Alignment.center,
                    transform: _isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                    child: CameraPreview(_cam!),
                  ),
                if (_cameraFor != 'selfie')
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: frameW,
                        height: frameH,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 2),
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                  ),
                if (_cameraFor == 'selfie') Positioned(top: 8, right: 8, child: IconButton(onPressed: _switchCamera, icon: const Icon(Icons.cameraswitch, color: Colors.white70))),
                if (warn.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(child: Text(warn, style: const TextStyle(color: Colors.white))),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: BorderRadius.circular(12),
              child: Row(children: [
                const Icon(Icons.info_outline, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(child: Text(warn.isEmpty ? baseHint : '$baseHint • $warn', style: const TextStyle(color: Colors.white70))),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () async {
                setState(() {
                  _cameraVisible = false;
                  _camReady = false;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    await _cam?.stopImageStream();
                    await _cam?.dispose();
                  } catch (_) {}
                  if (mounted) {
                    setState(() => _cam = null);
                  } else {
                    _cam = null;
                  }
                });
                ref.read(toastProvider.notifier).state = null;
              }, child: const Text('Отмена'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: _captureWithCustomCamera, child: const Text('Сделать фото'))),
            ])
          ]),
        ),
      ),
    );
  }
  Future<void> _simulateUpload() async {
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() => _uploadProgress = (i + 1) / 20);
    }
    HapticFeedback.mediumImpact();
    setState(() => _uploading = false);
    await _notifyModerator();
  }
  Future<void> _pickFromGallery() async {
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery);
      if (x != null) {
        _setPicked(x);
      } else {
        ref.read(toastProvider.notifier).state = 'Галерея отменена';
      }
    } catch (e) {
      ref.read(toastProvider.notifier).state = 'Не удалось открыть галерею';
    }
  }
  Future<void> _pickFile() async {
    try {
      final f = await openFile();
      if (f != null) {
        _setPicked(f);
      } else {
        ref.read(toastProvider.notifier).state = 'Файл не выбран';
      }
    } catch (e) {
      ref.read(toastProvider.notifier).state = 'Не удалось открыть файлы';
    }
  }
  void _setPicked(XFile x) {
    final m = Map<String, String?>.from(ref.read(docsFilesProvider));
    if (choosing == 'front') m['front'] = x.path;
    if (choosing == 'back') m['back'] = x.path;
    if (choosing == 'selfie') m['selfie'] = x.path;
    ref.read(docsFilesProvider.notifier).state = m;
    setState(() => choosing = null);
  }

  Future<void> _notifyModerator() async {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final agent = container.read(authControllerProvider).agent;
      if (agent == null) return;
      final files = Map<String, String?>.from(ref.read(docsFilesProvider));
      final now = DateTime.now().millisecondsSinceEpoch;
      final chat = ChatRemoteDataSource();
      int offset = 0;
      Future<void> sendLabel(String label) => chat.send(
            agent.agentId,
            'moderator',
            text: label,
            at: now + (offset++),
            from: 'agent',
          );
      await sendLabel('Документы отправлены на проверку');
      if (files['front'] != null) {
        final p = files['front']!;
        await chat.sendAttachment(
          agent.agentId,
          'moderator',
          at: now + (offset++),
          from: 'agent',
          kind: 'image',
          path: p,
          name: p.split('/').isNotEmpty ? p.split('/').last : 'front.jpg',
          text: 'Лицевая сторона ID',
        );
      }
      if (files['back'] != null) {
        final p = files['back']!;
        await chat.sendAttachment(
          agent.agentId,
          'moderator',
          at: now + (offset++),
          from: 'agent',
          kind: 'image',
          path: p,
          name: p.split('/').isNotEmpty ? p.split('/').last : 'back.jpg',
          text: 'Обратная сторона ID',
        );
      }
      if (files['selfie'] != null) {
        final p = files['selfie']!;
        await chat.sendAttachment(
          agent.agentId,
          'moderator',
          at: now + (offset++),
          from: 'agent',
          kind: 'image',
          path: p,
          name: p.split('/').isNotEmpty ? p.split('/').last : 'selfie.jpg',
          text: 'Селфи с документом',
        );
      }
      final db = FirebaseDatabase.instance;
      await db.ref('/moderation/requests').push().set({
        'agentId': agent.agentId,
        'title': 'Документы от ${agent.fullName}',
        'createdAt': now,
        'status': 'pending',
      });
    } catch (_) {}
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback? onArrowTap;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;
  final String? previewPath;
  const _UploadTile({required this.label, required this.done, required this.onTap, this.onArrowTap, this.onReplace, this.onDelete, this.previewPath});
  @override
  Widget build(BuildContext context) {
    final sizeText = previewPath != null && previewPath!.isNotEmpty ? _sizeString(previewPath!) : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x338B3EFF)),
          color: const Color(0xFF1A1A2E),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Stack(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? const Color(0xFF27AE60) : const Color(0xFF2C2C3D),
                    boxShadow: done ? [const BoxShadow(color: Color(0x5527AE60), blurRadius: 10, spreadRadius: 1)] : const [],
                  ),
                ),
                Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0, end: done ? 1 : 0),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.8 + 0.2 * t,
                        child: CustomPaint(size: const Size(18, 18), painter: _CheckPainter(progress: t)),
                      ),
                    ),
                  ),
                )
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            if (previewPath != null && previewPath!.isNotEmpty && _isImage(previewPath!)) ...[
              const SizedBox(width: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(previewPath!), width: 40, height: 28, fit: BoxFit.cover)),
            ],
            if (!done) ...[
              IconButton(onPressed: onArrowTap ?? onTap, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70)),
              const SizedBox(width: 4),
              const Icon(Icons.upload, color: Colors.white70),
            ] else ...[
              IconButton(onPressed: onReplace, icon: const Icon(Icons.edit, color: Colors.white70)),
              const SizedBox(width: 4),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.redAccent)),
            ],
          ]),
          if (previewPath != null && previewPath!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text(_previewLabel(label), style: const TextStyle(color: Colors.white70, fontSize: 12))),
              if (sizeText != null) Text(sizeText, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ])
          ]
        ]),
      ),
    );
  }
  bool _isImage(String p) {
    final s = p.toLowerCase();
    return s.endsWith('.jpg') || s.endsWith('.jpeg') || s.endsWith('.png') || s.endsWith('.heic') || s.endsWith('.heif') || s.endsWith('.webp') || s.endsWith('.bmp') || s.endsWith('.tiff');
  }
  String _previewLabel(String l) {
    if (l.contains('Лицевая')) return 'ID лиц.';
    if (l.contains('Обратная')) return 'ID обр.';
    if (l.contains('Селфи')) return 'Селфи';
    return l;
  }
  String _sizeString(String p) {
    try {
      final bytes = File(p).lengthSync();
      if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
      return '${(bytes / 1024).toStringAsFixed(0)} КБ';
    } catch (_) {
      return '';
    }
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    final start = Offset(size.width * 0.2, size.height * 0.55);
    final mid = Offset(size.width * 0.42, size.height * 0.76);
    final end = Offset(size.width * 0.82, size.height * 0.28);
    path.moveTo(start.dx, start.dy);
    path.lineTo(mid.dx, mid.dy);
    path.lineTo(end.dx, end.dy);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final extract1 = metrics[0].extractPath(0, metrics[0].length * progress);
    canvas.drawPath(extract1, p);
  }
  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.progress != progress;
}