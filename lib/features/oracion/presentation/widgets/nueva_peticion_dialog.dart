import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/community_policy_service.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/peticion_oracion.dart';
import '../../../../presentation/providers/app_providers.dart';

/// Diálogo para publicar una petición de oración.
///
/// Se mantiene idéntico al original: valida la política comunitaria, crea la
/// petición y evalúa las insignias al terminar.
void mostrarDialogoNuevaPeticion(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: AppTheme.primaryBlue),
          SizedBox(width: 8),
          Text('Pedir Oración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommunityPolicyService.buildPolicyBanner(context),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '¿Por qué podemos orar por ti?',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.pendingGray,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () async {
            final motivo = controller.text.trim();
            if (motivo.isEmpty) return;

            final policyCheck = CommunityPolicyService.validarContenido(motivo);
            if (!policyCheck.isApproved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(policyCheck.reason ??
                      'La petición no cumple las normas comunitarias.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            final uid = ref.read(effectiveUserUidProvider) ?? 'anonimo';
            final firestore = ref.read(firestoreServiceProvider);
            final storage = ref.read(storageProvider);
            final user = ref.read(userProfileProvider).asData?.value;
            final firebaseUser = ref.read(authServiceProvider).currentUser;

            final userName = (user?.nombre.isNotEmpty == true)
                ? user!.nombre
                : (storage.getUserName() ??
                    firebaseUser?.displayName ??
                    'Invitado');

            final nuevaPeticion = PeticionOracion(
              id: '',
              userId: uid,
              userName: userName,
              motivo: controller.text.trim(),
              fecha: DateTime.now(),
            );

            await firestore.crearPeticionOracion(nuevaPeticion);

            final newBadges = await GamificationService.evaluarYNotificarBadges(
              user: user,
              firestore: firestore,
              storage: storage,
              extraStats: {'peticionesPublicadas': 1},
            );

            if (context.mounted) {
              Navigator.pop(context);
              if (newBadges.isNotEmpty) {
                GamificationService.showBadgeUnlockedDialog(
                  context,
                  newBadges,
                  firestore: firestore,
                  storage: storage,
                  user: user,
                );
              }
            }
          },
          child: const Text('Compartir'),
        ),
      ],
    ),
  );
}
