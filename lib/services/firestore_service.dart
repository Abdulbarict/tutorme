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

  // ── Subjects ──────────────────────────────────────────────────────────────

  // ── FIX S9: Composite index requirement ─────────────────────────────────
  // The two queries below use WHERE + ORDER BY on separate fields, which
  // requires a Firestore composite index that is NOT created automatically.
  // Without it, the first run on a real project will produce:
  //   [cloud_firestore/failed-precondition] The query requires an index.
  //
  // Required indexes (see firestore.indexes.json at the project root):
  //   Collection: subjects  → fields: level ASC, order ASC
  //   Collection: chapters  → fields: subjectId ASC, order ASC
  //
  // Deploy: firebase deploy --only firestore:indexes
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch ordered subjects for a given [level].
  Future<List<SubjectModel>> getSubjects(CmaLevel level) async {
    final snap = await _subjects
        .where('level', isEqualTo: level.firestoreValue)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => SubjectModel.fromFirestore(d))
        .toList();
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
    final snap =
        await _chapters(subjectId).orderBy('order').get();
    return snap.docs
        .map((d) => ChapterModel.fromFirestore(d))
        .toList();
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
    return snap.docs
        .map((d) => QuestionModel.fromFirestore(d))
        .toList();
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

  // ── Results ───────────────────────────────────────────────────────────────

  Future<String> saveResult(ResultModel result) async {
    final ref = _results.doc();
    await ref.set({...result.toMap(), 'userId': _uid});
    return ref.id;
  }

  Future<List<ResultModel>> getUserResults({int limit = 20}) async {
    if (_uid == null) return [];
    final snap = await _results
        .where('userId', isEqualTo: _uid)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ResultModel.fromFirestore(d)).toList();
  }

  Future<ResultModel?> getResult(String resultId) async {
    final doc = await _results.doc(resultId).get();
    if (!doc.exists) return null;
    return ResultModel.fromFirestore(doc);
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
