import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/bible_download_service.dart';

class BibleVersionsScreen extends ConsumerStatefulWidget {
  const BibleVersionsScreen({super.key});

  @override
  ConsumerState<BibleVersionsScreen> createState() =>
      _BibleVersionsScreenState();
}

class _BibleVersionsScreenState extends ConsumerState<BibleVersionsScreen> {
  final BibleDownloadService _downloadService = BibleDownloadService();
  List<AvailableTranslation> _translations = [];
  Set<String> _downloading = {};
  Map<String, double> _progress = {};
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _downloadService.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final translations =
          await _downloadService.fetchAvailableTranslations();
      if (!mounted) return;
      setState(() {
        _translations = translations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _download(AvailableTranslation t) async {
    final slug = t.slug;
    setState(() {
      _downloading = {..._downloading, slug};
      _progress = {..._progress, slug: 0};
    });
    try {
      await _downloadService.downloadVersion(
        slug,
        onProgress: (current, total) {
          if (!mounted) return;
          setState(() {
            _progress = {..._progress, slug: current / total};
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _translations = _translations.map((tr) {
          if (tr.slug == slug) {
            return AvailableTranslation(
              slug: tr.slug,
              name: tr.name,
              language: tr.language,
              isDownloaded: true,
            );
          }
          return tr;
        }).toList();
        _downloading = _downloading.where((s) => s != slug).toSet();
        _progress = {..._progress}..remove(slug);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.name} descargada')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = _downloading.where((s) => s != slug).toSet();
        _progress = {..._progress}..remove(slug);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _delete(AvailableTranslation t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar versión'),
        content: Text('¿Eliminar "${t.name}" del dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _downloadService.deleteVersion(t.slug);
      if (!mounted) return;
      setState(() {
        _translations = _translations.map((tr) {
          if (tr.slug == t.slug) {
            return AvailableTranslation(
              slug: tr.slug,
              name: tr.name,
              language: tr.language,
              isDownloaded: false,
            );
          }
          return tr;
        }).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.name} eliminada')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  String _selectedLangFilter = 'todos';

  String _getLanguageBadge(String lang) {
    final lower = lang.toLowerCase();
    if (lower.contains('spanish') || lower.contains('español') || lower == 'es') {
      return '🇪🇸 Español';
    } else if (lower.contains('english') || lower.contains('inglés') || lower == 'en') {
      return '🇺🇸 English';
    } else if (lower.contains('portuguese') || lower.contains('portugués') || lower == 'pt') {
      return '🇧🇷 Português';
    } else if (lower.contains('french') || lower.contains('francés') || lower == 'fr') {
      return '🇫🇷 Français';
    } else if (lower.contains('german') || lower.contains('alemán') || lower == 'de') {
      return '🇩🇪 Deutsch';
    } else if (lower.contains('italian') || lower.contains('italiano') || lower == 'it') {
      return '🇮🇹 Italiano';
    }
    return '🌐 $lang';
  }

  List<AvailableTranslation> get _filtered {
    var list = _translations;

    if (_selectedLangFilter == 'instaladas') {
      list = list.where((t) => t.isDownloaded || _downloading.contains(t.slug)).toList();
    } else if (_selectedLangFilter == 'es') {
      list = list.where((t) {
        final l = t.language.toLowerCase();
        return l.contains('spanish') || l.contains('español') || l == 'es';
      }).toList();
    } else if (_selectedLangFilter == 'en') {
      list = list.where((t) {
        final l = t.language.toLowerCase();
        return l.contains('english') || l.contains('inglés') || l == 'en';
      }).toList();
    } else if (_selectedLangFilter == 'otros') {
      list = list.where((t) {
        final l = t.language.toLowerCase();
        return !l.contains('spanish') && !l.contains('español') && l != 'es' &&
            !l.contains('english') && !l.contains('inglés') && l != 'en';
      }).toList();
    }

    if (_search.isEmpty) return list;
    final q = _search.toLowerCase();
    return list.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.language.toLowerCase().contains(q) ||
          t.slug.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featured =
        _filtered.where((t) => t.isDownloaded || _downloading.contains(t.slug)).toList();
    final others =
        _filtered.where((t) => !featured.contains(t)).toList();

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Versiones de la Biblia',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        actions: const [],
      ),
      body: _buildBody(featured, others),
    );
  }

  Widget _buildLanguageFilterChips() {
    final filters = [
      {'id': 'todos', 'label': '🌐 Todos'},
      {'id': 'es', 'label': '🇪🇸 Español'},
      {'id': 'en', 'label': '🇺🇸 English'},
      {'id': 'instaladas', 'label': '🌟 Instaladas'},
      {'id': 'otros', 'label': '🌎 Otros Idiomas'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedLangFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryBlue,
              backgroundColor: Colors.white,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedLangFilter = f['id']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(
      List<AvailableTranslation> featured, List<AvailableTranslation> others) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryBlue),
            SizedBox(height: 16),
            Text('Cargando traducciones disponibles...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off,
                  size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('No se pudieron cargar las traducciones.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildLanguageFilterChips(),
        const SizedBox(height: 20),
        if (featured.isNotEmpty) ...[
          const Text('Instaladas (Offline)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          ...featured.map((t) => _buildFeaturedCard(t)),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Traducciones Disponibles',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text(
              '${others.length} disponibles',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...others.map((t) => _buildTranslationItem(t)),
        const SizedBox(height: 24),
        _buildOfflineTip(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.pendingGrayDark),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.search,
              size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Buscar traducciones (ej. Reina Valera)',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.tune,
              size: 18, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(AvailableTranslation t) {
    final slug = t.slug;
    final isDownloading = _downloading.contains(slug);
    final progress = _progress[slug] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.pendingGrayDark.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories,
                    color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    Text(_getLanguageBadge(t.language),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (isDownloading)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        color: AppTheme.primaryBlue,
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.completedGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Instalado',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.completedGreen)),
                ),
            ],
          ),
          if (isDownloading) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                color: AppTheme.completedGreen,
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationItem(AvailableTranslation t) {
    final slug = t.slug;
    final isDownloading = _downloading.contains(slug);
    final progress = _progress[slug] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.translate,
              size: 22, color: AppTheme.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                Text(_getLanguageBadge(t.language),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (isDownloading)
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    color: AppTheme.primaryBlue,
                  ),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else if (t.isDownloaded)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.textSecondary, size: 20),
              onPressed: () => _delete(t),
            )
          else
            GestureDetector(
              onTap: () => _download(t),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.pendingGrayDark),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    const Text('Descargar',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlueLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primaryBlueLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info,
              size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lectura Offline',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.primaryBlue)),
                const SizedBox(height: 4),
                const Text(
                  'Descarga tus versiones favoritas para leer la Palabra de Dios incluso sin conexión.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
