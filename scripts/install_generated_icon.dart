import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final sourcePath = r'C:\Users\ALVEAR\.gemini\antigravity-ide\brain\6c8a2f47-f072-4b66-8bfd-9a658732b4cd\media__1785286736401.png';
  final sourceFile = File(sourcePath);

  if (!sourceFile.existsSync()) {
    print('Error: Source file does not exist at $sourcePath');
    return;
  }

  final bytes = sourceFile.readAsBytesSync();
  img.Image? image;
  try { image ??= img.decodeImage(bytes); } catch (_) {}
  try { image ??= img.decodePng(bytes); } catch (_) {}
  try { image ??= img.decodeJpg(bytes); } catch (_) {}
  try { image ??= img.decodeWebP(bytes); } catch (_) {}
  try { image ??= img.decodeBmp(bytes); } catch (_) {}
  try { image ??= img.decodeNamedImage(sourcePath, bytes); } catch (_) {}

  if (image == null) {
    print('Error: Failed to decode image');
    return;
  }

  void saveResized(String path, int width, int height) {
    final resized = img.copyResize(image!, width: width, height: height, interpolation: img.Interpolation.linear);
    final outFile = File(path);
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(img.encodePng(resized));
    print('Saved: $path (${width}x$height)');
  }

  // 1. Assets
  saveResized('assets/logo_app.png', 1024, 1024);

  // 2. Web
  saveResized('web/favicon.png', 64, 64);
  saveResized('web/icons/Icon-192.png', 192, 192);
  saveResized('web/icons/Icon-512.png', 512, 512);
  saveResized('web/icons/Icon-maskable-192.png', 192, 192);
  saveResized('web/icons/Icon-maskable-512.png', 512, 512);

  // 3. Android mipmaps
  saveResized('android/app/src/main/res/mipmap-mdpi/ic_launcher.png', 48, 48);
  saveResized('android/app/src/main/res/mipmap-hdpi/ic_launcher.png', 72, 72);
  saveResized('android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', 96, 96);
  saveResized('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 144, 144);
  saveResized('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', 192, 192);

  print('All app icons updated successfully!');
}
