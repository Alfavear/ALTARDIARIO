import 'package:flutter/material.dart' hide Badge;
import '../../data/models/badge.dart';
import '../../data/models/usuario.dart';
import '../../data/models/reflexion.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/storage_service.dart';
import '../theme/app_theme.dart';
import 'notification_service.dart';

class GamificationService {
  static final Map<String, Badge> _allBadges = {
    'primer_paso': Badge(
      id: 'primer_paso',
      name: 'Primer Paso',
      description: 'Completa tu primera lectura',
      icon: '🌱',
      category: BadgeCategory.progreso,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'lecturas_completadas', 'valor': 1},
      points: 10,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'semana_fiel': Badge(
      id: 'semana_fiel',
      name: 'Semana Fiel',
      description: 'Mantén una racha de 7 días',
      icon: '🔥',
      category: BadgeCategory.racha,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'racha', 'valor': 7},
      points: 50,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'mes_fiel': Badge(
      id: 'mes_fiel',
      name: 'Mes Fiel',
      description: 'Mantén una racha de 30 días',
      icon: '🏆',
      category: BadgeCategory.racha,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'racha', 'valor': 30},
      points: 200,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'cien_lecturas': Badge(
      id: 'cien_lecturas',
      name: 'Centurión',
      description: 'Completa 100 lecturas',
      icon: '📖',
      category: BadgeCategory.progreso,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'lecturas_completadas', 'valor': 100},
      points: 150,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'trescientos65': Badge(
      id: 'trescientos65',
      name: 'Año Completo',
      description: 'Completa las 365 lecturas del año',
      icon: '👑',
      category: BadgeCategory.progreso,
      rarity: BadgeRarity.legendario,
      criteria: {'tipo': 'lecturas_completadas', 'valor': 365},
      points: 1000,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'primer_amen': Badge(
      id: 'primer_amen',
      name: 'Primer Amén',
      description: 'Da tu primer "Amén" a una reflexión',
      icon: '🙏',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'likes_dados', 'valor': 1},
      points: 10,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'cien_amenes': Badge(
      id: 'cien_amenes',
      name: 'Generoso',
      description: 'Da 100 "Amén" a reflexiones',
      icon: '💖',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'likes_dados', 'valor': 100},
      points: 100,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'primer_comentario': Badge(
      id: 'primer_comentario',
      name: 'Conversador',
      description: 'Escribe tu primer comentario',
      icon: '💬',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'comentarios', 'valor': 1},
      points: 15,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'diez_comentarios': Badge(
      id: 'diez_comentarios',
      name: 'Participante Activo',
      description: 'Escribe 10 comentarios',
      icon: '🗣️',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'comentarios', 'valor': 10},
      points: 75,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'primera_peticion': Badge(
      id: 'primera_peticion',
      name: 'Intercesor',
      description: 'Publica tu primera petición de oración',
      icon: '🕊️',
      category: BadgeCategory.oracion,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'peticiones_publicadas', 'valor': 1},
      points: 20,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'cinco_peticiones': Badge(
      id: 'cinco_peticiones',
      name: 'Guerrero de Oración',
      description: 'Publica 5 peticiones de oración',
      icon: '⚔️',
      category: BadgeCategory.oracion,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'peticiones_publicadas', 'valor': 5},
      points: 100,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'primera_reflexion': Badge(
      id: 'primera_reflexion',
      name: 'Escritor',
      description: 'Publica tu primera reflexión',
      icon: '✍️',
      category: BadgeCategory.progreso,
      rarity: BadgeRarity.comun,
      criteria: {'tipo': 'reflexiones_publicadas', 'valor': 1},
      points: 30,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'diez_reflexiones': Badge(
      id: 'diez_reflexiones',
      name: 'Predicador',
      description: 'Publica 10 reflexiones',
      icon: '📝',
      category: BadgeCategory.progreso,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'reflexiones_publicadas', 'valor': 10},
      points: 200,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'biblia_diaria': Badge(
      id: 'biblia_diaria',
      name: 'Estudiante de la Palabra',
      description: 'Lee la Biblia 30 días seguidos (Modo Enfoque)',
      icon: '📜',
      category: BadgeCategory.biblia,
      rarity: BadgeRarity.epico,
      criteria: {'tipo': 'dias_enfoque', 'valor': 30},
      points: 300,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'seguidor_fiel': Badge(
      id: 'seguidor_fiel',
      name: 'Seguidor Fiel',
      description: 'Sigue a 10 usuarios',
      icon: '👥',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.raro,
      criteria: {'tipo': 'siguiendo', 'valor': 10},
      points: 50,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'influencer': Badge(
      id: 'influencer',
      name: 'Influencer Espiritual',
      description: 'Consigue 50 seguidores',
      icon: '⭐',
      category: BadgeCategory.comunidad,
      rarity: BadgeRarity.epico,
      criteria: {'tipo': 'seguidores', 'valor': 50},
      points: 300,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    'navidad_2025': Badge(
      id: 'navidad_2025',
      name: 'Navidad 2025',
      description: 'Completa la lectura del 25 de diciembre',
      icon: '🎄',
      category: BadgeCategory.especial,
      rarity: BadgeRarity.legendario,
      criteria: {'tipo': 'fecha_especial', 'valor': '2025-12-25'},
      points: 500,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  };

  static const Map<int, int> _xpPerLevel = {
    1: 0,
    2: 100,
    3: 250,
    4: 500,
    5: 1000,
    6: 2000,
    7: 3500,
    8: 5500,
    9: 8000,
    10: 11000,
  };

  static List<Badge> getAllBadges() => _allBadges.values.toList();

  static Badge? getBadge(String id) => _allBadges[id];

  static List<Badge> getBadgesByCategory(BadgeCategory category) =>
      _allBadges.values.where((b) => b.category == category).toList();

  static List<Badge> getUnlockedBadges(Usuario user) =>
      _allBadges.values.where((b) => user.badges.contains(b.id)).toList();

  static List<Badge> getLockedBadges(Usuario user) =>
      _allBadges.values.where((b) => !user.badges.contains(b.id)).toList();

  static int calculateLevel(int totalPoints) {
    for (int i = 10; i >= 1; i--) {
      final required = _xpPerLevel[i] ?? 0;
      if (totalPoints >= required) return i;
    }
    return 1;
  }

  static int getXpForLevel(int level) => _xpPerLevel[level] ?? 0;

  static int getXpForNextLevel(int currentLevel) =>
      _xpPerLevel[currentLevel + 1] ?? _xpPerLevel[10]!;

  static double getLevelProgress(int totalPoints, int currentLevel) {
    final currentXp = _xpPerLevel[currentLevel] ?? 0;
    final nextXp = _xpPerLevel[currentLevel + 1] ?? _xpPerLevel[10]!;
    if (nextXp == currentXp) return 1.0;
    return ((totalPoints - currentXp) / (nextXp - currentXp)).clamp(0.0, 1.0);
  }

  static Future<List<String>> checkAndAwardBadges({
    required Usuario user,
    required FirestoreService firestore,
    required StorageService storage,
    required Map<String, dynamic> stats,
  }) async {
    final newlyUnlocked = <String>[];
    final currentBadges = user.badges.toSet();

    for (final badge in _allBadges.values) {
      if (currentBadges.contains(badge.id)) continue;

      bool shouldUnlock = false;

      switch (badge.criteria['tipo']) {
        case 'racha':
          final racha = stats['rachaActual'] ?? 0;
          shouldUnlock = racha >= (badge.criteria['valor'] as int);
          break;
        case 'lecturas_completadas':
          final completadas = stats['totalCompletadas'] ?? 0;
          shouldUnlock = completadas >= (badge.criteria['valor'] as int);
          break;
        case 'likes_dados':
          final likes = stats['likesDados'] ?? 0;
          shouldUnlock = likes >= (badge.criteria['valor'] as int);
          break;
        case 'comentarios':
          final comentarios = stats['comentarios'] ?? 0;
          shouldUnlock = comentarios >= (badge.criteria['valor'] as int);
          break;
        case 'peticiones_publicadas':
          final peticiones = stats['peticionesPublicadas'] ?? 0;
          shouldUnlock = peticiones >= (badge.criteria['valor'] as int);
          break;
        case 'reflexiones_publicadas':
          final reflexiones = stats['reflexionesPublicadas'] ?? 0;
          shouldUnlock = reflexiones >= (badge.criteria['valor'] as int);
          break;
        case 'dias_enfoque':
          final diasEnfoque = stats['diasEnfoque'] ?? 0;
          shouldUnlock = diasEnfoque >= (badge.criteria['valor'] as int);
          break;
        case 'siguiendo':
          final siguiendo = stats['siguiendo'] ?? 0;
          shouldUnlock = siguiendo >= (badge.criteria['valor'] as int);
          break;
        case 'seguidores':
          final seguidores = stats['seguidores'] ?? 0;
          shouldUnlock = seguidores >= (badge.criteria['valor'] as int);
          break;
        case 'fecha_especial':
          final fechaEspecial = badge.criteria['valor'] as String;
          final hoy = DateTime.now();
final hoyStr = "${hoy.year}-${hoy.month.toString().padLeft(2, "0")}-${hoy.day.toString().padLeft(2, "0")}";
          shouldUnlock = hoyStr == fechaEspecial;
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(badge.id);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      final updatedBadges = [...user.badges, ...newlyUnlocked];
      final puntosGanados = newlyUnlocked
          .map((id) => _allBadges[id]?.points ?? 0)
          .fold(0, (a, b) => a + b);
      final nuevosPuntos = user.totalPuntos + puntosGanados;
      final nuevoNivel = calculateLevel(nuevosPuntos);

      await firestore.updateUserConfig(user.id, {
        'badges': updatedBadges,
        'totalPuntos': nuevosPuntos,
        'nivel': nuevoNivel,
      });
    }

    return newlyUnlocked;
  }

  static Future<void> addPoints({
    required String userId,
    required int points,
    required FirestoreService firestore,
  }) async {
    final fs = firestore.firestore;
    if (fs == null) return;
    await fs.runTransaction((transaction) async {
      final userRef = fs.collection('usuarios').doc(userId);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentPoints = data['totalPuntos'] ?? 0;
      final newPoints = currentPoints + points;
      final newLevel = calculateLevel(newPoints);

      transaction.update(userRef, {
        'totalPuntos': newPoints,
        'nivel': newLevel,
      });
    });
  }

  static Future<List<Badge>> evaluarYNotificarBadges({
    required Usuario? user,
    required FirestoreService firestore,
    required StorageService storage,
    Map<String, dynamic>? extraStats,
  }) async {
    if (user == null) return [];

    final stats = <String, dynamic>{
      'rachaActual': storage.calcularRacha(),
      'totalCompletadas': storage.getTotalCompletadas(),
      'siguiendo': user.siguiendo.length,
      'seguidores': user.seguidores.length,
      ...?extraStats,
    };

    final unlockedIds = await checkAndAwardBadges(
      user: user,
      firestore: firestore,
      storage: storage,
      stats: stats,
    );

    final newBadges = unlockedIds
        .map((id) => _allBadges[id])
        .whereType<Badge>()
        .toList();

    if (newBadges.isNotEmpty) {
      for (final badge in newBadges) {
        await NotificationService.showNotification(
          id: badge.id.hashCode,
          title: '🎉 ¡Insignia Desbloqueada: ${badge.name}!',
          body: '${badge.icon} ${badge.description} (+${badge.points} XP)',
        );
      }
    }

    return newBadges;
  }

  static void showBadgeUnlockedDialog(
    BuildContext context,
    List<Badge> newBadges, {
    FirestoreService? firestore,
    StorageService? storage,
    Usuario? user,
  }) {
    if (newBadges.isEmpty || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _BadgeUnlockedCelebrationDialog(
        newBadges: newBadges,
        firestore: firestore ?? FirestoreService(),
        storage: storage,
        user: user,
      ),
    );
  }
}

class _BadgeUnlockedCelebrationDialog extends StatefulWidget {
  final List<Badge> newBadges;
  final FirestoreService firestore;
  final StorageService? storage;
  final Usuario? user;

  const _BadgeUnlockedCelebrationDialog({
    required this.newBadges,
    required this.firestore,
    this.storage,
    this.user,
  });

  @override
  State<_BadgeUnlockedCelebrationDialog> createState() =>
      __BadgeUnlockedCelebrationDialogState();
}

class __BadgeUnlockedCelebrationDialogState
    extends State<_BadgeUnlockedCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _compartirEnAltar(Badge badge) async {
    setState(() => _isSharing = true);
    try {
      final userName = widget.user?.nombre.isNotEmpty == true
          ? widget.user!.nombre
          : (widget.storage?.getUserName() ?? 'Hermano en Fe');
      final uid = widget.user?.id ?? 'anonimo';

      final reflexionCelebracion = Reflexion(
        id: '',
        userId: uid,
        userName: userName,
        texto:
            '🏆 ¡Gloria a Dios! Acabo de desbloquear la insignia "${badge.name}" (${badge.icon}) en AltarDiario! ${badge.description}. 🎉✨',
        pasajeDia: 'Insignia: ${badge.name}',
        fecha: DateTime.now(),
      );

      await widget.firestore.publicarReflexion(reflexionCelebracion);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 ¡Insignia compartida en el Altar Comunitario!'),
            backgroundColor: AppTheme.completedGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstBadge = widget.newBadges.first;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFDE7), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.4),
                          blurRadius: 25 * _glowAnimation.value,
                          spreadRadius: 8 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: Text(
                      firstBadge.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✨', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 4),
                  Text(
                    '¡INSIGNIA DESBLOQUEADA!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD84315),
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                firstBadge.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                firstBadge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '+${firstBadge.points} XP RECOMPENSA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing
                      ? null
                      : () => _compartirEnAltar(firstBadge),
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.campaign_rounded, color: Colors.white),
                  label: Text(
                    _isSharing
                        ? 'Compartiendo...'
                        : 'Compartir en Altar Comunitario',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '¡Excelente!',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
