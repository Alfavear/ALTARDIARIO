import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final Map<String, dynamic> criteria;
  final int points;
  final DateTime createdAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.criteria,
    this.points = 10,
    required this.createdAt,
  });

  factory Badge.fromMap(Map<String, dynamic> data) {
    return Badge(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏅',
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BadgeCategory.progreso,
      ),
      rarity: BadgeRarity.values.firstWhere(
        (e) => e.name == data['rarity'],
        orElse: () => BadgeRarity.comun,
      ),
      criteria: Map<String, dynamic>.from(data['criteria'] ?? {}),
      points: data['points'] ?? 10,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'rarity': rarity.name,
      'criteria': criteria,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    BadgeCategory? category,
    BadgeRarity? rarity,
    Map<String, dynamic>? criteria,
    int? points,
    DateTime? createdAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      criteria: criteria ?? this.criteria,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum BadgeCategory {
  racha,
  progreso,
  comunidad,
  oracion,
  biblia,
  especial,
}

enum BadgeRarity {
  comun,
  raro,
  epico,
  legendario,
}

extension BadgeRarityExtension on BadgeRarity {
  Color get color {
    switch (this) {
      case BadgeRarity.comun:
        return const Color(0xFF9E9E9E);
      case BadgeRarity.raro:
        return const Color(0xFF2196F3);
      case BadgeRarity.epico:
        return const Color(0xFF9C27B0);
      case BadgeRarity.legendario:
        return const Color(0xFFFF9800);
    }
  }

  String get label {
    switch (this) {
      case BadgeRarity.comun:
        return 'Común';
      case BadgeRarity.raro:
        return 'Raro';
      case BadgeRarity.epico:
        return 'Épico';
      case BadgeRarity.legendario:
        return 'Legendario';
    }
  }
}

extension BadgeCategoryExtension on BadgeCategory {
  String get label {
    switch (this) {
      case BadgeCategory.racha:
        return 'Racha';
      case BadgeCategory.progreso:
        return 'Progreso';
      case BadgeCategory.comunidad:
        return 'Comunidad';
      case BadgeCategory.oracion:
        return 'Oración';
      case BadgeCategory.biblia:
        return 'Biblia';
      case BadgeCategory.especial:
        return 'Especial';
    }
  }
}