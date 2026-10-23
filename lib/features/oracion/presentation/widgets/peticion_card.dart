import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/peticion_oracion.dart';
import '../../../../presentation/providers/app_providers.dart';
import '../../../moderation/presentation/report_content_dialog.dart';

class PeticionCard extends ConsumerWidget {
  final PeticionOracion peticion;
  const PeticionCard({super.key, required this.peticion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorProfile =
        ref.watch(userProfileByIdProvider(peticion.userId)).value;
    final authorName = (authorProfile?.nombre.isNotEmpty == true)
        ? authorProfile!.displayName
        : peticion.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
        border:
            Border.all(color: AppTheme.pendingGrayDark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppTheme.accentGold, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.primaryBlue)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(peticion.fecha),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.pendingGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              peticion.motivo,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${peticion.oracionesCount} orando',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ReportContentDialog(
                      targetType: 'peticion',
                      targetId: peticion.id,
                      targetTitle: peticion.motivo.length > 50
                          ? '${peticion.motivo.substring(0, 50)}...'
                          : peticion.motivo,
                      targetAuthor: authorName,
                    ),
                  );
                },
                icon: const Icon(Icons.flag_outlined,
                    size: 20, color: Colors.grey),
                tooltip: 'Reportar',
              ),
              const SizedBox(width: 8),
              // Botón "Marcar como respondida" solo para el autor y si no está respondida
              if (!peticion.respondida)
                _buildMarcarRespondidaButton(ref, context, peticion),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(firestoreServiceProvider)
                      .apoyarPeticion(peticion.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Has dicho: ¡Amén! 🙏'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.front_hand, size: 16, color: Colors.white),
                label: const Text('AMÉN',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para construir el botón "Marcar como respondida"
  Widget _buildMarcarRespondidaButton(
      WidgetRef ref, BuildContext context, PeticionOracion peticion) {
    final currentUid = ref.read(effectiveUserUidProvider);
    final isAutor = currentUid == peticion.userId;

    if (!isAutor) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Marcar como respondida'),
            content: const Text('¿Marcar esta petición como respondida?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Marcar'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await ref
                .read(firestoreServiceProvider)
                .marcarPeticionComoRespondida(
                  peticion.id,
                  ref.read(effectiveUserUidProvider)!,
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Petición marcada como respondida ✨')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
      },
      icon: const Icon(Icons.check_circle_outline,
          size: 18, color: AppTheme.accentGold),
      label: const Text('Respondida', style: TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accentGold,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
