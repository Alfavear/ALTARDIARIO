import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/app_providers.dart';
import '../data/services/storage_service.dart';

class AnualView extends ConsumerWidget {
  const AnualView({super.key});

  final List<String> _monthNames = const [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = ref.watch(storageProvider);
    
    final progreso = storageService.getProgreso();
    final total = storageService.getTotalCompletadas();
    final streak = storageService.calcularRacha();
    final maxStreak = storageService.getMaxStreak();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Cabecera con progreso general
          SliverToBoxAdapter(child: _buildProgressHeader(context, progreso, total)),
          // Estadísticas rápidas
          SliverToBoxAdapter(child: _buildStatsRow(streak, maxStreak, total)),
          // Título sección meses
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Progreso por mes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          // Grid de 12 mini-calendarios
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMiniMonth(context, index + 1, storageService),
                childCount: 12,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  /// Cabecera circular de progreso anual.
  Widget _buildProgressHeader(
      BuildContext context, double progreso, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Row(
        children: [
          // Indicador circular
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progreso,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentGold),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progreso * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Texto de progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progreso Anual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total de 365 lecturas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Barra lineal de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentGold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de estadísticas rápidas (racha, máx racha, completadas).
  Widget _buildStatsRow(int streak, int maxStreak, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard('🔥', '$streak', 'Racha', AppTheme.streakOrange),
          const SizedBox(width: 8),
          _buildStatCard('🏆', '$maxStreak', 'Máx. racha', AppTheme.accentGold),
          const SizedBox(width: 8),
          _buildStatCard(
            '📖',
            '${365 - total}',
            'Pendientes',
            AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mini-calendario de un mes (mapa de calor simplificado).
  Widget _buildMiniMonth(BuildContext context, int mes, StorageService storageService) {
    final year = DateTime.now().year;
    final lecturas = storageService.getLecturasMes(mes);
    final completadasSet = {
      for (var l in lecturas)
        if (l.completada) l.dia
    };
    final daysInMonth = DateTime(year, mes + 1, 0).day;
    final firstDayWeekday = DateTime(year, mes, 1).weekday % 7;
    final progresoMes = storageService.getProgresoMes(mes);
    final isCurrentMonth = DateTime.now().month == mes;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? AppTheme.primaryBlue.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isCurrentMonth
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.12),
          width: isCurrentMonth ? 1.5 : 1,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del mes y progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _monthNames[mes - 1],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCurrentMonth
                      ? AppTheme.primaryBlue
                      : AppTheme.textPrimary,
                ),
              ),
              Text(
                '${(progresoMes * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: progresoMes >= 1.0
                      ? AppTheme.completedGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Grid de días como puntos de calor
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: firstDayWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstDayWeekday) {
                  return const SizedBox.shrink();
                }
                final day = index - firstDayWeekday + 1;
                final isCompleted = completadasSet.contains(day);
                final isToday = isCurrentMonth && DateTime.now().day == day;

                return Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.completedGreen
                        : isToday
                            ? AppTheme.accentGold
                            : AppTheme.pendingGray,
                    borderRadius: BorderRadius.circular(2),
                    border: isToday && !isCompleted
                        ? Border.all(color: AppTheme.accentGold, width: 1)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
