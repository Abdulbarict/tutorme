import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/auth_service.dart';

part 'chapter_providers.g.dart';

class ChapterProgress {
  const ChapterProgress({
    required this.totalQuestions,
    required this.answeredQuestions,
  });

  final int totalQuestions;
  final int answeredQuestions;

  double get progress =>
      totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;
}

@riverpod
Future<Map<String, ChapterProgress>> userChapterProgress(
    Ref ref, String subjectId) async {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return {};

  try {
    final firestore = FirebaseFirestore.instance;
    final snap = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('chapter_progress')
        .where('subjectId', isEqualTo: subjectId)
        .get();

    final Map<String, ChapterProgress> map = {};
    for (final doc in snap.docs) {
      final data = doc.data();
      map[doc.id] = ChapterProgress(
        totalQuestions: (data['totalQuestions'] as int?) ?? 0,
        answeredQuestions: (data['answeredQuestions'] as int?) ?? 0,
      );
    }
    return map;
  } catch (_) {
    return {};
  }
}
