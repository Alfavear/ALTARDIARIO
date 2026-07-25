import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('assets/logo_app.png').readAsBytesSync())!;

  final webIcons = [
    ('web/favicon.png', 64),
    ('web/icons/Icon-192.png', 192),
    ('web/icons/Icon-512.png', 512),
    ('web/icons/Icon-maskable-192.png', 192),
    ('web/icons/Icon-maskable-512.png', 512),
  ];

  for (final entry in webIcons) {
    final resized = img.copyResize(src, width: entry.$2, height: entry.$2);
    File(entry.$1).writeAsBytesSync(img.encodePng(resized));
    print('  -> ${entry.$1} (${entry.$2}x${entry.$2})');
  }

  print('Web icons generados.');
}
