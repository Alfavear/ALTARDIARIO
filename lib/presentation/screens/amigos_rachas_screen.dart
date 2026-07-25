import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'public_profile_screen.dart';

class AmigosRachasScreen extends ConsumerWidget {
  const AmigosRachasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksAsync = ref.watch(friendStreaksProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
appBar: AppBar(
  backgroundColor: Colors.white,
  foregroundColor: AppTheme.textPrimary,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text('Rachas entre Amigos',
      style: TextStyle(fontWeight: FontWeight.bold)),
),
      body: streaksAsync.when(
        data: (streaks) {
          if (streaks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Sigue a otros usuarios para comparar rachas.\n\n'
                  '¡Entre más lecturas diarias, más arriba en la lista!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: streaks.length,
            itemBuilder: (_, i) {
              final s = streaks[i];
              final isMe = s.userId == ref.watch(effectiveUserUidProvider);
              return _StreakCard(
                rank: i + 1,
                streak: s,
                isMe: isMe,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int rank;
  final FriendStreak streak;
  final bool isMe;

  const _StreakCard({
    required this.rank,
    required this.streak,
    required this.isMe,
  });

  String get _medalEmoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: isMe
            ? Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3))
            : null,
        boxShadow: AppTheme.softShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: isMe
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PublicProfileScreen(userId: streak.userId),
                  ),
                );
              },
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: _medalEmoji.isNotEmpty
                  ? Text(_medalEmoji, style: const TextStyle(fontSize: 24))
                  : Text('$rank',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary)),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              backgroundImage: streak.fotoUrl.isNotEmpty
                  ? NetworkImage(streak.fotoUrl)
                  : null,
              child: streak.fotoUrl.isEmpty && !isMe
                  ? Text(streak.nombre.isNotEmpty
                          ? streak.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isMe ? 'Tú' : streak.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isMe
                              ? AppTheme.primaryBlue
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ERES TÚ',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${streak.totalLecturas} lecturas • Máx: ${streak.maxStreak} días',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _streakBgColor(streak.rachaActual),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${streak.rachaActual}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _streakBgColor(int racha) {
    if (racha >= 30) return const Color(0xFFE65100);
    if (racha >= 7) return AppTheme.streakOrange;
    if (racha >= 3) return const Color(0xFFFFB74D);
    return AppTheme.textSecondary.withValues(alpha: 0.5);
  }
}
