import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/note.dart';
import '../providers/app_providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? existingNote;
  final String? prefilledTitle;

  const NoteEditorScreen({super.key, this.existingNote, this.prefilledTitle});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
        text: widget.existingNote?.title ?? widget.prefilledTitle ?? '');
    _contentCtrl =
        TextEditingController(text: widget.existingNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final note = Note(
      id: widget.existingNote?.id ?? 'note-${now.microsecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      createdAt: widget.existingNote?.createdAt ?? now,
      updatedAt: now,
    );
    final storage = ref.read(storageProvider);
    await storage.saveNote(note);
    final uid = ref.read(effectiveUserUidProvider);
    if (uid != null) {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.syncNote(uid, note);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AltarDiario',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Descartar',
                style: TextStyle(color: Colors.white70)),
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 1,
                ),
                child: const Text('Guardar',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppTheme.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reflexión Diaria',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary)),
                        Text(
                          DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Título de tu reflexión...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppTheme.pendingGrayDark),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildToolbar(),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  autofocus: widget.existingNote == null,
                  decoration: const InputDecoration(
                    hintText: 'Comienza a escribir aquí...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppTheme.pendingGrayDark),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTagsSection(),
                const SizedBox(height: 16),
                _buildInspirationCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return const SizedBox.shrink();
  }

  Widget _buildTagsSection() {
    final tags = ['#Gratitud', '#Paz'];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Etiquetas:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary)),
        ...tags.map((t) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue)),
                  const SizedBox(width: 4),
                  const Icon(Icons.close,
                      size: 14, color: AppTheme.primaryBlue),
                ],
              ),
            )),
        const Icon(Icons.add_circle,
            size: 20, color: AppTheme.primaryBlue),
      ],
    );
  }

  Widget _buildInspirationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.completedGreenLight,
            AppTheme.completedGreenLight.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates,
                        size: 16, color: AppTheme.completedGreen),
                    const SizedBox(width: 6),
                    const Text('Sugerencia de escritura',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.completedGreen)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '¿Qué es aquello por lo que te sientes más agradecido en este preciso instante?',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              final text = _contentCtrl.text;
              final suggestion = '"Jehová es mi pastor; nada me faltará." — Salmos 23:1';
              _contentCtrl.text = text.isNotEmpty ? '$text\n\n$suggestion' : suggestion;
              _contentCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _contentCtrl.text.length),
              );
            },
            child: const Text('Usar',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.completedGreen)),
          ),
        ],
      ),
    );
  }
}
