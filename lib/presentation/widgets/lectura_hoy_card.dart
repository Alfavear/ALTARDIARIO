import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'lectura_hoy_estados.dart';

/// Tarjeta de la lectura de hoy.
///
/// Reúne los cuatro estados que el usuario ve en Inicio: cargando (skeleton),
/// sin conexión, pendiente y completado. Toda la tarjeta abre la lectura
/// pendiente en un solo toque y, cuando el día está completo, muestra una
/// celebración discreta y la siguiente lectura del plan.
///
/// El texto se adapta al escalado de accesibilidad: no hay alturas fijas
/// alrededor de texto y las acciones usan [Wrap], así que a escalas grandes
/// pasan a una segunda línea en lugar de recortarse.
class LecturaHoyCard extends StatelessWidget {
  final String pasaje;
  final String? versiculo;
  final String? referencia;
  final bool cargando;
  final bool sinConexion;
  final bool completado;
  final String? siguientePasaje;
  final VoidCallback onAbrir;
  final VoidCallback onMarcarCompletado;
  final VoidCallback? onAbrirSiguiente;

  const LecturaHoyCard({
    super.key,
    required this.pasaje,
    required this.cargando,
    required this.completado,
    required this.onAbrir,
    required this.onMarcarCompletado,
    this.versiculo,
    this.referencia,
    this.sinConexion = false,
    this.siguientePasaje,
    this.onAbrirSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: completado
          ? 'Lectura de hoy completada: $pasaje'
          : 'Abrir la lectura de hoy: $pasaje',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onAbrir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Portada(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pasaje,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Contenido(
                      cargando: cargando,
                      sinConexion: sinConexion,
                      versiculo: versiculo,
                      referencia: referencia,
                    ),
                    const SizedBox(height: 12),
                    _Progreso(completado: completado),
                    const SizedBox(height: 14),
                    if (completado) ...[
                      const LecturaCelebracion(),
                      if (siguientePasaje != null) ...[
                        const SizedBox(height: 10),
                        LecturaSiguiente(
                          pasaje: siguientePasaje!,
                          onAbrir: onAbrirSiguiente,
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onAbrir,
                          icon: const Icon(Icons.menu_book,
                              size: 18, color: Colors.white),
                          label: const Text(
                            'Leer pasaje',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        _BotonCompletar(
                          completado: completado,
                          onPressed: onMarcarCompletado,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Portada extends StatelessWidget {
  const _Portada();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.auto_stories,
                size: 48, color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Plan Anual',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final bool cargando;
  final bool sinConexion;
  final String? versiculo;
  final String? referencia;

  const _Contenido({
    required this.cargando,
    required this.sinConexion,
    this.versiculo,
    this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) return const LecturaSkeleton();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sinConexion) ...[
          const LecturaAvisoSinConexion(),
          const SizedBox(height: 8),
        ],
        if (versiculo != null) ...[
          Text(
            versiculo!,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          if (referencia != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                referencia!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue),
              ),
            ),
        ] else if (!sinConexion)
          const Text(
            'Abre el pasaje para empezar la lectura.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
      ],
    );
  }
}

class _Progreso extends StatelessWidget {
  final bool completado;

  const _Progreso({required this.completado});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Progreso del capítulo',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ),
            Text(
              completado ? '100%' : '0%',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: completado
                      ? AppTheme.completedGreen
                      : AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completado ? 1 : 0,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            color: AppTheme.completedGreen,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _BotonCompletar extends StatelessWidget {
  final bool completado;
  final VoidCallback onPressed;

  const _BotonCompletar({required this.completado, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: completado
          ? 'Marcar la lectura de hoy como pendiente'
          : 'Marcar la lectura de hoy como completada',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                completado ? AppTheme.completedGreenLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: completado
                  ? AppTheme.completedGreen
                  : AppTheme.pendingGrayDark,
            ),
          ),
          child: Icon(
            Icons.check,
            color:
                completado ? AppTheme.completedGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
