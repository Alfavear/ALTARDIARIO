import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../../data/models/reflexion.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/community_policy_service.dart';
import '../../data/services/bible_service.dart';

class PublicarReflexionScreen extends ConsumerStatefulWidget {
  final String pasajeDia;
  const PublicarReflexionScreen({super.key, required this.pasajeDia});

  @override
  ConsumerState<PublicarReflexionScreen> createState() =>
      _PublicarReflexionScreenState();
}

class _PublicarReflexionScreenState
    extends ConsumerState<PublicarReflexionScreen> {
  final _textController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isPublishing = false;
  bool _showPassage = true;
  String? _previewVerseText;
  bool _loadingVerse = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.pasajeDia;
    _fetchVersePreview();
  }

  Future<void> _fetchVersePreview([String? customPasaje]) async {
    final pasaje = (customPasaje ?? _titleController.text).trim();
    if (pasaje.isEmpty) {
      if (mounted) setState(() => _loadingVerse = false);
      return;
    }
    setState(() => _loadingVerse = true);
    try {
      final bibleService = BibleService();
      final pasajes = await bibleService.getPassageText(pasaje);
      BibleVerse? foundVerse;
      for (final p in pasajes) {
        if (p.verses.isNotEmpty) {
          foundVerse = p.verses.first;
          break;
        }
      }
      if (mounted) {
        setState(() {
          if (foundVerse != null) {
            _previewVerseText =
                '"${foundVerse.text}" — ${foundVerse.bookName} ${foundVerse.chapter}:${foundVerse.verse}';
          } else {
            _previewVerseText = null;
          }
          _loadingVerse = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _previewVerseText = null;
          _loadingVerse = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    final policyCheck = CommunityPolicyService.validarContenido(texto);
    if (!policyCheck.isApproved) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Normas Comunitaria',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
                policyCheck.reason ??
                    'El contenido no cumple las normas de edificación comunitaria.',
                style: const TextStyle(fontSize: 13, height: 1.4)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() => _isPublishing = true);

    final uid = ref.read(effectiveUserUidProvider) ?? 'anonimo';
    final firestoreService = ref.read(firestoreServiceProvider);
    final userProfile = ref.read(userProfileProvider).asData?.value;
    final storage = ref.read(storageProvider);
    final firebaseUser = ref.read(authServiceProvider).currentUser;
    final userName = (userProfile?.nombre.isNotEmpty == true)
        ? userProfile!.nombre
        : (storage.getUserName() ?? firebaseUser?.displayName ?? 'Invitado');

    final nuevaReflexion = Reflexion(
      id: '',
      userId: uid,
      userName: userName,
      texto: _textController.text.trim(),
      pasajeDia: _titleController.text.trim(),
      fecha: DateTime.now(),
    );

    try {
      await firestoreService.publicarReflexion(nuevaReflexion);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await storage.markDateAsCompleted(todayStr);
      final completed = storage.getCompletedDatesSync();
      final maxStreak = storage.getMaxStreak();
      if (uid != 'anonimo') {
        await firestoreService.syncProgress(uid, completed, maxStreak);
      }
      final user = ref.read(userProfileProvider).asData?.value;
      final newBadges = await GamificationService.evaluarYNotificarBadges(
        user: user,
        firestore: firestoreService,
        storage: storage,
        extraStats: {'reflexionesPublicadas': 1},
      );

      if (mounted) {
        if (newBadges.isNotEmpty) {
          GamificationService.showBadgeUnlockedDialog(
            context,
            newBadges,
            firestore: firestoreService,
            storage: storage,
            user: user,
          );
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reflexión compartida!')),
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
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
        actions: [
          if (_isPublishing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryBlue)),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: _publicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
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
                CommunityPolicyService.buildPolicyBanner(context),
                Row(
                  children: [
                    const Icon(Icons.edit_note,
                        size: 18, color: AppTheme.primaryBlueLight),
                    const SizedBox(width: 6),
                    Text(
                      'Nueva Reflexión',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlueLight,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Referencia bíblica (ej. Salmos 23:1)',
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
                Divider(
                    color: AppTheme.primaryBlueLight.withValues(alpha: 0.3),
                    thickness: 1),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: null,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu reflexión aquí...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppTheme.pendingGrayDark),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_showPassage)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.pendingGray,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color:
                              AppTheme.pendingGrayDark.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories,
                                size: 16, color: AppTheme.primaryBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _titleController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showPassage = false),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.completedGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_loadingVerse)
                          const SizedBox(
                            height: 24,
                            child: Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          )
                        else if (_previewVerseText != null)
                          Text(
                            _previewVerseText!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _buildFloatingToolbar(),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.mediumShadow,
        border: Border.all(
            color: AppTheme.pendingGrayDark.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPassage = !_showPassage),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _showPassage
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories,
                      size: 18,
                      color: _showPassage
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('Pasaje',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _showPassage
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
