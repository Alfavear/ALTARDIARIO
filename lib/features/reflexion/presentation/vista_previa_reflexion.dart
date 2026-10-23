import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Vista previa de la reflexión antes de publicarla.
///
/// Publicar es irreversible: la reflexión queda en el feed y se notifica a la
/// comunidad. Por eso mostramos exactamente lo que se va a publicar y pedimos
/// una confirmación explícita. Devuelve `true` solo si el usuario confirma.
class VistaPreviaReflexion extends StatelessWidget {
  final String pasaje;
  final String texto;

  const VistaPreviaReflexion({
    super.key,
    required this.pasaje,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility_outlined,
                    size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Así se verá tu reflexión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            if (pasaje.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pasaje.trim(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                    color: AppTheme.pendingGrayDark.withValues(alpha: 0.3)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  texto.trim(),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Seguir editando'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Al publicar, tu reflexión será visible para la comunidad.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
