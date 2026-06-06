import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppLogoWidget extends StatefulWidget {
  final double size;
  final bool animate;

  const AppLogoWidget({super.key, this.size = 120, this.animate = true});

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.animate) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(AppLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!widget.animate && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _LogoPainter(_animController.value),
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double anim;

  _LogoPainter(this.anim);

  double get _flameWave => math.sin(anim * 2 * math.pi);
  double get _flameWave2 => math.sin(anim * 2 * math.pi * 0.7 + 1.2);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final cx = size.width / 2;
    final cy = size.height / 2 + 5 * s;

    _drawBook(canvas, cx, cy, s);
    _drawLogs(canvas, cx, cy, s);
    _drawFlame(canvas, cx, cy, s);
  }

  void _drawBook(Canvas canvas, double cx, double cy, double s) {
    final bookPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    final pagePaint = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..style = PaintingStyle.fill;

    final pageEdgePaint = Paint()
      ..color = const Color(0xFFF5E6CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spinePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final bookmarkPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    final textLinePaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final bookBottom = cy + 25 * s;
    final bookTop = cy - 5 * s;
    final bookLeft = cx - 28 * s;
    final bookRight = cx + 28 * s;
    final bookSpine = cx;

    final coverH = 30 * s;
    final coverW = 58 * s;
    final coverTop = bookBottom - coverH - 2 * s;
    final coverLeft = cx - coverW / 2 - 2 * s;

    final coverRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(coverLeft, coverTop, coverW + 4 * s, coverH + 4 * s),
      const Radius.circular(4),
    );
    canvas.drawRRect(coverRect, bookPaint);

    final leftPage = Path()
      ..moveTo(bookSpine, bookTop)
      ..quadraticBezierTo(
          cx - 10 * s, bookTop + 3 * s, bookLeft + 3 * s, bookTop + 5 * s)
      ..lineTo(bookLeft, bookBottom - 2 * s)
      ..quadraticBezierTo(
          cx - 15 * s, bookBottom - 4 * s, bookSpine - 1 * s, bookBottom);
    leftPage.close();
    canvas.drawPath(leftPage, pagePaint);
    canvas.drawPath(leftPage, pageEdgePaint);

    final rightPage = Path()
      ..moveTo(bookSpine, bookTop)
      ..quadraticBezierTo(
          cx + 10 * s, bookTop + 3 * s, bookRight - 3 * s, bookTop + 5 * s)
      ..lineTo(bookRight, bookBottom - 2 * s)
      ..quadraticBezierTo(
          cx + 15 * s, bookBottom - 4 * s, bookSpine + 1 * s, bookBottom);
    rightPage.close();
    canvas.drawPath(rightPage, pagePaint);
    canvas.drawPath(rightPage, pageEdgePaint);

    canvas.drawLine(
        Offset(bookSpine, bookTop), Offset(bookSpine, bookBottom), spinePaint);

    for (int i = 0; i < 4; i++) {
      final y = bookTop + 6 * s + i * 4 * s;
      if (y < bookBottom - 4 * s) {
        canvas.drawLine(Offset(bookLeft + 5 * s, y),
            Offset(bookSpine - 3 * s - i * 3 * s, y), textLinePaint);
      }
    }

    for (int i = 0; i < 4; i++) {
      final y = bookTop + 6 * s + i * 4 * s;
      if (y < bookBottom - 4 * s) {
        canvas.drawLine(Offset(bookSpine + 3 * s + i * 3 * s, y),
            Offset(bookRight - 5 * s, y), textLinePaint);
      }
    }

    final ribbonPath = Path()
      ..moveTo(bookSpine, bookTop - 2 * s)
      ..lineTo(bookSpine + 3 * s, bookTop + 10 * s)
      ..lineTo(bookSpine, bookTop + 7 * s)
      ..lineTo(bookSpine - 3 * s, bookTop + 10 * s)
      ..close();
    canvas.drawPath(ribbonPath, bookmarkPaint);
  }

  void _drawLogs(Canvas canvas, double cx, double cy, double s) {
    final logPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rings = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final knot = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.fill;

    final logCenter = cy - 3 * s;

    canvas.save();
    canvas.translate(cx, logCenter);
    canvas.rotate(-0.35);
    _drawLog(canvas, 26 * s, 7 * s, logPaint, outline, rings, knot);
    canvas.restore();

    canvas.save();
    canvas.translate(cx, logCenter);
    canvas.rotate(0.35);
    _drawLog(canvas, 26 * s, 7 * s, logPaint, outline, rings, knot);
    canvas.restore();

    canvas.save();
    canvas.translate(cx, logCenter + 3 * s);
    canvas.rotate(0.0);
    _drawLog(canvas, 20 * s, 6 * s, logPaint, outline, rings, knot);
    canvas.restore();
  }

  void _drawLog(Canvas canvas, double w, double h, Paint fill, Paint outline,
      Paint rings, Paint knot) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, outline);

    final halfW = w / 2 - 3;
    canvas.drawLine(Offset(-halfW, -h / 4), Offset(halfW, -h / 4), rings);
    canvas.drawLine(Offset(-halfW, h / 4), Offset(halfW, h / 4), rings);

    canvas.drawCircle(Offset(0, 0), 1.5, knot);

    final endGrain = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-w / 2 + 2, 0), 2.5, endGrain);
    canvas.drawCircle(Offset(w / 2 - 2, 0), 2.5, endGrain);
  }

  void _drawFlame(Canvas canvas, double cx, double cy, double s) {
    final wave = _flameWave;
    final wave2 = _flameWave2;

    final flameTop = cy - 50 * s + wave * 1.5 * s;
    final flameBottom = cy - 7 * s;
    final baseW = 20 * s;

    // Main flame gradient
    final flameGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: const [
          Color(0xFFD84315),
          Color(0xFFFF6F00),
          Color(0xFFFFA726),
          Color(0xFFFFD54F),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, (flameTop + flameBottom) / 2),
        width: baseW * 2.5,
        height: (flameBottom - flameTop) * 1.2,
      ))
      ..style = PaintingStyle.fill;

    // Flame shadow/glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFAB40).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // === OUTER FLAME (main + side tongues) ===
    final flame = Path();
    final leftBaseX = cx - baseW * 0.7 + wave2 * 1.2 * s;
    final rightBaseX = cx + baseW * 0.7 + wave2 * 0.8 * s;

    // Start at bottom center
    flame.moveTo(cx - 2 * s, flameBottom);

    // Left side going up
    flame.cubicTo(
      leftBaseX - 3 * s, flameBottom - 5 * s,
      leftBaseX - 8 * s, flameBottom - 15 * s,
      leftBaseX - 5 * s + wave2 * 2 * s, flameBottom - 22 * s,
    );

    // Left side tongue
    flame.cubicTo(
      leftBaseX - 10 * s + wave2 * 2 * s, flameBottom - 30 * s,
      leftBaseX - 4 * s + wave * 1.5 * s, flameBottom - 38 * s,
      cx - baseW * 0.3 + wave2 * 1.5 * s, flameBottom - 35 * s,
    );

    // Curve up to main peak (right-leaning)
    flame.cubicTo(
      cx - 2 * s + wave * 2 * s, flameBottom - 40 * s,
      cx - 4 * s + wave * 2 * s, flameBottom - 47 * s,
      cx + wave * 2.5 * s, flameBottom - 55 * s + wave.abs() * 0.5 * s,
    );

    // Right side coming down
    flame.cubicTo(
      cx + 6 * s + wave * 2 * s, flameBottom - 47 * s,
      cx + 5 * s + wave2 * 1.5 * s, flameBottom - 40 * s,
      cx + baseW * 0.3 + wave2 * 1.5 * s, flameBottom - 35 * s,
    );

    // Right side tongue
    flame.cubicTo(
      rightBaseX + 5 * s + wave2 * 1.5 * s, flameBottom - 32 * s,
      rightBaseX + 8 * s + wave * 1.5 * s, flameBottom - 25 * s,
      rightBaseX + 3 * s, flameBottom - 18 * s,
    );

    // Right side going down to base
    flame.cubicTo(
      rightBaseX + 6 * s, flameBottom - 12 * s,
      rightBaseX + 2 * s, flameBottom - 5 * s,
      cx + 2 * s, flameBottom,
    );

    flame.close();
    canvas.drawPath(flame, glowPaint);
    canvas.drawPath(flame, flameGradient);

    // === INNER FLAME CORE (yellow/white) ===
    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: const [
          Color(0xFFFFCA28),
          Color(0xFFFFF176),
          Color(0xFFFFF9C4),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, (flameTop + flameBottom) / 2 + 5 * s),
        width: baseW * 0.8,
        height: (flameBottom - flameTop) * 0.6,
      ))
      ..style = PaintingStyle.fill;

    final core = Path();
    final coreTop = flameBottom - 38 * s + wave * 1.5 * s + wave.abs() * 0.5 * s;

    core.moveTo(cx - 1 * s, flameBottom - 3 * s);
    core.cubicTo(
      cx - 4 * s, flameBottom - 10 * s,
      cx - baseW * 0.2 + wave2 * s, flameBottom - 20 * s,
      cx - baseW * 0.15 + wave * 1.5 * s, flameBottom - 26 * s,
    );
    core.cubicTo(
      cx - 2 * s + wave * 2 * s, flameBottom - 32 * s,
      cx - 3 * s + wave * 2 * s, flameBottom - 36 * s,
      cx + wave * 2 * s, coreTop,
    );
    core.cubicTo(
      cx + 3 * s + wave * 2 * s, flameBottom - 36 * s,
      cx + 2 * s + wave2 * 1.5 * s, flameBottom - 32 * s,
      cx + baseW * 0.15 + wave2 * s, flameBottom - 26 * s,
    );
    core.cubicTo(
      cx + baseW * 0.2 + wave2 * s, flameBottom - 20 * s,
      cx + 4 * s, flameBottom - 10 * s,
      cx + 1 * s, flameBottom - 3 * s,
    );
    core.close();
    canvas.drawPath(core, corePaint);

    // === FACE on the flame ===
    final faceCenterY = flameBottom - 17 * s;
    final faceScale = s * 0.9;

    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = const Color(0xFF2C2C2C);
    final eyeHighlight = Paint()..color = Colors.white;

    final leftEyeX = cx - 5 * s;
    final rightEyeX = cx + 5 * s;
    final eyeY = faceCenterY;
    final eyeR = 3.5 * faceScale;
    final pupilR = 2.0 * faceScale;
    final highlightR = 0.8 * faceScale;

    // Left eye white
    canvas.drawCircle(Offset(leftEyeX, eyeY), eyeR, eyeWhite);
    // Left eye outline
    final eyeOutline = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * faceScale;
    canvas.drawCircle(Offset(leftEyeX, eyeY), eyeR, eyeOutline);
    // Left pupil
    canvas.drawCircle(Offset(leftEyeX + 0.5 * faceScale, eyeY + 0.3 * faceScale), pupilR, eyePupil);
    // Left highlight
    canvas.drawCircle(Offset(leftEyeX - 1.0 * faceScale, eyeY - 1.2 * faceScale), highlightR, eyeHighlight);

    // Right eye white
    canvas.drawCircle(Offset(rightEyeX, eyeY), eyeR, eyeWhite);
    canvas.drawCircle(Offset(rightEyeX, eyeY), eyeR, eyeOutline);
    canvas.drawCircle(Offset(rightEyeX + 0.5 * faceScale, eyeY + 0.3 * faceScale), pupilR, eyePupil);
    canvas.drawCircle(Offset(rightEyeX - 1.0 * faceScale, eyeY - 1.2 * faceScale), highlightR, eyeHighlight);

    // Eyebrows (cute little arcs)
    final browPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * faceScale
      ..strokeCap = StrokeCap.round;

    final browPath = Path()
      ..moveTo(leftEyeX - 4 * faceScale, eyeY - 4.5 * faceScale)
      ..quadraticBezierTo(
          leftEyeX, eyeY - 6.5 * faceScale, leftEyeX + 4 * faceScale, eyeY - 4.5 * faceScale);
    canvas.drawPath(browPath, browPaint);

    final browPath2 = Path()
      ..moveTo(rightEyeX - 4 * faceScale, eyeY - 4.5 * faceScale)
      ..quadraticBezierTo(
          rightEyeX, eyeY - 6.5 * faceScale, rightEyeX + 4 * faceScale, eyeY - 4.5 * faceScale);
    canvas.drawPath(browPath2, browPaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * faceScale
      ..strokeCap = StrokeCap.round;

    final smile = Path()
      ..moveTo(cx - 4.5 * faceScale, eyeY + 5 * faceScale)
      ..quadraticBezierTo(cx, eyeY + 8.5 * faceScale, cx + 4.5 * faceScale, eyeY + 5 * faceScale);
    canvas.drawPath(smile, smilePaint);

    // Cheeks (blush)
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8A80).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(leftEyeX - 5 * faceScale, eyeY + 2.5 * faceScale), 2.5 * faceScale, blushPaint);
    canvas.drawCircle(Offset(rightEyeX + 5 * faceScale, eyeY + 2.5 * faceScale), 2.5 * faceScale, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.anim != anim;
}
