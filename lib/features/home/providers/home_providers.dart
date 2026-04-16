import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// FIX M2: Use the models barrel instead of a direct file import.
import '../../../models/models.dart';
import '../../../services/auth_service.dart';

part 'home_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class HomeStats {
  const HomeStats({
    required this.questionsThisWeek,
    required this.testsThisWeek,
    required this.avgAccuracy,
    required this.streak,
    required this.bestStreak,
    required this.weeklyGoal,
    required this.weeklyGoalProgress,
  });

  final int questionsThisWeek;
  final int testsThisWeek;
  final double avgAccuracy;
  final int streak;
  // FIX S6: bestStreak is now a real Firestore field instead of a hardcoded
  // minimum of 12 that made the UI show wrong data for new users.
  final int bestStreak;
  final int weeklyGoal;
  final double weeklyGoalProgress;
}

class ContinueLearningItem {
  const ContinueLearningItem({
    required this.chapterId,
    required this.chapterName,
    required this.subjectName,
    required this.subjectCode,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.subjectId,
  });

  final String chapterId;
  final String chapterName;
  final String subjectName;
  final String subjectCode;
  final int totalQuestions;
  final int answeredQuestions;
  final String subjectId;

  double get progress =>
      totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;
}

// ─────────────────────────────────────────────────────────────────────────────
// Current user profile
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Stream<UserModel?> currentUserProfile(Ref ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      // FIX S8: The snapshot from a typed collection reference is already
      // DocumentSnapshot<Map<String, dynamic>>; the explicit cast was redundant.
      .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Stats provider
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<HomeStats> homeStats(Ref ref) async {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) {
    return const HomeStats(
      questionsThisWeek: 0,
      testsThisWeek: 0,
      avgAccuracy: 0,
      streak: 0,
      bestStreak: 0,
      weeklyGoal: 60,
      weeklyGoalProgress: 0,
    );
  }

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartTs = Timestamp.fromDate(
    DateTime(weekStart.year, weekStart.month, weekStart.day),
  );

  try {
    // Fetch weekly practice sessions
    final practiceSnap = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('practice_sessions')
        .where('createdAt', isGreaterThanOrEqualTo: weekStartTs)
        .get();

    int questionsThisWeek = 0;
    int correctThisWeek = 0;

    for (final doc in practiceSnap.docs) {
      final data = doc.data();
      questionsThisWeek += (data['totalAnswered'] as int?) ?? 0;
      correctThisWeek += (data['totalCorrect'] as int?) ?? 0;
    }

    // Fetch weekly test sessions
    final testSnap = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('test_results')
        .where('createdAt', isGreaterThanOrEqualTo: weekStartTs)
        .get();

    final testsThisWeek = testSnap.docs.length;

    // Streak from user doc
    final userDoc =
        await firestore.collection('users').doc(user.uid).get();
    final streak = (userDoc.data()?['currentStreak'] as int?) ?? 0;
    final bestStreak = (userDoc.data()?['bestStreak'] as int?) ?? streak;
    final weeklyGoal = (userDoc.data()?['weeklyGoal'] as int?) ?? 60;
    final avgAccuracy = questionsThisWeek == 0
        ? 0.0
        : correctThisWeek / questionsThisWeek;

    return HomeStats(
      questionsThisWeek: questionsThisWeek,
      testsThisWeek: testsThisWeek,
      avgAccuracy: avgAccuracy,
      streak: streak,
      bestStreak: bestStreak,
      weeklyGoal: weeklyGoal,
      weeklyGoalProgress:
          weeklyGoal == 0 ? 0 : (questionsThisWeek / weeklyGoal).clamp(0, 1),
    );
  } catch (_) {
    // Return demo data if Firestore is not yet configured
    return const HomeStats(
      questionsThisWeek: 42,
      testsThisWeek: 3,
      avgAccuracy: 0.71,
      streak: 5,
      bestStreak: 12,
      weeklyGoal: 60,
      weeklyGoalProgress: 0.70,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Learning provider
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<List<ContinueLearningItem>> continueLearning(Ref ref) async {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return [];

  try {
    final firestore = FirebaseFirestore.instance;
    final snap = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('chapter_progress')
        .where('progress', isGreaterThan: 0)
        .where('progress', isLessThan: 1)
        .orderBy('lastAccessedAt', descending: true)
        .limit(8)
        .get();

    final items = <ContinueLearningItem>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      items.add(ContinueLearningItem(
        chapterId: doc.id,
        chapterName: (data['chapterName'] as String?) ?? 'Chapter',
        subjectName: (data['subjectName'] as String?) ?? 'Subject',
        subjectCode: (data['subjectCode'] as String?) ?? 'CMA',
        totalQuestions: (data['totalQuestions'] as int?) ?? 22,
        answeredQuestions: (data['answeredQuestions'] as int?) ?? 0,
        subjectId: (data['subjectId'] as String?) ?? '',
      ));
    }
    return items;
  } catch (_) {
    // Demo data
    return const [
      ContinueLearningItem(
        chapterId: 'ch1',
        chapterName: 'Financial Statement Analysis',
        subjectName: 'Financial Accounting',
        subjectCode: 'FA',
        totalQuestions: 22,
        answeredQuestions: 12,
        subjectId: 'sub1',
      ),
      ContinueLearningItem(
        chapterId: 'ch2',
        chapterName: 'Budgeting & Forecasting',
        subjectName: 'Management Accounting',
        subjectCode: 'MA',
        totalQuestions: 18,
        answeredQuestions: 7,
        subjectId: 'sub2',
      ),
      ContinueLearningItem(
        chapterId: 'ch3',
        chapterName: 'Cost Volume Profit Analysis',
        subjectName: 'Cost Accounting',
        subjectCode: 'CA',
        totalQuestions: 30,
        answeredQuestions: 21,
        subjectId: 'sub3',
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Questions provider
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<List<QuestionModel>> recentQuestions(Ref ref) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('questions')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snap.docs
        .map((d) => QuestionModel.fromFirestore(
            d as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  } catch (_) {
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Has Notifications provider (simple placeholder)
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
bool hasNotifications(Ref ref) => false;
