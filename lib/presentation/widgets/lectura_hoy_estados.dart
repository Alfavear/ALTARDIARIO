import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Skeleton de carga del versículo de hoy.
///
/// Barras grises en lugar del spinner: la tarjeta no cambia de tamaño cuando
/// llega el texto real, así que no hay salto visual.
class LecturaSkeleton extends StatelessWidget {
  const LecturaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando la lectura de hoy',
      child: const ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BarraSkeleton(ancho: double.infinity, alto: 12),
            SizedBox(height: 8),
            _BarraSkeleton(ancho: 220, alto: 12),
            SizedBox(height: 8),
            _BarraSkeleton(ancho: 140, alto: 12),
          ],
        ),
      ),
    );
  }
}

class _BarraSkeleton extends StatelessWidget {
  final double ancho;
  final double alto;

  const _BarraSkeleton({required this.ancho, required this.alto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: AppTheme.pendingGrayDark.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Aviso de que no pudimos traer el versículo desde la base local.
class LecturaAvisoSinConexion extends StatelessWidget {
  const LecturaAvisoSinConexion({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.cloud_off, size: 16, color: AppTheme.textSecondary),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Sin conexión · mostrando tu plan guardado',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Celebración discreta del día completado.
///
/// Entra con un scale suave, sin confeti ni diálogos: el usuario sigue en su
/// flujo de lectura y solo recibe la confirmación.
class LecturaCelebracion extends StatelessWidget {
  const LecturaCelebracion({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 220),
      builder: (context, valor, child) =>
          Transform.scale(scale: valor, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.completedGreenLight,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.completedGreen.withValues(alpha: 0.4)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: AppTheme.completedGreen, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Día completado!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.completedGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Buen trabajo. Mañana continuamos.',
                    style: TextStyle(fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Siguiente lectura del plan con acceso directo.
class LecturaSiguiente extends StatelessWidget {
  final String pasaje;
  final VoidCallback? onAbrir;

  const LecturaSiguiente({super.key, required this.pasaje, this.onAbrir});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Siguiente: $pasaje',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
        ),
        if (onAbrir != null)
          TextButton(
            onPressed: onAbrir,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Abrir', style: TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}
