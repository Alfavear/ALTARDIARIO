import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lectura_dia.dart';
import '../../data/models/reflexion.dart';
import '../../data/services/bible_service.dart';
import '../providers/app_providers.dart';
import '../widgets/app_logo_widget.dart';
import 'bible_reader_screen.dart';
import 'notes_screen.dart';

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
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final isCompleted = storage.isDiaCompletado(dateKey);
    final racha = storage.calcularRacha();
    final total = storage.getTotalCompletadas();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogoWidget(size: 36),
                      const SizedBox(width: 12),
                      Text('AltarDiario',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Verso del día',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_loadingVerse)
                    const SizedBox(
                      height: 60,
                      child: Center(
                          child: CircularProgressIndicator(color: Colors.white)),
                    )
                  else if (_verseText != null) ...[
                    Text('"$_verseText"',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(_verseRef ?? '',
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 13)),
                        const Spacer(),
                        Text(
                          isCompleted ? '✓ Completado' : 'Pendiente',
                          style: TextStyle(
                            color: isCompleted ? Colors.greenAccent : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text('Hoy: abre tu devocional',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.menu_book_rounded,
                              label: 'Devocional',
                              color: AppTheme.primaryBlue,
                              onTap: () => widget.onNavigateTo?.call(1),
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
                                      fechaClave: DateFormat('yyyy-MM-dd').format(DateTime.now()),
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
                              onTap: () => widget.onNavigateTo?.call(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.auto_awesome_rounded,
                              label: 'Oración',
                              color: AppTheme.completedGreen,
                              onTap: () => widget.onNavigateTo?.call(3),
                            ),
                          ),
                        ],
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
                          color:
                              isCompleted ? AppTheme.completedGreen : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotesScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
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
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              onPressed: () => widget.onNavigateTo?.call(2),
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
    return Expanded(
      child: Material(
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
                Text(reflexion.userName,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
