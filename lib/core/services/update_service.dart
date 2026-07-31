import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class UpdateService {
  static Future<void> checkForUpdates(BuildContext context) async {
    if (kIsWeb) return; // En web no aplica actualización de app

    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_info')
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final minVersion = data['minVersion'] as String?;
      final latestVersion = data['latestVersion'] as String?;
      final updateUrl = data['updateUrl'] as String?;

      if (minVersion == null || latestVersion == null || updateUrl == null) return;

      final current = AppConstants.currentVersion;
      
      final isRequired = _isVersionLower(current, minVersion);
      final isRecommended = !isRequired && _isVersionLower(current, latestVersion);

      if (isRequired || isRecommended) {
        if (!context.mounted) return;
        _showUpdateDialog(context, isRequired, updateUrl);
      }
    } catch (e) {
      debugPrint('Error comprobando actualizaciones: $e');
    }
  }

  static bool _isVersionLower(String current, String target) {
    final v1 = current.split('.').map(int.parse).toList();
    final v2 = target.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final p1 = i < v1.length ? v1[i] : 0;
      final p2 = i < v2.length ? v2[i] : 0;
      if (p1 < p2) return true;
      if (p1 > p2) return false;
    }
    return false; // Son iguales
  }

  static void _showUpdateDialog(BuildContext context, bool isRequired, String url) {
    showDialog(
      context: context,
      barrierDismissible: !isRequired,
      builder: (ctx) => PopScope(
        canPop: !isRequired,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.system_update_alt, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              const Text('Nueva versión', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            isRequired 
              ? 'Es necesario actualizar la aplicación para continuar usándola.'
              : 'Hay una nueva versión disponible con mejoras y correcciones. ¿Deseas actualizar ahora?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            if (!isRequired)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Más tarde', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
