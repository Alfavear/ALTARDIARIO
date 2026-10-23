import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Hoja de exportación de la biblioteca personal.
///
/// Deja claro que nada sale del dispositivo sin que el usuario lo pida: el
/// texto se copia al portapapeles y es el usuario quien decide compartirlo.
class HojaExportarBiblioteca extends StatelessWidget {
  final String texto;
  final VoidCallback onCopiar;

  const HojaExportarBiblioteca({
    super.key,
    required this.texto,
    required this.onCopiar,
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
                const Icon(Icons.lock_outline,
                    size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Exportar mi biblioteca',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Se copia en tu portapapeles y tú decides dónde pegarla. '
              'No se envía nada a otros usuarios ni a terceros.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 240),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                    color: AppTheme.pendingGrayDark.withValues(alpha: 0.3)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCopiar,
                    icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                    label: const Text('Copiar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
