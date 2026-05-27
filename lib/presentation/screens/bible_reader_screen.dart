import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/bible_service.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
  final String pasajes;
  final String fechaClave;

  const BibleReaderScreen({
    super.key,
    required this.pasajes,
    required this.fechaClave,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final BibleService _bibleService = BibleService();
  BibleVersion _selectedVersion = BibleService.availableVersions.first;
  bool _isLoading = true;
  List<Map<String, String>> _passages = [];
  double _fontSize = 18.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _loadText() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _bibleService.getPassageText(widget.pasajes, version: _selectedVersion.id);
      setState(() {
        _passages = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar la Biblia. Verifica tu conexión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageProvider);
    final isCompleted = storageService.isDiaCompletado(widget.fechaClave);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: Text(widget.pasajes, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize >= 24 ? 16 : _fontSize + 2;
              });
            },
          ),
          PopupMenuButton<BibleVersion>(
            icon: const Icon(Icons.translate),
            onSelected: (version) {
              setState(() => _selectedVersion = version);
              _loadText();
            },
            itemBuilder: (context) => BibleService.availableVersions.map((v) {
              return PopupMenuItem(
                value: v,
                child: Text(v.name),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadText,
                        child: const Text('REINTENTAR'),
                      ),
                    ],
                  ),
                )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._passages.map((p) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_passages.length > 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  p['reference']!,
                                  style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            _buildStyledBibleText(p['text']!),
                            const SizedBox(height: 40),
                          ],
                        )),
                        if (!isCompleted)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await storageService.markDateAsCompleted(widget.fechaClave);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('¡Lectura completada! 🔥')),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('FINALIZAR LECTURA'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.completedGreen,
                                  minimumSize: const Size(240, 50),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStyledBibleText(String rawText) {
    final List<TextSpan> spans = [];
    final words = rawText.split(' ');

    for (var word in words) {
      if (RegExp(r'^\d+$').hasMatch(word)) {
        spans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: _fontSize * 0.7,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: _fontSize,
            height: 1.6,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}