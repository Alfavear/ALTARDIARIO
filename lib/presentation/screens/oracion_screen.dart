import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../../data/models/peticion_oracion.dart';

class OracionScreen extends ConsumerWidget {
  const OracionScreen({super.key});

  void _abrirDialogoNuevaPeticion(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedir Oración'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '¿Por qué podemos orar por ti?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              
              final uid = ref.read(effectiveUserUidProvider) ?? 'anonimo';
              final nuevaPeticion = PeticionOracion(
                id: '',
                userId: uid,
                userName: 'Usuario de Altar',
                motivo: controller.text.trim(),
                fecha: DateTime.now(),
              );
              
              await ref.read(firestoreServiceProvider).crearPeticionOracion(nuevaPeticion);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peticionesAsync = ref.watch(peticionesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compañeros de Oración')),
      body: peticionesAsync.when(
        data: (peticiones) => peticiones.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: peticiones.length,
                itemBuilder: (context, index) => _PeticionCard(peticion: peticiones[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogoNuevaPeticion(context, ref),
        label: const Text('Pedir Oración'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: AppTheme.accentGold),
          const SizedBox(height: 16),
          Text('No hay peticiones activas.', style: TextStyle(color: AppTheme.textSecondary)),
          const Text('¡Sé el primero en pedir apoyo!'),
        ],
      ),
    );
  }
}

class _PeticionCard extends ConsumerWidget {
  final PeticionOracion peticion;
  const _PeticionCard({required this.peticion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.accentGold.withValues(alpha: 0.2),
                  child: Text(peticion.userName.isNotEmpty ? peticion.userName[0] : '?', style: const TextStyle(color: AppTheme.accentGold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(peticion.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat('dd MMM, HH:mm').format(peticion.fecha),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(peticion.motivo, style: const TextStyle(fontSize: 15, height: 1.4)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${peticion.oracionesCount} personas están orando',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(firestoreServiceProvider).apoyarPeticion(peticion.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Has dicho: ¡Amén! Orando por esto. 🙏'), duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.front_hand, size: 16, color: AppTheme.primaryBlue),
                  label: const Text('AMÉN', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}