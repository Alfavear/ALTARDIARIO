import 'package:altar_diario/features/moderation/data/moderation_repository.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider del repositorio de moderación.
/// Construye el ModerationRepository a partir del FirestoreService global.
final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(ref.watch(firestoreServiceProvider));
});
