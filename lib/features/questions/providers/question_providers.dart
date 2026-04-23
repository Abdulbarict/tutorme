import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

part 'question_providers.g.dart';

// ── Questions for a chapter ───────────────────────────────────────────────────

/// Stream of questions for a given chapter, ordered by year desc.
@riverpod
Stream<List<QuestionModel>> chapterQuestions(
  Ref ref,
  String subjectId,
  String chapterId,
) =>
    FirebaseFirestore.instance
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('questions')
        .orderBy('year', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList());

// ── Chapter metadata for the list screen ─────────────────────────────────────

@riverpod
Future<ChapterModel> chapterDetail(Ref ref, String subjectId,
    String chapterId) async {
  final doc = await FirebaseFirestore.instance
      .collection('subjects')
      .doc(subjectId)
      .collection('chapters')
      .doc(chapterId)
      .get();
  if (!doc.exists) throw Exception('Chapter not found: $chapterId');
  return ChapterModel.fromFirestore(doc);
}

// ── Bookmark IDs from user profile ───────────────────────────────────────────

/// Emits the set of bookmarked question IDs for the current user.
@riverpod
Stream<Set<String>> userBookmarkIds(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value({});
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists) return <String>{};
    final data = snap.data()!;
    final list =
        List<String>.from(data['bookmarkedQuestionIds'] as List? ?? []);
    return list.toSet();
  });
}

// ── Practiced question IDs ────────────────────────────────────────────────────

/// Emits the set of practiced question IDs for the current user.
@riverpod
Stream<Set<String>> userPracticedIds(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value({});
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists) return <String>{};
    final data = snap.data()!;
    final list =
        List<String>.from(data['practicedQuestionIds'] as List? ?? []);
    return list.toSet();
  });
}

// ── Bookmark toggle notifier ──────────────────────────────────────────────────

/// Simple helper to toggle bookmark with optimistic-like UX.
/// The source-of-truth is the Firestore stream above; this just fires the write.
Future<void> toggleBookmarkWrite(
    UserService service, String questionId, bool currentlyBookmarked) =>
    service.toggleBookmark(questionId, currentlyBookmarked);
