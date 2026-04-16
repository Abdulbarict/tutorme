import 'package:cloud_firestore/cloud_firestore.dart';

/// Question type enum
enum QuestionType { mcq, descriptive, numericalMcq }

/// Exam session enum
enum ExamSession { may, november }

/// A past-paper question document stored in Firestore.
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    required this.type,
    required this.question,
    required this.marks,
    required this.year,
    required this.session,
    required this.correctAnswerIndex,
    this.options = const [],
    this.solution,
    this.solutionSteps = const [],
    this.tags = const [],
    this.difficulty,
    this.imageUrls = const [],
  });

  final String id;
  final String subjectId;
  final String chapterId;
  final QuestionType type;
  final String question;
  final int marks;
  final int year;
  final ExamSession session;

  /// 0-based index of the correct option (only for MCQ types)
  final int correctAnswerIndex;

  /// Option texts (only for MCQ types)
  final List<String> options;

  /// Full plain-text solution
  final String? solution;

  /// Step-by-step solution breakdown
  final List<String> solutionSteps;

  final List<String> tags;
  final String? difficulty; // 'easy' | 'medium' | 'hard'
  final List<String> imageUrls;

  // ── Firestore factory ─────────────────────────────────────────────────────

  factory QuestionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return QuestionModel(
      id: doc.id,
      subjectId: data['subjectId'] as String,
      chapterId: data['chapterId'] as String,
      type: QuestionType.values.firstWhere(
        (t) => t.name == (data['type'] as String?),
        orElse: () => QuestionType.mcq,
      ),
      question: data['question'] as String,
      marks: (data['marks'] as int?) ?? 1,
      year: (data['year'] as int?) ?? 0,
      session: ExamSession.values.firstWhere(
        (s) => s.name == (data['session'] as String?),
        orElse: () => ExamSession.may,
      ),
      correctAnswerIndex: (data['correctAnswerIndex'] as int?) ?? 0,
      options: List<String>.from(data['options'] as List? ?? []),
      solution: data['solution'] as String?,
      solutionSteps:
          List<String>.from(data['solutionSteps'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      difficulty: data['difficulty'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'chapterId': chapterId,
        'type': type.name,
        'question': question,
        'marks': marks,
        'year': year,
        'session': session.name,
        'correctAnswerIndex': correctAnswerIndex,
        'options': options,
        'solution': solution,
        'solutionSteps': solutionSteps,
        'tags': tags,
        'difficulty': difficulty,
        'imageUrls': imageUrls,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  QuestionModel copyWith({
    String? id,
    String? subjectId,
    String? chapterId,
    QuestionType? type,
    String? question,
    int? marks,
    int? year,
    ExamSession? session,
    int? correctAnswerIndex,
    List<String>? options,
    String? solution,
    List<String>? solutionSteps,
    List<String>? tags,
    String? difficulty,
    List<String>? imageUrls,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        chapterId: chapterId ?? this.chapterId,
        type: type ?? this.type,
        question: question ?? this.question,
        marks: marks ?? this.marks,
        year: year ?? this.year,
        session: session ?? this.session,
        correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
        options: options ?? this.options,
        solution: solution ?? this.solution,
        solutionSteps: solutionSteps ?? this.solutionSteps,
        tags: tags ?? this.tags,
        difficulty: difficulty ?? this.difficulty,
        imageUrls: imageUrls ?? this.imageUrls,
      );

  String get sessionDisplay =>
      '${session.name[0].toUpperCase()}${session.name.substring(1)} $year';

  @override
  String toString() => 'QuestionModel(id: $id, year: $year)';
}
