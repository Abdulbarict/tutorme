import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

part 'practice_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter option enum
// ─────────────────────────────────────────────────────────────────────────────

enum PracticeFilter { all, bookmarked, notPracticed, needReview }

extension PracticeFilterLabel on PracticeFilter {
  String get label => switch (this) {
        PracticeFilter.all => 'All',
        PracticeFilter.bookmarked => 'Bookmarked Only',
        PracticeFilter.notPracticed => 'Not Practiced',
        PracticeFilter.needReview => 'Need Review',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Practice session config — passed from Config → Session screen
// ─────────────────────────────────────────────────────────────────────────────

class PracticeConfig {
  const PracticeConfig({
    required this.subjectId,
    required this.subjectName,
    required this.selectedChapterIds,
    required this.filter,
    required this.shuffle,
  });

  final String subjectId;
  final String subjectName;
  final List<String> selectedChapterIds;
  final PracticeFilter filter;
  final bool shuffle;

  PracticeConfig copyWith({
    String? subjectId,
    String? subjectName,
    List<String>? selectedChapterIds,
    PracticeFilter? filter,
    bool? shuffle,
  }) =>
      PracticeConfig(
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        selectedChapterIds: selectedChapterIds ?? this.selectedChapterIds,
        filter: filter ?? this.filter,
        shuffle: shuffle ?? this.shuffle,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Self-assessment result per question
// ─────────────────────────────────────────────────────────────────────────────

enum SelfAssessment { gotIt, needReview }

// ─────────────────────────────────────────────────────────────────────────────
// Session state
// ─────────────────────────────────────────────────────────────────────────────

class PracticeSessionState {
  const PracticeSessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.revealedIndices = const {},
    this.assessments = const {},
    this.isComplete = false,
    this.shuffleActive = false,
  });

  final List<QuestionModel> questions;
  final int currentIndex;

  /// Set of question indices whose answers have been revealed.
  final Set<int> revealedIndices;

  /// Maps question ID → self-assessment result.
  final Map<String, SelfAssessment> assessments;
  final bool isComplete;
  final bool shuffleActive;

  bool get isCurrentRevealed => revealedIndices.contains(currentIndex);

  QuestionModel? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  int get gotItCount =>
      assessments.values.where((a) => a == SelfAssessment.gotIt).length;

  int get needReviewCount =>
      assessments.values.where((a) => a == SelfAssessment.needReview).length;

  PracticeSessionState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    Set<int>? revealedIndices,
    Map<String, SelfAssessment>? assessments,
    bool? isComplete,
    bool? shuffleActive,
  }) =>
      PracticeSessionState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        revealedIndices: revealedIndices ?? this.revealedIndices,
        assessments: assessments ?? this.assessments,
        isComplete: isComplete ?? this.isComplete,
        shuffleActive: shuffleActive ?? this.shuffleActive,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Session notifier
// ─────────────────────────────────────────────────────────────────────────────

class PracticeSessionNotifier extends StateNotifier<PracticeSessionState> {
  PracticeSessionNotifier() : super(const PracticeSessionState());

  void loadQuestions(List<QuestionModel> questions, {bool shuffle = false}) {
    final list = shuffle ? (List<QuestionModel>.from(questions)..shuffle(Random())) : questions;
    state = PracticeSessionState(
      questions: list,
      shuffleActive: shuffle,
    );
  }

  void revealCurrent() {
    final revealed = {...state.revealedIndices, state.currentIndex};
    state = state.copyWith(revealedIndices: revealed);
  }

  void assess(String questionId, SelfAssessment result) {
    final assessments = Map<String, SelfAssessment>.from(state.assessments);
    assessments[questionId] = result;
    state = state.copyWith(assessments: assessments);
  }

  void goToNext() {
    final next = state.currentIndex + 1;
    if (next >= state.questions.length) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(currentIndex: next);
    }
  }

  void goToPrev() {
    if (state.currentIndex == 0) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void goToIndex(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(currentIndex: index);
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffleActive;
    final list = List<QuestionModel>.from(state.questions);
    if (newShuffle) list.shuffle(Random());
    state = PracticeSessionState(
      questions: list,
      shuffleActive: newShuffle,
      assessments: const {},
      revealedIndices: const {},
    );
  }

  void resetSession() {
    state = state.copyWith(
      currentIndex: 0,
      revealedIndices: {},
      assessments: {},
      isComplete: false,
    );
  }

  void filterToNeedReview() {
    final needReview = state.questions
        .where((q) => state.assessments[q.id] == SelfAssessment.needReview)
        .toList();
    state = PracticeSessionState(questions: needReview, shuffleActive: false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final practiceSessionProvider =
    StateNotifierProvider.autoDispose<PracticeSessionNotifier, PracticeSessionState>(
  (ref) => PracticeSessionNotifier(),
);

final activePracticeConfigProvider = StateProvider<PracticeConfig?>((ref) => null);

// ── Subjects for the user's CMA level ───────────────────────────────────────

@riverpod
Stream<List<SubjectModel>> practiceSubjects(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .asyncExpand((userSnap) {
    final levelStr = userSnap.data()?['level'] as String?;
    return FirebaseFirestore.instance
        .collection('subjects')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SubjectModel.fromFirestore(d))
            .where((s) =>
                levelStr == null || s.level.firestoreValue == levelStr)
            .toList());
  });
}

// ── Chapters for a subject ───────────────────────────────────────────────────

@riverpod
Stream<List<ChapterModel>> practiceChapters(Ref ref, String subjectId) {
  if (subjectId.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('subjects')
      .doc(subjectId)
      .collection('chapters')
      .orderBy('order')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ChapterModel.fromFirestore(d)).toList());
}

// ── Load questions for the session ───────────────────────────────────────────

@riverpod
Future<List<QuestionModel>> practiceSessionQuestions(
  Ref ref,
  String subjectId,
  List<String> chapterIds,
) async {
  if (subjectId.isEmpty || chapterIds.isEmpty) return [];

  final futures = chapterIds.map((cid) => FirebaseFirestore.instance
      .collection('subjects')
      .doc(subjectId)
      .collection('chapters')
      .doc(cid)
      .collection('questions')
      .get());

  final results = await Future.wait(futures);
  return results
      .expand((snap) =>
          snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList())
      .toList();
}

// ── Need-review question IDs from user profile ───────────────────────────────

@riverpod
Stream<Set<String>> userNeedReviewIds(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value({});
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists) return <String>{};
    final data = snap.data()!;
    return Set<String>.from(
        List<String>.from(data['needReviewQuestionIds'] as List? ?? []));
  });
}
