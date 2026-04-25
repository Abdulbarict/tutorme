import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';
import 'auth_service.dart';

part 'firestore_service.g.dart';

/// Low-level Firestore repository for TutorMe content.
///
/// All methods that return lists use ordered queries and decode via
/// the model's [fromFirestore] factory, keeping the rest of the app
/// free from Firestore imports.
class FirestoreService {
  FirestoreService(this._db, this._uid);

  final FirebaseFirestore _db;
  final String? _uid;

  // ── Firestore collection paths ────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _subjects =>
      _db.collection('subjects');

  CollectionReference<Map<String, dynamic>> _chapters(String subjectId) =>
      _db.collection('subjects').doc(subjectId).collection('chapters');

  CollectionReference<Map<String, dynamic>> _questions(
          String subjectId, String chapterId) =>
      _db
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .collection('questions');

  CollectionReference<Map<String, dynamic>> get _results =>
      _db.collection('results');

  CollectionReference<Map<String, dynamic>> _selfAssessments(String uid) =>
      _db.collection('users').doc(uid).collection('selfAssessments');

  // ── Subjects ──────────────────────────────────────────────────────────────
  //
  // NOTE: Composite indexes required for WHERE + ORDER BY on separate fields.
  //   Collection: subjects  → fields: level ASC, order ASC
  //   Collection: chapters  → fields: subjectId ASC, order ASC
  // Deploy: firebase deploy --only firestore:indexes

  /// Fetch ordered subjects for a given [level].
  Future<List<SubjectModel>> getSubjects(CmaLevel level) async {
    final snap = await _subjects
        .where('level', isEqualTo: level.firestoreValue)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList();
  }

