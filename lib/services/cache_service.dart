import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

/// Hive-backed offline cache for TutorMe content.
///
/// Strategy: "stale-while-revalidate"
///   1. Return cached data immediately for instant display
///   2. Fetch from Firestore in background
///   3. Update cache + notify UI with fresh data
class CacheService {
  static const _questionsBox = 'questionsBox';
  static const _subjectsBox = 'subjectsBox';
  static const _chaptersBox = 'chaptersBox';
  static const _userProgressBox = 'userProgressBox';

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Call once in main() after Hive.initFlutter()
  static Future<void> init() async {
    await Hive.openBox<String>(_questionsBox);
    await Hive.openBox<String>(_subjectsBox);
    await Hive.openBox<String>(_chaptersBox);
    await Hive.openBox<String>(_userProgressBox);
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  /// Cache a list of questions for a chapter (JSON serialised per item).
  Future<void> cacheQuestions(
      String chapterId, List<QuestionModel> questions) async {
    final box = Hive.box<String>(_questionsBox);
    final payload = jsonEncode(
      questions.map((q) => q.toMap()..['id'] = q.id).toList(),
    );
    await box.put(chapterId, payload);
  }

  /// Return cached questions, or null if nothing is cached.
  List<QuestionModel>? getCachedQuestions(String chapterId) {
    final box = Hive.box<String>(_questionsBox);
    final raw = box.get(chapterId);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _questionFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Subjects ─────────────────────────────────────────────────────────────

  Future<void> cacheSubjects(
      String cmaLevel, List<SubjectModel> subjects) async {
    final box = Hive.box<String>(_subjectsBox);
    final payload = jsonEncode(
      subjects.map((s) => s.toMap()..['id'] = s.id).toList(),
    );
    await box.put(cmaLevel, payload);
  }

  List<SubjectModel>? getCachedSubjects(String cmaLevel) {
    final box = Hive.box<String>(_subjectsBox);
    final raw = box.get(cmaLevel);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _subjectFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Chapters ─────────────────────────────────────────────────────────────

  Future<void> cacheChapters(
      String subjectId, List<ChapterModel> chapters) async {
    final box = Hive.box<String>(_chaptersBox);
    final payload = jsonEncode(
      chapters.map((c) => c.toMap()..['id'] = c.id).toList(),
    );
    await box.put(subjectId, payload);
  }

  List<ChapterModel>? getCachedChapters(String subjectId) {
    final box = Hive.box<String>(_chaptersBox);
    final raw = box.get(subjectId);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _chapterFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── User progress (offline) ────────────────────────────────────────────────

  Future<void> cacheUserProgress({
    required List<String> practicedQuestionIds,
    required List<String> bookmarkedQuestionIds,
  }) async {
    final box = Hive.box<String>(_userProgressBox);
    await box.put('practiced', jsonEncode(practicedQuestionIds));
    await box.put('bookmarked', jsonEncode(bookmarkedQuestionIds));
  }

  List<String> getCachedPracticed() {
    final box = Hive.box<String>(_userProgressBox);
    final raw = box.get('practiced');
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw) as List);
  }

  List<String> getCachedBookmarked() {
    final box = Hive.box<String>(_userProgressBox);
    final raw = box.get('bookmarked');
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw) as List);
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Call on logout to wipe all cached data.
  Future<void> clearCache() async {
    await Hive.box<String>(_questionsBox).clear();
    await Hive.box<String>(_subjectsBox).clear();
    await Hive.box<String>(_chaptersBox).clear();
    await Hive.box<String>(_userProgressBox).clear();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  QuestionModel _questionFromMap(Map<String, dynamic> m) => QuestionModel(
        id: m['id'] as String? ?? '',
        subjectId: m['subjectId'] as String? ?? '',
        chapterId: m['chapterId'] as String? ?? '',
        type: QuestionType.values.firstWhere(
          (t) => t.name == (m['type'] as String?),
          orElse: () => QuestionType.mcq,
        ),
        question: m['question'] as String? ?? '',
        marks: (m['marks'] as int?) ?? 1,
        year: (m['year'] as int?) ?? 0,
        session: ExamSession.values.firstWhere(
          (s) => s.name == (m['session'] as String?),
          orElse: () => ExamSession.may,
        ),
        correctAnswerIndex: (m['correctAnswerIndex'] as int?) ?? 0,
        options: List<String>.from(m['options'] as List? ?? []),
        solution: m['solution'] as String?,
        solutionSteps: List<String>.from(m['solutionSteps'] as List? ?? []),
        tags: List<String>.from(m['tags'] as List? ?? []),
        difficulty: m['difficulty'] as String?,
        imageUrls: List<String>.from(m['imageUrls'] as List? ?? []),
      );

  SubjectModel _subjectFromMap(Map<String, dynamic> m) => SubjectModel(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        code: m['code'] as String? ?? '',
        level: CmaLevel.values.firstWhere(
          (l) => l.firestoreValue == (m['level'] as String?),
          orElse: () => CmaLevel.foundation,
        ),
        description: m['description'] as String? ?? '',
        totalChapters: (m['totalChapters'] as int?) ?? 0,
        totalQuestions: (m['totalQuestions'] as int?) ?? 0,
        order: (m['order'] as int?) ?? 0,
        iconUrl: m['iconUrl'] as String?,
        colorHex: m['colorHex'] as String?,
      );

  ChapterModel _chapterFromMap(Map<String, dynamic> m) => ChapterModel(
        id: m['id'] as String? ?? '',
        subjectId: m['subjectId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        number: (m['number'] as int?) ?? 1,
        totalQuestions: (m['totalQuestions'] as int?) ?? 0,
        order: (m['order'] as int?) ?? 0,
        description: m['description'] as String?,
        topics: List<String>.from(m['topics'] as List? ?? []),
      );
}

/// Singleton instance — initialise in main(), read everywhere.
final cacheService = CacheService();
