import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/models.dart';
import '../../../services/auth_service.dart';

part 'result_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fetch a single ResultModel by resultId from Firestore /results/{id}
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<ResultModel> resultById(Ref ref, String resultId) async {
  final doc = await FirebaseFirestore.instance
      .collection('results')
      .doc(resultId)
      .get();
  if (!doc.exists) throw Exception('Result not found: $resultId');
  return ResultModel.fromFirestore(doc);
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch all questions for a result (by the stored questionIds list)
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<List<QuestionModel>> resultQuestions(Ref ref, String resultId) async {
  final result = await ref.watch(resultByIdProvider(resultId).future);

  if (result.questionIds.isEmpty) return [];

  // Questions live at /subjects/{subjectId}/chapters/{chapterId}/questions/{id}
  // We need to fetch per-chapter because of the nested collection structure.
  final chapterId = result.chapterId;
  final subjectId = result.subjectId;

  final snap = await FirebaseFirestore.instance
      .collection('subjects')
      .doc(subjectId)
      .collection('chapters')
      .doc(chapterId)
      .collection('questions')
      .get();

  final allQs = snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList();

  // Keep only the IDs that were part of this test, in original order
  final idSet = result.questionIds.toSet();
  final qMap = {for (final q in allQs) q.id: q};
  return result.questionIds
      .where((id) => idSet.contains(id) && qMap.containsKey(id))
      .map((id) => qMap[id]!)
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch subject name for the result
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<String> resultSubjectName(Ref ref, String resultId) async {
  final result = await ref.watch(resultByIdProvider(resultId).future);
  final doc = await FirebaseFirestore.instance
      .collection('subjects')
      .doc(result.subjectId)
      .get();
  return (doc.data()?['name'] as String?) ?? 'Unknown Subject';
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch chapter name for the result
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<String> resultChapterName(Ref ref, String resultId) async {
  final result = await ref.watch(resultByIdProvider(resultId).future);
  final doc = await FirebaseFirestore.instance
      .collection('subjects')
      .doc(result.subjectId)
      .collection('chapters')
      .doc(result.chapterId)
      .get();
  return (doc.data()?['name'] as String?) ?? 'Unknown Chapter';
}

// ─────────────────────────────────────────────────────────────────────────────
// Transient in-memory state: stores the latest test session result so
// ResultSummaryScreen can also be reached without a Firestore write during dev.
// ─────────────────────────────────────────────────────────────────────────────

class ActiveResultState {
  const ActiveResultState({
    this.result,
    this.questions = const [],
    this.subjectName = '',
    this.chapterName = '',
  });

  final ResultModel? result;
  final List<QuestionModel> questions;
  final String subjectName;
  final String chapterName;

  bool get isReady => result != null;
}

class ActiveResultNotifier extends StateNotifier<ActiveResultState> {
  ActiveResultNotifier() : super(const ActiveResultState());

  void setResult({
    required ResultModel result,
    required List<QuestionModel> questions,
    required String subjectName,
    required String chapterName,
  }) {
    state = ActiveResultState(
      result: result,
      questions: questions,
      subjectName: subjectName,
      chapterName: chapterName,
    );
  }

  void clear() => state = const ActiveResultState();
}

final activeResultProvider =
    StateNotifierProvider<ActiveResultNotifier, ActiveResultState>(
  (ref) => ActiveResultNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Save a completed result to Firestore and return the document ID
// ─────────────────────────────────────────────────────────────────────────────

Future<String> saveResultToFirestore({
  required ResultModel result,
  required Ref ref,
}) async {
  final uid = ref.read(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) throw Exception('User not logged in');

  final data = result.toMap()..['userId'] = uid;
  final doc =
      await FirebaseFirestore.instance.collection('results').add(data);
  return doc.id;
}