  /// Real-time stream of subjects (useful for home screen).
  Stream<List<SubjectModel>> watchSubjects(CmaLevel level) =>
      _subjects
          .where('level', isEqualTo: level.firestoreValue)
          .orderBy('order')
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList());

  Future<SubjectModel> getSubject(String subjectId) async {
    final doc = await _subjects.doc(subjectId).get();
    if (!doc.exists) throw Exception('Subject not found: $subjectId');
    return SubjectModel.fromFirestore(doc);
  }

  // ── Chapters ──────────────────────────────────────────────────────────────

  Future<List<ChapterModel>> getChapters(String subjectId) async {
    final snap = await _chapters(subjectId).orderBy('order').get();
    return snap.docs.map((d) => ChapterModel.fromFirestore(d)).toList();
  }

  Stream<List<ChapterModel>> watchChapters(String subjectId) =>
      _chapters(subjectId)
          .orderBy('order')
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => ChapterModel.fromFirestore(d)).toList());

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<List<QuestionModel>> getQuestions(
    String subjectId,
    String chapterId, {
    int? year,
    ExamSession? session,
    String? difficulty,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> query =
        _questions(subjectId, chapterId).orderBy('year', descending: true);

    if (year != null) query = query.where('year', isEqualTo: year);
    if (session != null) {
      query = query.where('session', isEqualTo: session.name);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    final snap = await query.limit(limit).get();
    return snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList();
  }

  Future<QuestionModel> getQuestion(
    String subjectId,
    String chapterId,
    String questionId,
  ) async {
    final doc = await _questions(subjectId, chapterId).doc(questionId).get();
    if (!doc.exists) throw Exception('Question not found: $questionId');
    return QuestionModel.fromFirestore(doc);
  }

  /// Fetch multiple questions by their IDs (fan-out then collect).
  Future<List<QuestionModel>> getQuestionsByIds(
      String subjectId, String chapterId, List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids
        .map((id) => getQuestion(subjectId, chapterId, id))
        .toList();
    return Future.wait(futures);
  }

  // ── User Progress ─────────────────────────────────────────────────────────

  /// Returns the user document snapshot — use [UserModel.fromFirestore].
  Future<UserModel?> getUserProfile() async {
    if (_uid == null) return null;
    final doc = await _users.doc(_uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUserProfile() {
    if (_uid == null) return Stream.value(null);
    return _users
        .doc(_uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Overwrite the user's bookmarked question IDs.
  Future<void> updateBookmarks(String uid, List<String> questionIds) =>
      _users.doc(uid).update({'bookmarkedQuestionIds': questionIds});

  /// Overwrite the user's practiced question IDs.
  Future<void> updatePracticedQuestions(
          String uid, List<String> questionIds) =>
      _users.doc(uid).update({'practicedQuestionIds': questionIds});

  /// Save a self-assessment for one question in the subcollection
  /// `users/{uid}/selfAssessments/{questionId}`.
  Future<void> saveSelfAssessment(
    String uid,
    String questionId,
    String assessment, // 'gotIt' | 'needReview'
  ) =>
      _selfAssessments(uid).doc(questionId).set({
        'assessment': assessment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// Fetch all self-assessments for the current user.
  Future<Map<String, String>> getSelfAssessments(String uid) async {
    final snap = await _selfAssessments(uid).get();
    return {
      for (final doc in snap.docs)
        doc.id: (doc.data()['assessment'] as String?) ?? '',
    };
  }

  // ── Results ───────────────────────────────────────────────────────────────

  /// Persist a test result and return the generated document ID.
  Future<String> saveResult(ResultModel result) async {
    final ref = _results.doc();
    await ref.set({...result.toMap(), 'userId': _uid});
    return ref.id;
  }

  /// Real-time stream of the last 20 results for the current user.
  Stream<List<ResultModel>> getUserResults(String uid) =>
      _results
          .where('userId', isEqualTo: uid)
          .orderBy('completedAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => ResultModel.fromFirestore(d)).toList());

  /// Fetch a single result by document ID.
  Future<ResultModel?> getResult(String resultId) async {
    final doc = await _results.doc(resultId).get();
    if (!doc.exists) return null;
    return ResultModel.fromFirestore(doc);
  }

  // ── Stats Aggregation ─────────────────────────────────────────────────────

  /// Compute weekly stats from the last 7 days of results.
  Future<Map<String, dynamic>> getWeeklyStats(String uid) async {
    final since = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _results
        .where('userId', isEqualTo: uid)
        .where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    final results =
        snap.docs.map((d) => ResultModel.fromFirestore(d)).toList();

    final testsThisWeek = results.length;

    final practicedSet = <String>{};
    for (final r in results) {
      practicedSet.addAll(r.questionIds);
    }

    final totalAccuracy = results.isEmpty
        ? 0.0
        : results.map((r) => r.accuracy).reduce((a, b) => a + b) /
            results.length;

    // Fetch saved FCM token etc.
    return {
      'questionsThisWeek': practicedSet.length,
      'testsThisWeek': testsThisWeek,
      'avgAccuracy': totalAccuracy,
    };
  }

  // ── FCM Token ─────────────────────────────────────────────────────────────

  /// Persist the user's FCM push token to Firestore.
  Future<void> saveFcmToken(String uid, String token) =>
      _users.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
}

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
FirestoreService firestoreService(Ref ref) {
  final uid = ref.watch(authServiceProvider).currentUid;
  return FirestoreService(ref.watch(firestoreProvider), uid);
}

/// Watch subjects by level
@riverpod
Stream<List<SubjectModel>> subjects(Ref ref, CmaLevel level) =>
    ref.watch(firestoreServiceProvider).watchSubjects(level);

/// Fetch single subject
@riverpod
Future<SubjectModel> subject(Ref ref, String subjectId) =>
    ref.watch(firestoreServiceProvider).getSubject(subjectId);

/// Watch chapters for a subject
@riverpod
Stream<List<ChapterModel>> chapters(Ref ref, String subjectId) =>
    ref.watch(firestoreServiceProvider).watchChapters(subjectId);

/// Fetch questions (one-off)
@riverpod
Future<List<QuestionModel>> questions(
  Ref ref,
  String subjectId,
  String chapterId,
) =>
    ref.watch(firestoreServiceProvider).getQuestions(subjectId, chapterId);

/// Fetch single question
@riverpod
Future<QuestionModel> question(
  Ref ref,
  String subjectId,
  String chapterId,
  String questionId,
) =>
    ref
        .watch(firestoreServiceProvider)
        .getQuestion(subjectId, chapterId, questionId);

/// Watch live user profile
@riverpod
Stream<UserModel?> userProfile(Ref ref) =>
    ref.watch(firestoreServiceProvider).watchUserProfile();

/// Stream of the current user's last 20 results
@riverpod
Stream<List<ResultModel>> userResults(Ref ref, String uid) =>
    ref.watch(firestoreServiceProvider).getUserResults(uid);

/// Fetch weekly stats map
@riverpod
Future<Map<String, dynamic>> weeklyStats(Ref ref, String uid) =>
    ref.watch(firestoreServiceProvider).getWeeklyStats(uid);
