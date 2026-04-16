import 'package:cloud_firestore/cloud_firestore.dart';

/// A chapter within a [SubjectModel].
class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.number,
    required this.totalQuestions,
    required this.order,
    this.description,
    this.topics = const [],
  });

  final String id;
  final String subjectId;
  final String name;

  /// Chapter number (e.g., 1, 2, 3)
  final int number;
  final int totalQuestions;
  final int order;
  final String? description;

  /// List of subtopic names within this chapter
  final List<String> topics;

  // ── Firestore factory ─────────────────────────────────────────────────────

  factory ChapterModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChapterModel(
      id: doc.id,
      subjectId: data['subjectId'] as String,
      name: data['name'] as String,
      number: (data['number'] as int?) ?? 1,
      totalQuestions: (data['totalQuestions'] as int?) ?? 0,
      order: (data['order'] as int?) ?? 0,
      description: data['description'] as String?,
      topics: List<String>.from(data['topics'] as List? ?? []),
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'name': name,
        'number': number,
        'totalQuestions': totalQuestions,
        'order': order,
        'description': description,
        'topics': topics,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  ChapterModel copyWith({
    String? id,
    String? subjectId,
    String? name,
    int? number,
    int? totalQuestions,
    int? order,
    String? description,
    List<String>? topics,
  }) =>
      ChapterModel(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        number: number ?? this.number,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        order: order ?? this.order,
        description: description ?? this.description,
        topics: topics ?? this.topics,
      );

  String get displayTitle => 'Chapter $number: $name';

  @override
  String toString() => 'ChapterModel(id: $id, name: $name)';
}
