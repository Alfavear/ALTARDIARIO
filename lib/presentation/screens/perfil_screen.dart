import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/usuario.dart';
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
                _ProfileHero(authState: authState),
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
                      _AnnualProgressCard(
                          progreso: progreso, total: total),
                      const SizedBox(height: 20),
                      _SocialStatsSection(userProfile: userProfile),
                      const SizedBox(height: 20),
                      _AchievementsSection(
                          streak: streak, maxStreak: maxStreak, total: total),
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
  const _ProfileHero({required this.authState});

  @override
  Widget build(BuildContext context) {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: authState.value?.photoURL != null
                    ? NetworkImage(authState.value!.photoURL!)
                    : null,
                child: authState.value?.photoURL == null
                    ? const Icon(Icons.person,
                        size: 48, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            authState.value?.displayName ??
                authState.value?.email ??
                'Usuario Anónimo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authState.value?.email ?? '',
            style: const TextStyle(
                color: Colors.white70, fontSize: 13),
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

class _AchievementsSection extends StatelessWidget {
  final int streak;
  final int maxStreak;
  final int total;
  const _AchievementsSection(
      {required this.streak, required this.maxStreak, required this.total});

  @override
  Widget build(BuildContext context) {
    final logros = <_Logro>[
      _Logro(
        icon: Icons.workspace_premium,
        label: 'Primeros 7 días',
        color: AppTheme.streakOrangeLight,
        unlocked: streak >= 7 || maxStreak >= 7,
        iconColor: AppTheme.streakOrange,
      ),
      _Logro(
        icon: Icons.star,
        label: 'Lector Fiel',
        color: AppTheme.primaryBlueLight,
        unlocked: total >= 30,
        iconColor: AppTheme.primaryBlue,
      ),
      _Logro(
        icon: Icons.eco,
        label: 'Reflector',
        color: AppTheme.completedGreenLight,
        unlocked: total >= 1,
        iconColor: AppTheme.completedGreen,
      ),
      _Logro(
        icon: Icons.lock,
        label: '30 días',
        color: AppTheme.pendingGray,
        unlocked: streak >= 30 || maxStreak >= 30,
        iconColor: AppTheme.pendingGrayDark,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mis Logros',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos',
                  style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: logros.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final l = logros[i];
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: l.unlocked
                          ? l.color.withValues(alpha: 0.2)
                          : AppTheme.pendingGray,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: l.unlocked
                            ? l.color
                            : AppTheme.pendingGrayDark,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      l.icon,
                      color: l.unlocked ? l.iconColor : AppTheme.textSecondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      l.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: l.unlocked
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Logro {
  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;
  final Color iconColor;
  const _Logro({
    required this.icon,
    required this.label,
    required this.color,
    required this.unlocked,
    required this.iconColor,
  });
}

class _ConfigSection extends ConsumerWidget {
  const _ConfigSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(focusModeProvider);
    final storage = ref.watch(storageProvider);

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
        ],
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

void _showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Configuración'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Text('AltarDiario v1.0.0',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showClearDataDialog(context);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Borrar datos locales'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
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

void _showClearDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Borrar datos locales'),
      content: const Text(
        '¿Estás seguro? Se eliminará tu progreso de lectura, notas y datos locales. Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Función disponible próximamente')),
            );
          },
          child: const Text('Borrar', style: TextStyle(color: Colors.red)),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.settings,
            label: 'Configuración',
            onTap: () => _showSettingsDialog(context),
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
