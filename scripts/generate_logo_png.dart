import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  final size = 1024;
  final image = img.Image(width: size, height: size);
  final h = size ~/ 2;

  // Colors
  final bg = img.ColorRgba8(13, 71, 161, 255);
  final flame1 = img.ColorRgba8(216, 67, 21, 255);
  final flame2 = img.ColorRgba8(255, 111, 0, 255);
  final flame3 = img.ColorRgba8(255, 167, 38, 255);
  final flame4 = img.ColorRgba8(255, 213, 79, 255);
  final flame5 = img.ColorRgba8(255, 235, 150, 255);
  final coreLight = img.ColorRgba8(255, 249, 196, 255);
  final eyeWhite = img.ColorRgba8(255, 255, 255, 255);
  final pupil = img.ColorRgba8(44, 44, 44, 255);
  final brown = img.ColorRgba8(78, 52, 46, 255);
  final cheek = img.ColorRgba8(255, 138, 128, 255);
  final wood = img.ColorRgba8(93, 64, 55, 255);
  final page = img.ColorRgba8(255, 248, 225, 255);
  final pageLine = img.ColorRgba8(215, 204, 200, 255);

  // Background circle
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - h;
      final dy = y - h;
      if (dx * dx + dy * dy <= h * h) {
        image.setPixelRgba(x, y, bg.r, bg.g, bg.b, bg.a);
      }
    }
  }

  // Draw log helper
  void drawLog(int cx, int cy, double angleDeg) {
    final rad = angleDeg * math.pi / 180;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    final hw = 180;
    final hh = 28;
    final pts = <img.Point>[
      img.Point((cx + (-cosA * hw + sinA * hh)).toInt(),
          (cy + (-sinA * hw - cosA * hh)).toInt()),
      img.Point((cx + (cosA * hw + sinA * hh)).toInt(),
          (cy + (sinA * hw - cosA * hh)).toInt()),
      img.Point((cx + (cosA * hw - sinA * hh)).toInt(),
          (cy + (sinA * hw + cosA * hh)).toInt()),
      img.Point((cx + (-cosA * hw - sinA * hh)).toInt(),
          (cy + (-sinA * hw + cosA * hh)).toInt()),
    ];
    img.fillPolygon(image, vertices: pts, color: wood);
    img.drawPolygon(image, vertices: pts, color: brown, thickness: 4);
  }

  // Logs
  drawLog(430, 680, -25);
  drawLog(594, 680, 25);
  img.fillRect(image, x1: 410, y1: 660, x2: 614, y2: 704, color: wood);
  img.drawRect(image, x1: 410, y1: 660, x2: 614, y2: 704, color: brown, thickness: 4);

  // Book
  img.fillRect(image, x1: 340, y1: 740, x2: 684, y2: 870, color: wood);
  img.drawRect(image, x1: 340, y1: 740, x2: 684, y2: 870, color: brown, thickness: 4);
  img.fillRect(image, x1: 350, y1: 750, x2: 674, y2: 860, color: page);
  img.drawLine(image, x1: h, y1: 740, x2: h, y2: 870, color: brown, thickness: 6);
  // Book lines
  final lines = [770, 790, 810, 830];
  final leftEnds = [460, 470, 480, 490];
  final rightStarts = [554, 544, 534, 524];
  for (int i = 0; i < lines.length; i++) {
    img.drawLine(image, x1: 370, y1: lines[i], x2: leftEnds[i], y2: lines[i], color: pageLine, thickness: 3);
    img.drawLine(image, x1: rightStarts[i], y1: lines[i], x2: 644, y2: lines[i], color: pageLine, thickness: 3);
  }

  // Flame — layered circles from outer to inner
  img.fillCircle(image, x: h, y: 300, radius: 180, color: flame1);
  img.fillCircle(image, x: h, y: 250, radius: 140, color: flame2);
  img.fillCircle(image, x: h, y: 200, radius: 100, color: flame3);
  img.fillCircle(image, x: h, y: 160, radius: 70, color: flame4);
  img.fillCircle(image, x: h, y: 130, radius: 50, color: flame5);

  // Flame tongues
  img.fillCircle(image, x: 440, y: 220, radius: 50, color: flame2);
  img.fillCircle(image, x: 420, y: 180, radius: 35, color: flame3);
  img.fillCircle(image, x: 584, y: 220, radius: 50, color: flame2);
  img.fillCircle(image, x: 604, y: 180, radius: 35, color: flame3);

  // Inner core
  img.fillCircle(image, x: h, y: 270, radius: 90, color: flame4);
  img.fillCircle(image, x: h, y: 250, radius: 65, color: coreLight);

  // Eyes
  img.fillCircle(image, x: 480, y: 290, radius: 22, color: eyeWhite);
  img.fillCircle(image, x: 544, y: 290, radius: 22, color: eyeWhite);
  img.fillCircle(image, x: 482, y: 292, radius: 11, color: pupil);
  img.fillCircle(image, x: 546, y: 292, radius: 11, color: pupil);
  img.fillCircle(image, x: 476, y: 286, radius: 4, color: eyeWhite);
  img.fillCircle(image, x: 540, y: 286, radius: 4, color: eyeWhite);

  // Eyebrows
  img.drawLine(image, x1: 462, y1: 268, x2: 498, y2: 262, color: brown, thickness: 6);
  img.drawLine(image, x1: 526, y1: 262, x2: 562, y2: 268, color: brown, thickness: 6);

  // Smile
  for (int x = -36; x <= 36; x++) {
    final y = (10.0 * (x / 36.0) * (x / 36.0)).round();
    for (int dy = -2; dy <= 2; dy++) {
      image.setPixelRgba(h + x, 345 + y, brown.r, brown.g, brown.b, brown.a);
    }
  }

  // Cheeks
  img.fillCircle(image, x: 455, y: 315, radius: 16, color: cheek);
  img.fillCircle(image, x: 569, y: 315, radius: 16, color: cheek);

  // Save full-size PNG
  final png = img.encodePng(image);
  File('assets/logo_app.png').writeAsBytesSync(png);
  print('Icono generado: assets/logo_app.png (${png.length} bytes, ${size}x$size)');

  // Generate Android mipmap PNGs
  final sizes = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in sizes.entries) {
    final s = entry.value;
    final resized = img.copyResize(image, width: s, height: s);
    final dir = 'android/app/src/main/res/${entry.key}';
    File('$dir/ic_launcher.png').writeAsBytesSync(img.encodePng(resized));
    print('  -> $dir/ic_launcher.png (${s}x$s)');
  }

  print('Listo! Reconstruye la app para ver el icono.');
}
