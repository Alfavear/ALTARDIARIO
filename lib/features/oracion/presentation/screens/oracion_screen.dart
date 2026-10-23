import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/app_providers.dart';
import '../../../../presentation/widgets/guest_access_restricted_widget.dart';
import '../../../../presentation/widgets/shimmer_loading_widget.dart';
import '../widgets/nueva_peticion_dialog.dart';
import '../widgets/oracion_empty_state.dart';
import '../widgets/peticion_card.dart';

class OracionScreen extends ConsumerWidget {
  const OracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestUserProvider);

    if (isGuest) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        appBar: _buildAppBar(context),
        body: const GuestAccessRestrictedWidget(
          title: 'Compañeros de Oración Reservado',
          description:
              'Para proteger la privacidad y evitar cuentas falsas, la consulta y envío de peticiones de oración comunitarias están reservadas para miembros registrados con su cuenta de Google.',
        ),
      );
    }

    final filtro = ref.watch(peticionesFiltroProvider);
    final peticionesAsync = ref.watch(peticionesFiltradasProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: _buildAppBar(
        context,
        actions: [
          PopupMenuButton<bool?>(
            initialValue: filtro,
            tooltip: 'Filtrar peticiones',
            icon: const Icon(Icons.filter_list, color: AppTheme.textPrimary),
            onSelected: (value) =>
                ref.read(peticionesFiltroProvider.notifier).setFiltro(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todas'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Pendientes'),
              ),
              const PopupMenuItem(
                value: true,
                child: Text('Respondidas'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Icon(Icons.front_hand,
                    size: 18, color: AppTheme.primaryBlueLight),
                SizedBox(width: 6),
                Text(
                  'COMPAÑEROS DE ORACIÓN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlueLight,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: peticionesAsync.when(
              data: (peticiones) => peticiones.isEmpty
                  ? const OracionEmptyState()
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(peticionesStreamProvider.future),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: peticiones.length,
                        itemBuilder: (context, index) =>
                            PeticionCard(peticion: peticiones[index]),
                      ),
                    ),
              loading: () => const ShimmerListLoading(itemCount: 4),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => mostrarDialogoNuevaPeticion(context, ref),
        label: const Text('Pedir Oración'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, {List<Widget>? actions}) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: AppTheme.primaryBlue, size: 22),
          const SizedBox(width: 8),
          Text('AltarDiario',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppTheme.primaryBlue, fontSize: 20)),
        ],
      ),
      actions: actions,
    );
  }
}
