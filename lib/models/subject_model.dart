import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// A CMA subject (e.g., "Financial Accounting", "Cost Accounting").
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.level,
    required this.description,
    required this.totalChapters,
    required this.totalQuestions,
    required this.order,
    this.iconUrl,
    this.colorHex,
  });

  final String id;
  final String name;

  /// ICMAI subject code, e.g., "P1", "P5"
  final String code;
  final CmaLevel level;
  final String description;
  final int totalChapters;
  final int totalQuestions;
  final int order;
  final String? iconUrl;

  /// Hex color string (without #) for subject card accent colour
  final String? colorHex;

  // ── Firestore factory ─────────────────────────────────────────────────────

  factory SubjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SubjectModel(
      id: doc.id,
      name: data['name'] as String,
      code: data['code'] as String? ?? '',
      level: CmaLevel.values.firstWhere(
        (l) => l.firestoreValue == (data['level'] as String?),
        orElse: () => CmaLevel.foundation,
      ),
      description: data['description'] as String? ?? '',
      totalChapters: (data['totalChapters'] as int?) ?? 0,
      totalQuestions: (data['totalQuestions'] as int?) ?? 0,
      order: (data['order'] as int?) ?? 0,
      iconUrl: data['iconUrl'] as String?,
      colorHex: data['colorHex'] as String?,
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'name': name,
        'code': code,
        'level': level.firestoreValue,
        'description': description,
        'totalChapters': totalChapters,
        'totalQuestions': totalQuestions,
        'order': order,
        'iconUrl': iconUrl,
        'colorHex': colorHex,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    CmaLevel? level,
    String? description,
    int? totalChapters,
    int? totalQuestions,
    int? order,
    String? iconUrl,
    String? colorHex,
  }) =>
      SubjectModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        level: level ?? this.level,
        description: description ?? this.description,
        totalChapters: totalChapters ?? this.totalChapters,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        order: order ?? this.order,
        iconUrl: iconUrl ?? this.iconUrl,
        colorHex: colorHex ?? this.colorHex,
      );

  @override
  String toString() => 'SubjectModel(id: $id, name: $name)';
}
