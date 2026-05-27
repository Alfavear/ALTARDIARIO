import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lectura_dia.dart';
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
  late int _currentMonthIndex; // 0 = Enero, 11 = Diciembre
  final int _year = DateTime.now().year;

  final List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<String> _dayHeaders = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

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
    return Column(
      children: [
        _buildHeader(),
        _buildStreakBanner(),
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
      ],
    );
  }

  /// Cabecera con gradiente azul, nombre del mes y flechas de navegación.
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXLarge),
          bottomRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              // Título de la app
              Text(
                'altarDiario',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tu hábito diario con Dios',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              // Selector de mes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    onPressed: _currentMonthIndex > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                  GestureDetector(
                    onTap: _goToCurrentMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Text(
                        '${_monthNames[_currentMonthIndex]} $_year',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                    onPressed: _currentMonthIndex < 11
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner de racha con icono de fuego 🔥 y animación.
  Widget _buildStreakBanner() {
    final storageService = ref.watch(storageProvider);
    final streak = storageService.calcularRacha();
    final totalCompletadas = storageService.getTotalCompletadas();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Racha actual
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: streak > 0
                    ? AppTheme.streakGradient
                    : null,
                color: streak == 0 ? AppTheme.pendingGray : null,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: streak > 0 ? AppTheme.softShadow : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    streak > 0 ? '🔥' : '💤',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak ${streak == 1 ? 'día' : 'días'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: streak > 0 ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Racha actual',
                        style: TextStyle(
                          fontSize: 11,
                          color: streak > 0
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Progreso total
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.completedGreenLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalCompletadas/365',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.completedGreen,
                        ),
                      ),
                      const Text(
                        'Lecturas',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezados de día de semana (Dom, Lun, ..., Sáb).
  Widget _buildDayHeaders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: _dayHeaders
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: day == 'Dom'
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

  /// Grilla mensual de días con las lecturas bíblicas.
  Widget _buildMonthGrid(int mes) {
    final storageService = ref.watch(storageProvider);
    final lecturas = storageService.getLecturasMes(mes);
    final lecturasMap = {for (var l in lecturas) l.dia: l};

    final firstDay = DateTime(_year, mes, 1);
    final daysInMonth = DateTime(_year, mes + 1, 0).day;
    // Ajuste para que Domingo = 0
    final startWeekday = firstDay.weekday % 7;

    final today = DateTime.now();
    final isCurrentMonth = today.month == mes && today.year == _year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.58,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
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
          final isPast = DateTime(_year, mes, dayNum).isBefore(
              DateTime(today.year, today.month, today.day));

          return _buildDayCell(
            dayNum: dayNum,
            mes: mes,
            lectura: lectura,
            isToday: isToday,
            isCompleted: isCompleted,
            isPast: isPast,
          );
        },
      ),
    );
  }

  /// Celda individual de un día en el calendario.
  Widget _buildDayCell({
    required int dayNum,
    required int mes,
    LecturaDia? lectura,
    required bool isToday,
    required bool isCompleted,
    required bool isPast,
  }) {
    Color bgColor;
    Color borderColor;
    Color dayNumColor;

    if (isCompleted) {
      bgColor = AppTheme.completedGreenLight;
      borderColor = AppTheme.completedGreen.withValues(alpha: 0.4);
      dayNumColor = AppTheme.completedGreen;
    } else if (isToday) {
      bgColor = AppTheme.todayHighlight;
      borderColor = AppTheme.accentGold;
      dayNumColor = AppTheme.primaryBlue;
    } else if (isPast) {
      bgColor = Colors.white;
      borderColor = Colors.red.withValues(alpha: 0.15);
      dayNumColor = AppTheme.textSecondary;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.withValues(alpha: 0.12);
      dayNumColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTap: lectura != null
          ? () => _showLecturaBottomSheet(context, lectura, mes, dayNum)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: borderColor,
            width: isToday ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número del día y check
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: isToday ? 14 : 12,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: dayNumColor,
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: AppTheme.completedGreen, size: 14),
                  if (isToday && !isCompleted)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              // Pasajes bíblicos
              if (lectura != null)
                Expanded(
                  child: Text(
                    lectura.pasajes,
                    style: TextStyle(
                      fontSize: 7.5,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: isCompleted
                          ? AppTheme.completedGreen.withValues(alpha: 0.8)
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// BottomSheet con detalle de la lectura del día.
  void _showLecturaBottomSheet(
      BuildContext context, LecturaDia lectura, int mes, int dayNum) {
    final fecha = DateTime(_year, mes, dayNum);
    final fechaFormateada = DateFormat("EEEE, d 'de' MMMM 'del' yyyy", 'es')
        .format(fecha);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final storageService = ref.watch(storageProvider);
            final isCompleted = storageService.isDiaCompletado(lectura.fechaClave);

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
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Fecha formateada
                  Text(
                    fechaFormateada,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pasajes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.completedGreenLight
                          : AppTheme.scaffoldBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.completedGreen.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 20,
                              color: isCompleted
                                  ? AppTheme.completedGreen
                                  : AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lectura del día',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? AppTheme.completedGreen
                                    : AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lectura.pasajes,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de marcar como leído
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await storageService.toggleLectura(lectura.fechaClave);
                        
                        // Si se marcó como completado, ofrecer publicar reflexión
                        final ahoraCompletado = storageService.isDiaCompletado(lectura.fechaClave);
                        
                        if (mounted) {
                          setModalState(() {});
                          setState(() {}); // Actualizar el calendario
                          
                          if (ahoraCompletado) {
                            // Pequeño delay para dejar que la UI se actualice
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (context.mounted) {
                                Navigator.pop(context); // Cerrar bottom sheet actual
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PublicarReflexionScreen(
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
                        size: 22,
                      ),
                      label: Text(
                        isCompleted
                            ? 'Marcar como pendiente'
                            : 'Marcar como leído ✓',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
                  // Botón de leer online
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: const Text('📖 LEER EN LA APP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _openBibleOnline(lectura.pasajes),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'Leer pasajes en línea',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
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

  /// Abre los pasajes bíblicos en BibleGateway (navegador externo).
  Future<void> _openBibleOnline(String pasajes) async {
    // Toma el primer pasaje para la búsqueda
    final query = pasajes.split(';').first.trim();
    final url = Uri.parse(
        'https://www.biblegateway.com/passage/?search=${Uri.encodeComponent(query)}&version=RVR1960');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Navega al mes actual.
  void _goToCurrentMonth() {
    final currentMonth = DateTime.now().month - 1;
    _pageController.animateToPage(
      currentMonth,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
