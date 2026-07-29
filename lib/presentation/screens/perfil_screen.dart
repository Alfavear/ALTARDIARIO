import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/community_policy_service.dart';
import '../../data/models/usuario.dart';
import '../../data/models/badge.dart';
import '../providers/app_providers.dart';
import 'login_screen.dart';
import 'followers_screen.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider);
    final storageService = ref.watch(storageProvider);

    final streak = storageService.calcularRacha();
    final total = storageService.getTotalCompletadas();
    final maxStreak = storageService.getMaxStreak();
    final progreso = storageService.getProgreso();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text('AltarDiario',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white, fontSize: 20)),
              ],
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ProfileHero(
                    authState: authState,
                    userProfile: userProfile,
                    ref: ref),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsBentoGrid(
                          streak: streak,
                          total: total,
                          reflexionesCount: null),
                      const SizedBox(height: 20),
                      _LevelProgressCard(userProfile: userProfile),
                      const SizedBox(height: 20),
                      _AnnualProgressCard(
                          progreso: progreso, total: total),
                      const SizedBox(height: 20),
                      _SocialStatsSection(userProfile: userProfile),
                      const SizedBox(height: 20),
                      _AchievementsSection(
                          userProfile: userProfile,
                          streak: streak,
                          maxStreak: maxStreak,
                          total: total),
                      const SizedBox(height: 20),
                      const _ConfigSection(),
                      const SizedBox(height: 20),
                      _MenuOptions(authState: authState, ref: ref),
                      const SizedBox(height: 24),
                      _UserReflexionesSection(ref: ref),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final AsyncValue<User?> authState;
  final AsyncValue<Usuario?> userProfile;
  final WidgetRef ref;
  const _ProfileHero({
    required this.authState,
    required this.userProfile,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = userProfile.asData?.value;
    final photoUrl = (usuario?.fotoUrl.isNotEmpty == true)
        ? usuario!.fotoUrl
        : authState.value?.photoURL;
    final nombre = (usuario?.nombre.isNotEmpty == true)
        ? usuario!.nombre
        : (authState.value?.displayName ??
            authState.value?.email ??
            'Usuario Anónimo');
    final bio = usuario?.bio ?? '';

    final bool isEmoji = photoUrl != null && photoUrl.startsWith('emoji:');
    final String emojiChar = isEmoji ? photoUrl.replaceFirst('emoji:', '') : '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF004d99)],
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 48),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, ref, usuario),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty && !isEmoji
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty || isEmoji)
                      ? (isEmoji
                          ? Text(emojiChar, style: const TextStyle(fontSize: 44))
                          : const Icon(Icons.person, size: 48, color: Colors.white))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '“$bio”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            authState.value?.email ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (authState.value?.isAnonymous == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sesión anónima',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _showEditProfileDialog(
    BuildContext context, WidgetRef ref, Usuario? usuario) {
  final nombreCtrl = TextEditingController(text: usuario?.nombre ?? '');
  final bioCtrl = TextEditingController(text: usuario?.bio ?? '');
  final fotoUrlCtrl = TextEditingController(text: usuario?.fotoUrl ?? '');

  final presets = [
    'emoji:🕊️',
    'emoji:📖',
    'emoji:⭐',
    'emoji:🔥',
    'emoji:📜',
  ];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Editar Perfil'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre de usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Biografía / Frase',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: bioCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Escribe una breve biografía...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              const Text('URL de Foto o Avatar Emoji',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: fotoUrlCtrl,
                decoration: InputDecoration(
                  hintText: 'https://ejemplo.com/foto.png o emoji:🕊️',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              const Text('O elige un avatar preset:',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: presets.map((preset) {
                  final isSelected = fotoUrlCtrl.text == preset;
                  final emojiChar = preset.replaceFirst('emoji:', '');
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        fotoUrlCtrl.text = preset;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.grey[300]!,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.pendingGray,
                        child: Text(emojiChar, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = ref.read(effectiveUserUidProvider);
              if (uid != null) {
                await ref
                    .read(firestoreServiceProvider)
                    .updateUserConfig(uid, {
                  'nombre': nombreCtrl.text.trim(),
                  'bio': bioCtrl.text.trim(),
                  'fotoUrl': fotoUrlCtrl.text.trim(),
                });
                ref.invalidate(userProfileProvider);
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado correctamente ✨'),
                  backgroundColor: AppTheme.completedGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

class _StatsBentoGrid extends StatelessWidget {
  final int streak;
  final int total;
  final int? reflexionesCount;
  const _StatsBentoGrid(
      {required this.streak, required this.total, this.reflexionesCount});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          _BentoStat(
            icon: Icons.auto_stories,
            value: '$total',
            label: 'Lecturas',
            color: AppTheme.primaryBlue,
          ),
          Container(
              height: 40,
              width: 1,
              color: AppTheme.pendingGrayDark),
          _BentoStat(
            icon: Icons.local_fire_department,
            value: '$streak días',
            label: 'Racha',
            color: AppTheme.streakOrange,
          ),
          Container(
              height: 40,
              width: 1,
              color: AppTheme.pendingGrayDark),
          _BentoStat(
            icon: Icons.description,
            value: '${reflexionesCount ?? 0}',
            label: 'Reflexiones',
            color: AppTheme.completedGreen,
          ),
        ],
      ),
      ),
    );
  }
}

class _BentoStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _BentoStat(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _AnnualProgressCard extends StatelessWidget {
  final double progreso;
  final int total;
  const _AnnualProgressCard(
      {required this.progreso, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso Anual',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                '${(progreso * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 8,
              backgroundColor: AppTheme.pendingGray,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$total de 365 lecturas completadas',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SocialStatsSection extends ConsumerWidget {
  final AsyncValue<Usuario?> userProfile;
  const _SocialStatsSection({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    return userProfile.when(
      data: (usuario) {
        if (usuario == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (uid == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowersScreen(
                        userId: uid,
                        tabIndex: 0,
                      ),
                    ),
                  );
                },
                child: _SocialStat(
                    value: '${usuario.siguiendo.length}',
                    label: 'Siguiendo'),
              ),
              Container(
                  height: 40, width: 1, color: AppTheme.pendingGrayDark),
              GestureDetector(
                onTap: () {
                  if (uid == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowersScreen(
                        userId: uid,
                        tabIndex: 1,
                      ),
                    ),
                  );
                },
                child: _SocialStat(
                    value: '${usuario.seguidores.length}',
                    label: 'Seguidores'),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SocialStat extends StatelessWidget {
  final String value;
  final String label;
  const _SocialStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _LevelProgressCard extends StatelessWidget {
  final AsyncValue<Usuario?> userProfile;
  const _LevelProgressCard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final usuario = userProfile.asData?.value;
    final totalPuntos = usuario?.totalPuntos ?? 0;
    final nivel = GamificationService.calculateLevel(totalPuntos);
    final progress = GamificationService.getLevelProgress(totalPuntos, nivel);
    final nextXp = GamificationService.getXpForNextLevel(nivel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentGold, Colors.amber],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nivel $nivel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Progreso de XP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Text(
                '$totalPuntos XP',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppTheme.pendingGray,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% hacia Nivel ${nivel < 10 ? nivel + 1 : 10}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                nivel >= 10 ? '¡Nivel Máximo!' : '$totalPuntos / $nextXp XP',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final AsyncValue<Usuario?> userProfile;
  final int streak;
  final int maxStreak;
  final int total;

  const _AchievementsSection({
    required this.userProfile,
    required this.streak,
    required this.maxStreak,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = userProfile.asData?.value;
    final allBadges = GamificationService.getAllBadges();
    final unlockedIds = usuario?.badges.toSet() ?? {};

    // Si el usuario local no tiene badges cargados en Firestore pero cumple criterios locales, derivamos
    if (unlockedIds.isEmpty) {
      if (total >= 1) unlockedIds.add('primer_paso');
      if (total >= 1) unlockedIds.add('primera_reflexion');
      if (streak >= 7 || maxStreak >= 7) unlockedIds.add('semana_fiel');
      if (streak >= 30 || maxStreak >= 30) unlockedIds.add('mes_fiel');
      if (total >= 100) unlockedIds.add('cien_lecturas');
      if (total >= 365) unlockedIds.add('trescientos65');
    }

    final unlockedCount = allBadges.where((b) => unlockedIds.contains(b.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Mis Insignias',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount/${allBadges.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showAllBadgesModal(context, allBadges, unlockedIds),
              child: const Text('Ver todas', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allBadges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final badge = allBadges[i];
              final isUnlocked = unlockedIds.contains(badge.id);
              final rarityColor = _getRarityColor(badge.rarity);

              return GestureDetector(
                onTap: () => _showBadgeDetailDialog(context, badge, isUnlocked),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? rarityColor.withValues(alpha: 0.15)
                            : AppTheme.pendingGray,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked ? rarityColor : AppTheme.pendingGrayDark,
                          width: 2,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: rarityColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          isUnlocked ? badge.icon : '🔒',
                          style: TextStyle(
                            fontSize: 24,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 72,
                      child: Text(
                        badge.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                          color: isUnlocked
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.comun:
        return AppTheme.completedGreen;
      case BadgeRarity.raro:
        return AppTheme.primaryBlue;
      case BadgeRarity.epico:
        return Colors.purple;
      case BadgeRarity.legendario:
        return AppTheme.accentGold;
    }
  }
}

void _showBadgeDetailDialog(BuildContext context, Badge badge, bool isUnlocked) {
  final rarityColor = _AchievementsSection._getRarityColor(badge.rarity);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isUnlocked ? rarityColor.withValues(alpha: 0.2) : AppTheme.pendingGray,
              shape: BoxShape.circle,
              border: Border.all(color: isUnlocked ? rarityColor : AppTheme.pendingGrayDark, width: 3),
            ),
            child: Center(
              child: Text(
                isUnlocked ? badge.icon : '🔒',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(badge.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge.rarity.label.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rarityColor),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: AppTheme.accentGold, size: 18),
              const SizedBox(width: 4),
              Text('+${badge.points} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked ? '✅ Insignia Desbloqueada' : '🔒 Bloqueada',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppTheme.completedGreen : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

void _showAllBadgesModal(BuildContext context, List<Badge> allBadges, Set<String> unlockedIds) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Colección de Insignias',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${unlockedIds.length}/${allBadges.length} Desbloqueadas',
                      style: const TextStyle(fontSize: 13, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: allBadges.length,
              itemBuilder: (ctx, i) {
                final badge = allBadges[i];
                final isUnlocked = unlockedIds.contains(badge.id);
                final rarityColor = _AchievementsSection._getRarityColor(badge.rarity);

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isUnlocked ? rarityColor.withValues(alpha: 0.5) : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isUnlocked ? rarityColor.withValues(alpha: 0.15) : AppTheme.pendingGray,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(isUnlocked ? badge.icon : '🔒', style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    title: Text(
                      badge.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                    ),
                    subtitle: Text(badge.description, style: const TextStyle(fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${badge.points} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge.rarity.label,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: rarityColor),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showBadgeDetailDialog(context, badge, isUnlocked),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ConfigSection extends ConsumerWidget {
  const _ConfigSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(focusModeProvider);
    final storage = ref.watch(storageProvider);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text('Configuración',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: Icon(
              focusMode ? Icons.lock : Icons.lock_open_rounded,
              color: focusMode ? AppTheme.streakOrange : AppTheme.textSecondary,
            ),
            title: Text(
              focusMode ? 'Modo Enfoque activo' : 'Modo Enfoque',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              focusMode
                  ? 'Notificaciones bloqueadas'
                  : 'Sin distracciones hasta completar tu lectura',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            value: focusMode,
            activeThumbColor: AppTheme.streakOrange,
            onChanged: (_) {
              ref.read(focusModeProvider.notifier).toggle();
            },
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: AppTheme.primaryBlue),
            title: const Text('Recordatorio diario',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(
              '${storage.getNotificationHour().toString().padLeft(2, '0')}:${storage.getNotificationMinute().toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            trailing: TextButton(
              onPressed: () => _pickNotificationTime(context, ref),
              child: const Text('CAMBIAR'),
            ),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.shield_outlined,
                color: AppTheme.primaryBlue),
            title: const Text('Normas de la Comunidad',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: const Text(
                'Uso edificado, prohibido pedir dinero o vulgaridad',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
            onTap: () =>
                CommunityPolicyService.showCommunityRulesDialog(context),
          ),
        ],
      ),
    ),
  );
 }
}

Future<void> _pickNotificationTime(
    BuildContext context, WidgetRef ref) async {
  final storage = ref.read(storageProvider);
  final firestore = ref.read(firestoreServiceProvider);
  final uid = ref.read(effectiveUserUidProvider);
  final initial = TimeOfDay(
    hour: storage.getNotificationHour(),
    minute: storage.getNotificationMinute(),
  );
  final picked = await showTimePicker(context: context, initialTime: initial);
  if (picked != null) {
    await storage.setNotificationTime(picked.hour, picked.minute);
    if (uid != null) {
      await firestore.updateUserConfig(uid, {
        'notifHour': picked.hour,
        'notifMin': picked.minute,
      });
    }
    await NotificationService.scheduleDailyReminder(
      hour: picked.hour,
      minute: picked.minute,
    );
  }
}

void _showSettingsModalSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings, color: AppTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Ajustes y Configuración',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final focusMode = ref.watch(focusModeProvider);
                  final storage = ref.watch(storageProvider);
                  final hour = storage.getNotificationHour().toString().padLeft(2, '0');
                  final min = storage.getNotificationMinute().toString().padLeft(2, '0');

                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'NOTIFICACIONES Y ENFOQUE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        color: AppTheme.scaffoldBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: Icon(
                                focusMode ? Icons.lock : Icons.lock_open_rounded,
                                color: focusMode ? AppTheme.streakOrange : AppTheme.textSecondary,
                              ),
                              title: const Text(
                                'Modo Enfoque',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                focusMode
                                    ? 'Bloquea distracciones durante la lectura'
                                    : 'Desactivado',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              value: focusMode,
                              activeThumbColor: AppTheme.streakOrange,
                              onChanged: (_) {
                                ref.read(focusModeProvider.notifier).toggle();
                              },
                            ),
                            const Divider(height: 1, indent: 56),
                            ListTile(
                              leading: const Icon(Icons.alarm, color: AppTheme.primaryBlue),
                              title: const Text(
                                'Recordatorio Diario',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text('Programado a las $hour:$min h'),
                              trailing: TextButton(
                                onPressed: () => _pickNotificationTime(context, ref),
                                child: const Text('CAMBIAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'COMUNIDAD Y PRIVACIDAD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        color: AppTheme.scaffoldBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.gavel, color: AppTheme.primaryBlue),
                          title: const Text(
                            'Normas y Políticas de la Comunidad',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: const Text('Uso respetuoso, prohibido spam o vulgaridad'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            CommunityPolicyService.showCommunityRulesDialog(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'DATOS Y ALMACENAMIENTO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        color: AppTheme.scaffoldBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.red),
                          title: const Text(
                            'Reiniciar progreso local',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red),
                          ),
                          subtitle: const Text('Elimina las lecturas guardadas en este dispositivo'),
                          trailing: const Icon(Icons.chevron_right, color: Colors.red),
                          onTap: () {
                            _showClearDataDialog(context, ref);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, color: AppTheme.primaryBlue, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'AltarDiario v1.0.0 Pro',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tu hábito diario con Dios • 2026',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showClearDataDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Reiniciar progreso local'),
        ],
      ),
      content: const Text(
        '¿Estás seguro de que deseas reiniciar tu progreso de lecturas y racha en este dispositivo? Tus publicaciones e insignias en la nube no se borrarán.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            final storage = ref.read(storageProvider);
            await storage.clearLocalProgress();
            ref.invalidate(storageProvider);
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Progreso local reiniciado correctamente ✨'),
                backgroundColor: AppTheme.completedGreen,
              ),
            );
          },
          child: const Text('Reiniciar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _showFeedbackDialog(BuildContext context, WidgetRef ref) {
  final mensajeCtrl = TextEditingController();
  int calificacion = 0;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.feedback_outlined, color: AppTheme.primaryBlue),
            SizedBox(width: 10),
            Text('Tu opinión'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué te parece AltarDiario? '
                'Tus comentarios nos ayudan a mejorar.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(
                      star <= calificacion
                          ? Icons.star
                          : Icons.star_border,
                      color: AppTheme.accentGold,
                      size: 36,
                    ),
                    onPressed: () => setDialogState(() => calificacion = star),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: mensajeCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu opinión aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.scaffoldBg,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (mensajeCtrl.text.trim().isEmpty) return;
              final uid = ref.read(effectiveUserUidProvider);
              final userProfile = ref.read(userProfileProvider).asData?.value;
              await ref.read(firestoreServiceProvider).sendFeedback(
                userId: uid ?? 'anonimo',
                userName: userProfile?.nombre ?? 'Anónimo',
                mensaje: mensajeCtrl.text.trim(),
                calificacion: calificacion,
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gracias por tu opinión 🙏'),
                  backgroundColor: AppTheme.completedGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    ),
  );
}

void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Privacidad'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus datos de lectura, notas y reflexiones se almacenan de forma segura en Firebase y localmente en tu dispositivo.',
            style: TextStyle(height: 1.4),
          ),
          SizedBox(height: 12),
          Text(
            'No compartimos tu información personal con terceros. Puedes eliminar tu cuenta y datos en cualquier momento.',
            style: TextStyle(height: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

class _MenuOptions extends ConsumerWidget {
  final AsyncValue<User?> authState;
  final WidgetRef ref;
  const _MenuOptions({required this.authState, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.settings,
            label: 'Configuración y Ajustes',
            onTap: () => _showSettingsModalSheet(context, ref),
          ),
          const Divider(height: 1, indent: 56, color: AppTheme.pendingGrayDark),
          _MenuTile(
            icon: Icons.notifications,
            label: 'Notificaciones',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('2',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            onTap: () {
              _pickNotificationTime(context, ref);
            },
          ),
          const Divider(height: 1, indent: 56, color: AppTheme.pendingGrayDark),
          _MenuTile(
            icon: Icons.lock_person,
            label: 'Privacidad',
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(height: 1, indent: 56, color: AppTheme.pendingGrayDark),
          _MenuTile(
            icon: Icons.feedback_outlined,
            label: 'Enviar opinión',
            onTap: () => _showFeedbackDialog(context, ref),
          ),
          const Divider(height: 1, indent: 56, color: AppTheme.pendingGrayDark),
          _MenuTile(
            icon: Icons.logout,
            label: 'Cerrar Sesión',
            color: AppTheme.completedGreen,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cerrar Sesión',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await ref.read(authServiceProvider).signOut();
              await ref.read(authServiceProvider).clearLocalUid();
              ref.read(localUidProvider.notifier).setUid(null);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon,
                color: color ?? AppTheme.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: color ?? AppTheme.textPrimary,
                  fontWeight: color != null ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right,
                color: color ?? AppTheme.pendingGrayDark, size: 20),
          ],
        ),
      ),
    );
  }
}

class _UserReflexionesSection extends ConsumerWidget {
  final WidgetRef ref;
  const _UserReflexionesSection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    if (uid == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis Reflexiones',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ref.watch(userReflexionesProvider(uid)).when(
          data: (reflexiones) {
            if (reflexiones.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aún no has compartido reflexiones.\n¡Marca una lectura y comparte tu pensamiento!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reflexiones.length,
              itemBuilder: (context, i) {
                final r = reflexiones[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.pasajeDia,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(r.texto,
                            style: const TextStyle(
                                fontSize: 14, height: 1.4)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(r.fecha),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.favorite,
                                    size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('${r.likes}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No se pudieron cargar tus reflexiones.\nVerifica que Firebase Console tenga los índices necesarios.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
