import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lectura_dia.dart';
import '../../data/models/reflexion.dart';
import '../../data/services/bible_service.dart';
import '../providers/app_providers.dart';
import 'bible_reader_screen.dart';
import 'notes_screen.dart';
import 'public_profile_screen.dart';
import 'amigos_rachas_screen.dart';
import 'foro_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onNavigateTo;

  const HomeScreen({super.key, this.onNavigateTo});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final BibleService _bibleService = BibleService();
  String? _verseText;
  String? _verseRef;
  String? _passageTitle;
  bool _loadingVerse = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadVerse);
  }

  Future<void> _loadVerse() async {
    try {
      final storage = ref.read(storageProvider);
      final now = DateTime.now();
      final lecturas = storage.getLecturasMes(now.month);
      final hoy = lecturas.firstWhere(
        (l) => l.dia == now.day,
        orElse: () => LecturaDia(
          dia: now.day,
          pasajes: 'Salmo 1',
          fechaClave: DateFormat('yyyy-MM-dd').format(now),
        ),
      );
      _passageTitle = hoy.pasajes.split(';').first.trim();
      final pasaje = hoy.pasajes.split(';').first.trim();
      final passages = await _bibleService.getPassageText(pasaje);
      if (passages.isNotEmpty && passages.first.verses.isNotEmpty) {
        final v = passages.first.verses.first;
        if (mounted) {
          setState(() {
            _verseText = v.text;
            _verseRef = '${v.bookName} ${v.chapter}:${v.verse}';
            _loadingVerse = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingVerse = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingVerse = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageProvider);
    final reflexionesAsync = ref.watch(reflexionesStreamProvider);
    final focusMode = ref.watch(focusModeProvider);
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final isCompleted = storage.isDiaCompletado(dateKey);
    final racha = storage.calcularRacha();
    final total = storage.getTotalCompletadas();

    return PopScope(
      canPop: !focusMode || isCompleted,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showFocusModeWarning();
      },
      child: Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text('AltarDiario',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20)),
          ],
        ),
        actions: [
          if (focusMode)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.lock, color: Colors.white, size: 20),
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white),
            onPressed: () => _handleNavigate(4, isCompleted),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text('Mi Lectura Hoy',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('Continúa tu camino de fe y reflexión.',
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          _buildReadingCard(isCompleted),
          const SizedBox(height: 16),
          _buildStreakCard(racha),
          const SizedBox(height: 24),
          _buildUpcomingReadings(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Devocional',
                  color: AppTheme.primaryBlue,
                  onTap: () => _handleNavigate(1, isCompleted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.book_rounded,
                  label: 'Biblia',
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BibleReaderScreen(
                          pasajes: 'Salmo 1',
                          fechaClave:
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          readOnly: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.forum_rounded,
                  label: 'Comunidad',
                  color: AppTheme.streakOrange,
                  onTap: () => _handleNavigate(2, isCompleted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Oración',
                  color: AppTheme.completedGreen,
                  onTap: () => _handleNavigate(3, isCompleted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.forum,
                  label: 'Foro Bíblico',
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForoScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Leaderboard',
                  color: AppTheme.streakOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '$racha días',
                  color: AppTheme.streakOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle,
                  label: 'Completadas',
                  value: '$total/365',
                  color: isCompleted
                      ? AppTheme.completedGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AmigosRachasScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.streakOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: AppTheme.streakOrange),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rachas entre Amigos',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Text('Compite y motívate con tu comunidad',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer(builder: (_, ref2, __) {
            final sugerenciasAsync = ref2.watch(sugerenciasAmistadProvider);
            return sugerenciasAsync.when(
              data: (usuarios) {
                if (usuarios.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personas que quizás conozcas',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: usuarios.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final u = usuarios[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PublicProfileScreen(
                                      userId: u.id),
                                ),
                              );
                            },
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.primaryBlue
                                        .withValues(alpha: 0.12),
                                    backgroundImage: u.fotoUrl.isNotEmpty
                                        ? NetworkImage(u.fotoUrl)
                                        : null,
                                    child: u.fotoUrl.isEmpty
                                        ? Text(
                                            u.nombre.isNotEmpty
                                                ? u.nombre[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.primaryBlue))
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(u.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotesScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.note_alt_rounded,
                        color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mis Notas',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Text('Apuntes, prédicas e ideas',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Últimas reflexiones',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          reflexionesAsync.when(
            data: (reflexiones) {
              final preview = reflexiones.take(3).toList();
              if (preview.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Aún no hay reflexiones.\n¡Marca una lectura y comparte tu pensamiento!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
      ),
      );
  }
              return Column(
                children: [
                  for (final r in preview)
                    _ReflexionPreviewCard(reflexion: r),
                  if (reflexiones.length > 3)
                    TextButton(
                      onPressed: () =>
                          _handleNavigate(2, isCompleted),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ver todas en Altar'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      ),
    );
  }

  void _handleNavigate(int tab, bool completed) {
    final focusMode = ref.read(focusModeProvider);
    if (focusMode && !completed) {
      _showFocusModeWarning();
      return;
    }
    widget.onNavigateTo?.call(tab);
  }

  void _showFocusModeWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔒 Modo Enfoque'),
        content: const Text(
          'Aún no has completado tu lectura de hoy.\n\n'
          'Termina tu devocional o desactiva el Modo Enfoque para navegar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Seguir leyendo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(focusModeProvider.notifier).toggle();
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.auto_stories,
                      size: 48,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Plan Anual',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _passageTitle ?? 'Salmo 1',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 8),
                if (_loadingVerse)
                  const SizedBox(
                    height: 40,
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))),
                  )
                else if (_verseText != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_verseText',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                            color: AppTheme.textSecondary),
                      ),
                      if (_verseRef != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _verseRef!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Progreso del capítulo',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text(
                      isCompleted ? '100%' : '0%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppTheme.completedGreen
                              : AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1.0 : 0.0,
                    backgroundColor:
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                    color: AppTheme.completedGreen,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BibleReaderScreen(
                                pasajes: _passageTitle ?? 'Salmo 1',
                                fechaClave: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                readOnly: true,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book,
                            size: 18, color: Colors.white),
                        label: const Text('Leer pasaje',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.completedGreenLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted
                                ? AppTheme.completedGreen
                                : AppTheme.pendingGrayDark,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: isCompleted
                              ? AppTheme.completedGreen
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int racha) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.streakOrange, AppTheme.streakOrangeLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$racha Días de Racha',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              const Text('¡Vas excelente! No rompas el hábito.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReadings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Próximas Lecturas',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => widget.onNavigateTo?.call(1),
              child: const Text('Ver plan',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryBlue)),
            ),
          ],
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _MiniReadingCard(
                day: 'Mañana',
                passage: 'Génesis 1:11-20',
              ),
              _MiniReadingCard(
                day: 'Miércoles',
                passage: 'Génesis 1:21-31',
              ),
              _MiniReadingCard(
                day: 'Jueves',
                passage: 'Génesis 2:1-7',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniReadingCard extends StatelessWidget {
  final String day;
  final String passage;
  const _MiniReadingCard({required this.day, required this.passage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.pendingGrayDark.withValues(alpha: 0.3)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
           Text(passage,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
               style: const TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.w700,
                   color: AppTheme.primaryBlue)),
           const Spacer(),
           Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               const Icon(Icons.schedule,
                   size: 14, color: AppTheme.pendingGrayDark),
               const SizedBox(width: 4),
               const Text('Planificado',
                   style: TextStyle(
                       fontSize: 11,
                       color: AppTheme.pendingGrayDark)),
             ],
           ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReflexionPreviewCard extends StatelessWidget {
  final Reflexion reflexion;

  const _ReflexionPreviewCard({required this.reflexion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(reflexion.pasajeDia,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                        fontStyle: FontStyle.italic)),
                const Spacer(),
                Text(
                  DateFormat('dd MMM').format(reflexion.fecha),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(reflexion.texto,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.3)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.favorite, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Text('${reflexion.likes}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(
                            userId: reflexion.userId),
                      ),
                    );
                  },
                  child: Text(reflexion.userName,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
