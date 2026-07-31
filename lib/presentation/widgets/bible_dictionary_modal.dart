import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/bible_dictionary_term.dart';
import '../../data/services/bible_dictionary_service.dart';

class BibleDictionaryModal extends StatefulWidget {
  final String? initialQuery;

  const BibleDictionaryModal({super.key, this.initialQuery});

  static Future<void> show(BuildContext context, {String? initialQuery}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BibleDictionaryModal(initialQuery: initialQuery),
    );
  }

  @override
  State<BibleDictionaryModal> createState() => _BibleDictionaryModalState();
}

class _BibleDictionaryModalState extends State<BibleDictionaryModal> {
  final _service = BibleDictionaryService();
  final _searchController = TextEditingController();
  List<BibleDictionaryTerm> _terms = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Término Hebreo',
    'Término Griego',
    'Concepto Teológico',
    'Objeto Sagrado',
    'Ser Celestial',
    'Lugar',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _loadTerms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    setState(() => _isLoading = true);
    final results = await _service.searchTerms(_searchController.text);
    if (mounted) {
      setState(() {
        _terms = results;
        _isLoading = false;
      });
    }
  }

  List<BibleDictionaryTerm> get _filteredTerms {
    if (_selectedCategory == 'Todos') return _terms;
    return _terms.where((t) => t.categoria == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Cabecera del Modal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diccionario Bíblico',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Significados, etimología en hebreo y griego',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buscador de Términos
              TextField(
                controller: _searchController,
                onChanged: (_) => _loadTerms(),
                decoration: InputDecoration(
                  hintText: 'Buscar término, palabra o concepto...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _loadTerms();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filtros por Categoría (Chips Horizontales)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: theme.cardColor,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Lista de Términos
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTerms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 48, color: AppTheme.textSecondary),
                                const SizedBox(height: 12),
                                Text(
                                  'No se encontraron términos para "${_searchController.text}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _filteredTerms.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final term = _filteredTerms[index];
                              return _buildTermCard(term, theme);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermCard(BibleDictionaryTerm term, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de Título y Categoría
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  term.palabra,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    term.categoria,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Origen Etimológico
            if (term.origen.isNotEmpty) ...[
              Text(
                term.origen,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Resumen del Significado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📌 ${term.significado}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Definición Completa
            Text(
              term.definicion,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
              ),
            ),

            // Pasajes de Referencia
            if (term.pasajes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: term.pasajes.map((pasaje) {
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    avatar: const Icon(Icons.bookmark_outline_rounded,
                        size: 14, color: AppTheme.primaryBlue),
                    label: Text(
                      pasaje,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: theme.scaffoldBackgroundColor,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
