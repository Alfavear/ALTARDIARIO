import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_dictionary_term.dart';

class BibleDictionaryService {
  static final BibleDictionaryService _instance = BibleDictionaryService._internal();
  factory BibleDictionaryService() => _instance;
  BibleDictionaryService._internal();

  List<BibleDictionaryTerm>? _cachedTerms;

  /// Carga y retorna la lista completa de términos del diccionario bíblico.
  Future<List<BibleDictionaryTerm>> getAllTerms() async {
    if (_cachedTerms != null) return _cachedTerms!;
    try {
      final jsonString =
          await rootBundle.loadString('assets/dictionary/biblical_glossary.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedTerms = jsonList
          .map((item) => BibleDictionaryTerm.fromMap(item as Map<String, dynamic>))
          .toList();
      return _cachedTerms!;
    } catch (_) {
      return [];
    }
  }

  /// Busca términos por coincidencia en palabra, significado, definición o categoría.
  Future<List<BibleDictionaryTerm>> searchTerms(String query) async {
    final all = await getAllTerms();
    if (query.trim().isEmpty) return all;

    final q = query.trim().toLowerCase();
    return all.where((term) {
      return term.palabra.toLowerCase().contains(q) ||
          term.significado.toLowerCase().contains(q) ||
          term.origen.toLowerCase().contains(q) ||
          term.categoria.toLowerCase().contains(q) ||
          term.definicion.toLowerCase().contains(q);
    }).toList();
  }

  /// Escanea un texto o versículo para encontrar qué términos del diccionario están presentes en él.
  Future<List<BibleDictionaryTerm>> findTermsInVerse(String verseText) async {
    final all = await getAllTerms();
    if (verseText.trim().isEmpty) return [];

    final textLower = verseText.toLowerCase();
    return all.where((term) {
      final wordLower = term.palabra.toLowerCase();
      // Verifica si la palabra del diccionario aparece dentro del texto del versículo
      return textLower.contains(wordLower);
    }).toList();
  }

  /// Limpia la memoria caché si fuese necesario.
  void clearCache() {
    _cachedTerms = null;
  }
}
