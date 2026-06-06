import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

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
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.accentGold,
                        backgroundImage: authState.value?.photoURL != null
                            ? NetworkImage(authState.value!.photoURL!)
                            : null,
                        child: authState.value?.photoURL == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authState.value?.displayName ??
                            authState.value?.email ??
                            'Usuario Anónimo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authState.value?.isAnonymous == true)
                        const Text(
                          'Sesión anónima',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ──────────────────────────────────────────────
                  Row(
                    children: [
                      _StatCard(
                        emoji: '🔥',
                        value: '$streak',
                        label: 'Racha',
                        color: AppTheme.streakOrange,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        emoji: '🏆',
                        value: '$maxStreak',
                        label: 'Máx. racha',
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        emoji: '📖',
                        value: '$total',
                        label: 'Lecturas',
                        color: AppTheme.completedGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Barra de progreso anual ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlue),
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
                  ),
                  const SizedBox(height: 20),

                  // ── Seguidores / Siguiendo ──────────────────────────────
                  userProfile.when(
                    data: (usuario) {
                      if (usuario == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SocialStat(
                                value: '${usuario.siguiendo.length}',
                                label: 'Siguiendo'),
                            Container(
                                height: 40,
                                width: 1,
                                color: AppTheme.pendingGrayDark),
                            _SocialStat(
                                value: '${usuario.seguidores.length}',
                                label: 'Seguidores'),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ── Reflexiones del usuario ─────────────────────────────
                  const Text(
                    'Mis Reflexiones',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  (() {
                    final uid = ref.watch(effectiveUserUidProvider);
                    if (uid == null) return const SizedBox.shrink();
                    return ref
                        .watch(userReflexionesProvider(uid))
                        .when(
                            data: (reflexiones) {
                              if (reflexiones.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'Aún no has compartido reflexiones.\n¡Marca una lectura y comparte tu pensamiento!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppTheme.textSecondary),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                DateFormat('dd MMM yyyy')
                                                    .format(r.fecha),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme
                                                        .textSecondary),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.favorite,
                                                      size: 14,
                                                      color: Colors.red),
                                                  const SizedBox(width: 4),
                                                  Text('${r.likes}',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme
                                                              .textSecondary)),
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
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    );
                  })(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
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
