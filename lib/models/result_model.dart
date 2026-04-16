import 'package:cloud_firestore/cloud_firestore.dart';

/// Record of a completed test session, stored in Firestore `/results/{resultId}`.
class ResultModel {
  const ResultModel({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.chapterId,
    required this.questionIds,
    required this.selectedAnswers,
    required this.correctAnswers,
    required this.marksObtained,
    required this.totalMarks,
    required this.timeTakenSeconds,
    required this.completedAt,
    this.mode = ResultMode.test,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String chapterId;

  /// Ordered list of question IDs attempted
  final List<String> questionIds;

  /// Map of questionId → selectedOptionIndex (null = skipped)
  final Map<String, int?> selectedAnswers;

  /// Map of questionId → correctOptionIndex
  final Map<String, int> correctAnswers;

  final int marksObtained;
  final int totalMarks;
  final int timeTakenSeconds;
  final DateTime completedAt;
  final ResultMode mode;

  // ── computed ──────────────────────────────────────────────────────────────

  int get totalQuestions => questionIds.length;

  int get correctCount => selectedAnswers.entries
      .where((e) => e.value == correctAnswers[e.key])
      .length;

  int get wrongCount => selectedAnswers.entries
      .where((e) => e.value != null && e.value != correctAnswers[e.key])
      .length;

  int get skippedCount =>
      selectedAnswers.values.where((v) => v == null).length;

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;

  double get marksPercent =>
      totalMarks == 0 ? 0 : marksObtained / totalMarks;

  // ── Firestore factory ─────────────────────────────────────────────────────

  factory ResultModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final rawSelected =
        (data['selectedAnswers'] as Map<String, dynamic>? ?? {});
    final rawCorrect =
        (data['correctAnswers'] as Map<String, dynamic>? ?? {});

    return ResultModel(
      id: doc.id,
      // FIX C4: null-safe casts — these fields should always be present but
      // a malformed or partially-written document must not crash the app.
      userId: data['userId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      chapterId: data['chapterId'] as String? ?? '',
      questionIds: List<String>.from(data['questionIds'] as List? ?? []),
      selectedAnswers: rawSelected
          .map((k, v) => MapEntry(k, v == null ? null : v as int)),
      correctAnswers: rawCorrect.map((k, v) => MapEntry(k, v as int)),
      marksObtained: (data['marksObtained'] as int?) ?? 0,
      totalMarks: (data['totalMarks'] as int?) ?? 0,
      timeTakenSeconds: (data['timeTakenSeconds'] as int?) ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      mode: ResultMode.values.firstWhere(
        (m) => m.name == (data['mode'] as String?),
        orElse: () => ResultMode.test,
      ),
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'subjectId': subjectId,
        'chapterId': chapterId,
        'questionIds': questionIds,
        'selectedAnswers': selectedAnswers,
        'correctAnswers': correctAnswers,
        'marksObtained': marksObtained,
        'totalMarks': totalMarks,
        'timeTakenSeconds': timeTakenSeconds,
        'completedAt': Timestamp.fromDate(completedAt),
        'mode': mode.name,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  ResultModel copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? chapterId,
    List<String>? questionIds,
    Map<String, int?>? selectedAnswers,
    Map<String, int>? correctAnswers,
    int? marksObtained,
    int? totalMarks,
    int? timeTakenSeconds,
    DateTime? completedAt,
    ResultMode? mode,
  }) =>
      ResultModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        subjectId: subjectId ?? this.subjectId,
        chapterId: chapterId ?? this.chapterId,
        questionIds: questionIds ?? this.questionIds,
        selectedAnswers: selectedAnswers ?? this.selectedAnswers,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        marksObtained: marksObtained ?? this.marksObtained,
        totalMarks: totalMarks ?? this.totalMarks,
        timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
        completedAt: completedAt ?? this.completedAt,
        mode: mode ?? this.mode,
      );

  @override
  String toString() =>
      'ResultModel(id: $id, score: $marksObtained/$totalMarks)';
}

enum ResultMode { practice, test }
