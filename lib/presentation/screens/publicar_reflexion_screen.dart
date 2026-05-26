import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/app_providers.dart';
import '../../views/reflexion.dart';
import '../../theme/app_theme.dart';

class PublicarReflexionScreen extends ConsumerStatefulWidget {
  final String pasajeDia;
  const PublicarReflexionScreen({super.key, required this.pasajeDia});

  @override
  ConsumerState<PublicarReflexionScreen> createState() => _PublicarReflexionScreenState();
}

class _PublicarReflexionScreenState extends ConsumerState<PublicarReflexionScreen> {
  final _textController = TextEditingController();
  bool _isPublishing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isPublishing = true);
    
    final user = ref.read(authStateProvider).value;
    final firestoreService = ref.read(firestoreServiceProvider);

    final nuevaReflexion = Reflexion(
      id: '', // Firestore genera el ID automáticamente
      userId: user?.uid ?? 'anonimo',
      userName: user?.displayName ?? 'Usuario de Altar',
      texto: _textController.text.trim(),
      pasajeDia: widget.pasajeDia,
      fecha: DateTime.now(),
    );

    try {
      await firestoreService.publicarReflexion(nuevaReflexion);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reflexión compartida! 🙌')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reflexión'),
        actions: [
          if (_isPublishing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
            )
          else
            TextButton(
              onPressed: _publicar,
              child: const Text('PUBLICAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre la lectura de hoy:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              widget.pasajeDia,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const Divider(height: 32),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '¿Qué te habló Dios hoy?',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}