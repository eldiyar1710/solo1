import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidProgressBar extends StatefulWidget {
  final double value;
  const LiquidProgressBar({super.key, required this.value});
  @override
  State<LiquidProgressBar> createState() => _LiquidProgressBarState();
}

class _LiquidProgressBarState extends State<LiquidProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final v = widget.value.clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _LiquidBarPainter(progress: v, t: _c.value),
        child: const SizedBox(height: 16),
      ),
    );
  }
}

class _LiquidBarPainter extends CustomPainter {
  final double progress;
  final double t;
  _LiquidBarPainter({required this.progress, required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final h = 16.0;
    final bg = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, h), const Radius.circular(999));
    final base = Paint()..color = const Color(0x1FFFFFFF);
    canvas.drawRRect(bg, base);
    final border = Paint()
      ..color = const Color(0x338B3EFF)
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(bg, border);
    final w = size.width * progress;
    if (w <= 0) return;
    final clip = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(999));
    canvas.save();
    canvas.clipRRect(clip);
    final fill = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF8B3EFF), Color(0xFF42A5F5)], begin: Alignment.centerLeft, end: Alignment.centerRight)
          .createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(bg, fill);
    final wave1 = Path();
    final wave2 = Path();
    final amp1 = 2.2;
    final amp2 = 1.4;
    final freq1 = 2 * math.pi;
    final freq2 = 3 * math.pi;
    final phase = t * 2 * math.pi;
    for (double x = 0; x <= w; x += 2) {
      final y1 = h / 2 + amp1 * math.sin((x / w) * freq1 + phase);
      final y2 = h / 2 + amp2 * math.sin((x / w) * freq2 - phase * 0.8);
      if (x == 0) {
        wave1.moveTo(x, y1);
        wave2.moveTo(x, y2);
      } else {
        wave1.lineTo(x, y1);
        wave2.lineTo(x, y2);
      }
    }
    wave1.lineTo(w, h);
    wave1.lineTo(0, h);
    wave1.close();
    wave2.lineTo(w, h);
    wave2.lineTo(0, h);
    wave2.close();
    final p1 = Paint()..color = const Color(0x55FFFFFF);
    final p2 = Paint()..color = const Color(0x33FFFFFF);
    canvas.drawPath(wave1, p1);
    canvas.drawPath(wave2, p2);
    final bubbles = Paint()..color = const Color(0x99FFFFFF);
    for (int i = 0; i < 6; i++) {
      final bx = (w - 8) * ((i + 1) / 7);
      final by = h - (t * h + i * 2) % h;
      canvas.drawCircle(Offset(bx, by), 1.2, bubbles);
    }
    canvas.restore();
    final gloss = Paint()
      ..shader = const LinearGradient(colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)], begin: Alignment.topCenter, end: Alignment.center)
          .createShader(Rect.fromLTWH(0, 0, size.width, h));
    canvas.drawRRect(bg, gloss);
  }
  @override
  bool shouldRepaint(covariant _LiquidBarPainter old) => old.progress != progress || old.t != t;
}