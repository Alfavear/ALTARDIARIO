import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'public_profile_screen.dart';

class FollowersScreen extends ConsumerWidget {
  final String userId;
  final int tabIndex;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.tabIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      initialIndex: tabIndex,
      length: 2,
      child: Scaffold(
appBar: AppBar(
  backgroundColor: Colors.white,
  foregroundColor: AppTheme.textPrimary,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text('Conexiones',
      style: TextStyle(fontWeight: FontWeight.bold)),
  bottom: const TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryBlue,
            tabs: [
              Tab(text: 'Siguiendo'),
              Tab(text: 'Seguidores'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UserListTab(userId: userId, isFollowing: true),
            _UserListTab(userId: userId, isFollowing: false),
          ],
        ),
      ),
    );
  }
}

class _UserListTab extends ConsumerWidget {
  final String userId;
  final bool isFollowing;

  const _UserListTab({
    required this.userId,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = isFollowing
        ? ref.watch(siguiendoUsuariosProvider(userId))
        : ref.watch(seguidoresUsuariosProvider(userId));

    return provider.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                isFollowing
                    ? 'No sigues a nadie todavía.'
                    : 'Aún no tienes seguidores.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72, endIndent: 16),
          itemBuilder: (_, i) {
            final u = users[i];
            return ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                backgroundImage: u.fotoUrl.isNotEmpty
                    ? NetworkImage(u.fotoUrl)
                    : null,
                child: Text(u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue)),
              ),
              title: Text(u.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: u.bio.isNotEmpty
                  ? Text(u.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12))
                  : null,
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PublicProfileScreen(userId: u.id),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
