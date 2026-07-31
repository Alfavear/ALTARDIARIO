import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'public_profile_screen.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);
    final myUid = ref.watch(effectiveUserUidProvider);

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
        title: const Text('Leaderboard Global',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: leaderboardAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No hay usuarios en el ranking aún.\n\n¡Sé el primero en completar lecturas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              final isMe = e.userId == myUid;
              return _LeaderboardCard(
                entry: e,
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

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;

  const _LeaderboardCard({required this.entry, required this.isMe});

  String get _medalEmoji {
    if (entry.posicion == 1) return '🥇';
    if (entry.posicion == 2) return '🥈';
    if (entry.posicion == 3) return '🥉';
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
                    builder: (_) => PublicProfileScreen(userId: entry.userId),
                  ),
                );
              },
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: _medalEmoji.isNotEmpty
                  ? Text(_medalEmoji, style: const TextStyle(fontSize: 24))
                  : Text('${entry.posicion}',
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
              backgroundImage: entry.fotoUrl.isNotEmpty
                  ? NetworkImage(entry.fotoUrl)
                  : null,
              child: isMe
                  ? null
                  : Text(entry.nombre.isNotEmpty ? entry.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isMe ? 'Tú' : entry.nombre,
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
                    '${entry.totalLecturas} lecturas • Máx: ${entry.maxStreak} días',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _streakBgColor(entry.rachaActual),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.rachaActual}',
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