import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/debate.dart';
import '../../data/services/bible_service.dart';
import '../providers/app_providers.dart';

class CrearDebateScreen extends ConsumerStatefulWidget {
  const CrearDebateScreen({super.key});

  @override
  ConsumerState<CrearDebateScreen> createState() => _CrearDebateScreenState();
}

class _CrearDebateScreenState extends ConsumerState<CrearDebateScreen> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String? _selectedLibro;
  final _bibleService = BibleService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final titulo = _tituloCtrl.text.trim();
    final contenido = _contenidoCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final uid = ref.read(effectiveUserUidProvider);
      final user = ref.read(userProfileProvider).value;
      if (uid == null) return;
      final debate = Debate(
        id: '',
        titulo: titulo,
        contenido: contenido,
        userId: uid,
        userName: user?.nombre ?? 'Anónimo',
        libroId: _bibleService.getBookIdFromName(_selectedLibro ?? '').toString(),
        libroNombre: _selectedLibro ?? '',
        fecha: DateTime.now(),
      );
      await ref.read(firestoreServiceProvider).crearDebate(debate);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Nuevo Debate',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('PUBLICAR',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título del debate',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloCtrl,
              decoration: InputDecoration(
                hintText: 'Ej: ¿Qué significa la fe en Hebreos 11?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.pendingGrayDark),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            const Text('Libro bíblico relacionado (opcional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.pendingGrayDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Seleccionar libro...'),
                  value: _selectedLibro,
                  items: _bibleService
                      .getBookNames()
                      .map((l) => DropdownMenuItem(
                          value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedLibro = v),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Contenido (opcional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _contenidoCtrl,
              decoration: InputDecoration(
                hintText:
                    'Desarrolla tu idea, pregunta o reflexión...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.pendingGrayDark),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 6,
              maxLength: 2000,
            ),
          ],
        ),
      ),
    );
  }
}
