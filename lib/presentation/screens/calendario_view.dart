import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lectura_dia.dart';
import '../../data/services/storage_service.dart';
import '../providers/app_providers.dart';
import 'bible_reader_screen.dart';
import 'publicar_reflexion_screen.dart';

class CalendarioView extends ConsumerStatefulWidget {
  const CalendarioView({super.key});

  @override
  ConsumerState<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends ConsumerState<CalendarioView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentMonthIndex;
  final int _year = DateTime.now().year;

  final List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<String> _dayHeaders = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

  @override
  void initState() {
    super.initState();
    _currentMonthIndex = DateTime.now().month - 1;
    _pageController = PageController(initialPage: _currentMonthIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageProvider);
    final streak = storageService.calcularRacha();
    final total = storageService.getTotalCompletadas();

    return Column(
      children: [
        _MonthHeader(
          monthName: '${_monthNames[_currentMonthIndex]} $_year',
          onPrev: _currentMonthIndex > 0
              ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  )
              : null,
          onNext: _currentMonthIndex < 11
              ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  )
              : null,
          onToday: _goToCurrentMonth,
        ),
        _buildDayHeaders(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 12,
            onPageChanged: (index) {
              setState(() => _currentMonthIndex = index);
            },
            itemBuilder: (context, index) => _buildMonthGrid(index + 1),
          ),
        ),
        _StatsSection(
          mes: _currentMonthIndex + 1,
          streak: streak,
          total: total,
          storageService: storageService,
        ),
        _InspirationCard(streak: streak, onDevotional: () {}),
      ],
    );
  }

  Widget _buildDayHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _dayHeaders
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: day == 'D'
                            ? AppTheme.streakOrange
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid(int mes) {
    final storageService = ref.watch(storageProvider);
    final lecturas = storageService.getLecturasMes(mes);
    final lecturasMap = {for (var l in lecturas) l.dia: l};

    final firstDay = DateTime(_year, mes, 1);
    final daysInMonth = DateTime(_year, mes + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final today = DateTime.now();
    final isCurrentMonth = today.month == mes && today.year == _year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.85,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: startWeekday + daysInMonth,
        itemBuilder: (context, index) {
          if (index < startWeekday) {
            return const SizedBox.shrink();
          }

          final dayNum = index - startWeekday + 1;
          final lectura = lecturasMap[dayNum];
          final isToday = isCurrentMonth && today.day == dayNum;
          final isCompleted = lectura?.completada ?? false;

          return _DayCell(
            dayNum: dayNum,
            isToday: isToday,
            isCompleted: isCompleted,
            isPast: DateTime(_year, mes, dayNum)
                .isBefore(DateTime(today.year, today.month, today.day)),
            onTap: lectura != null
                ? () => _showLecturaBottomSheet(context, lectura, mes, dayNum)
                : null,
          );
        },
      ),
    );
  }

  void _showLecturaBottomSheet(
      BuildContext context, LecturaDia lectura, int mes, int dayNum) {
    final fecha = DateTime(_year, mes, dayNum);
    final fechaFormateada = DateFormat("EEEE, d 'de' MMMM", 'es')
        .format(fecha);
    final diaCapitalizado =
        fechaFormateada[0].toUpperCase() + fechaFormateada.substring(1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final storageService = ref.watch(storageProvider);
            final isCompleted =
                storageService.isDiaCompletado(lectura.fechaClave);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        diaCapitalizado,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? AppTheme.completedGradient
                          : null,
                      color: isCompleted ? null : AppTheme.scaffoldBg,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: isCompleted ? AppTheme.softShadow : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 22,
                              color: isCompleted
                                  ? Colors.white
                                  : AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Lectura del día',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? Colors.white
                                    : AppTheme.primaryBlue,
                              ),
                            ),
                            if (isCompleted) ...[
                              const Spacer(),
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          lectura.pasajes,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? Colors.white
                                : AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await storageService.toggleLectura(lectura.fechaClave);
                        final ahoraCompletado =
                            storageService.isDiaCompletado(lectura.fechaClave);

                        if (mounted) {
                          setModalState(() {});
                          setState(() {});

                          if (ahoraCompletado) {
                            Future.delayed(
                                const Duration(milliseconds: 400), () {
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PublicarReflexionScreen(
                                      pasajeDia: lectura.pasajes,
                                    ),
                                  ),
                                );
                              }
                            });
                          }
                        }
                      },
                      icon: Icon(
                        isCompleted
                            ? Icons.replay_rounded
                            : Icons.check_circle_outline,
                        size: 24,
                      ),
                      label: Text(
                        isCompleted
                            ? 'Marcar como pendiente'
                            : 'Marcar como leído',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? AppTheme.pendingGrayDark
                            : AppTheme.completedGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BibleReaderScreen(
                              pasajes: lectura.pasajes,
                              fechaClave: lectura.fechaClave,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.book_rounded, size: 20),
                      label: const Text(
                        'Leer en la app',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _openBibleOnline(lectura.pasajes),
                      icon: Icon(Icons.open_in_new,
                          size: 16, color: AppTheme.textSecondary),
                      label: Text(
                        'Leer pasajes en línea',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openBibleOnline(String pasajes) async {
    final query = pasajes.split(';').first.trim();
    final url = Uri.parse(
        'https://www.biblegateway.com/passage/?search=${Uri.encodeComponent(query)}&version=RVR1960');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _goToCurrentMonth() {
    final currentMonth = DateTime.now().month - 1;
    _pageController.animateToPage(
      currentMonth,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthName;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onToday;
  const _MonthHeader({
    required this.monthName,
    this.onPrev,
    this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: AppTheme.primaryBlue, size: 24),
            onPressed: onPrev,
          ),
          GestureDetector(
            onTap: onToday,
            child: Text(
              monthName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: AppTheme.primaryBlue, size: 24),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNum;
  final bool isToday;
  final bool isCompleted;
  final bool isPast;
  final VoidCallback? onTap;
  const _DayCell({
    required this.dayNum,
    required this.isToday,
    required this.isCompleted,
    required this.isPast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.completedGreen
              : isToday
                  ? AppTheme.todayHighlight
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppTheme.completedGreen
                : isToday
                    ? AppTheme.primaryBlue
                    : AppTheme.pendingGrayDark.withValues(alpha: 0.3),
            width: isToday ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                fontSize: isToday ? 16 : 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isCompleted
                    ? Colors.white
                    : isToday
                        ? AppTheme.primaryBlue
                        : isPast
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check, size: 14, color: Colors.white)
            else
              const SizedBox(height: 14),
            if (isToday && !isCompleted)
              Text(
                'Hoy',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int mes;
  final int streak;
  final int total;
  final StorageService storageService;
  const _StatsSection({
    required this.mes,
    required this.streak,
    required this.total,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final lecturas = storageService.getLecturasMes(mes);
    final completadas = lecturas.where((l) => l.completada).length;
    final progresoMes = lecturas.isEmpty ? 0.0 : completadas / lecturas.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              icon: Icons.event_available,
              value: '$completadas / ${lecturas.length}',
              label: 'Días leídos',
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.streakGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.white, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    '$streak ${streak == 1 ? 'día' : 'días'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Racha actual',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.pie_chart,
              value: '${(progresoMes * 100).toInt()}%',
              label: 'Progreso',
              color: AppTheme.completedGreen,
              valueWidget: _CircularProgress(progreso: progresoMes),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Widget? valueWidget;
  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          if (valueWidget != null)
            valueWidget!
          else ...[
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double progreso;
  const _CircularProgress({required this.progreso});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progreso,
            strokeWidth: 3,
            backgroundColor: AppTheme.pendingGray,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.completedGreen),
          ),
        ],
      ),
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final int streak;
  final VoidCallback onDevotional;
  const _InspirationCard({
    required this.streak,
    required this.onDevotional,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '¡Sigue así!' : '¡Empieza hoy!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 0
                      ? 'Has mantenido tu racha por $streak días consecutivos. La constancia es la clave de la devoción.'
                      : 'Comienza tu plan de lectura bíblica anual y fortalece tu hábito devocional.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.auto_awesome,
            color: Colors.white.withValues(alpha: 0.15),
            size: 64,
          ),
        ],
      ),
    );
  }
}
