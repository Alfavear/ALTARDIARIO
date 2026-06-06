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
      final translations = await _downloadService.fetchAvailableTranslations();
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

  List<AvailableTranslation> get _filtered {
    if (_search.isEmpty) return _translations;
    final q = _search.toLowerCase();
    return _translations.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.language.toLowerCase().contains(q) ||
          t.slug.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('Versiones de la Biblia'),
        actions: [
          if (_error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar las traducciones.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar versión...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final t = filtered[index];
              return _buildTile(t);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTile(AvailableTranslation t) {
    final slug = t.slug;
    final isDownloading = _downloading.contains(slug);
    final progress = _progress[slug] ?? 0.0;

    return ListTile(
      title: Text(t.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${t.language} · ${t.slug}${t.isDownloaded ? ' · Descargada' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isDownloading
          ? SizedBox(
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
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : t.isDownloaded
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _delete(t),
                  tooltip: 'Eliminar',
                )
              : IconButton(
                  icon: const Icon(Icons.download, color: AppTheme.primaryBlue),
                  onPressed: () => _download(t),
                  tooltip: 'Descargar',
                ),
    );
  }
}
