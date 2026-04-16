import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

part 'user_service.g.dart';

/// High-level user operations — profile updates, bookmarks, practice tracking.
///
/// This service sits above [FirestoreService] and exposes domain-specific
/// write operations to prevent scattered Firestore logic in the UI layer.
class UserService {
  UserService(this._db, this._uid);

  final FirebaseFirestore _db;
  final String? _uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc =>
      _uid == null ? null : _db.collection('users').doc(_uid);

  // ── Profile ───────────────────────────────────────────────────────────────

  /// Create or fully overwrite a user document (used after sign-up).
  Future<void> createUserProfile(UserModel user) =>
      _db.collection('users').doc(user.uid).set(user.toMap());

  /// Partial update — only the supplied fields are written.
  Future<void> updateProfile({
    String? fullName,
    String? photoUrl,
    String? phone,
    CmaLevel? level,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phone != null) data['phone'] = phone;
    if (level != null) data['level'] = level.firestoreValue;
    if (data.isNotEmpty) await doc.update(data);
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  /// Add a question ID to the user's bookmark list.
  Future<void> addBookmark(String questionId) async {
    await _userDoc?.update({
      'bookmarkedQuestionIds': FieldValue.arrayUnion([questionId]),
    });
  }

  /// Remove a question ID from the user's bookmark list.
  Future<void> removeBookmark(String questionId) async {
    await _userDoc?.update({
      'bookmarkedQuestionIds': FieldValue.arrayRemove([questionId]),
    });
  }

  /// Toggle bookmark state, returning the new state (true = bookmarked).
  Future<bool> toggleBookmark(String questionId, bool currentlyBookmarked) async {
    if (currentlyBookmarked) {
      await removeBookmark(questionId);
      return false;
    } else {
      await addBookmark(questionId);
      return true;
    }
  }

  // ── Practiced Questions ───────────────────────────────────────────────────

  /// Mark one or more questions as practiced.
  Future<void> markAsPracticed(List<String> questionIds) async {
    if (questionIds.isEmpty) return;
    await _userDoc?.update({
      'practicedQuestionIds': FieldValue.arrayUnion(questionIds),
    });
  }

  // ── Progress Counters ─────────────────────────────────────────────────────

  /// Atomically increment attempt/correct counters after a session.
  Future<void> updatePracticedQuestions({
    required int attempted,
    required int correct,
  }) async {
    await _userDoc?.update({
      'totalQuestionsAttempted': FieldValue.increment(attempted),
      'totalCorrect': FieldValue.increment(correct),
    });
  }

  // ── First-time initialisation ──────────────────────────────────────────────

  /// Write streak / goal fields that are NOT covered by [UserModel.toMap()].
  ///
  /// Called once after [createUserProfile] on new sign-ups so that
  /// [homeStatsProvider] always reads real Firestore data rather than
  /// falling back to hard-coded demo values.
  Future<void> initUserStats() async {
    await _userDoc?.set(
      {
        'currentStreak': 0,
        'bestStreak': 0,
        'weeklyGoal': 60,
        'lastActiveDate': null,
      },
      SetOptions(merge: true),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
UserService userService(Ref ref) {
  final uid = ref.watch(authServiceProvider).currentUid;
  return UserService(ref.watch(firestoreProvider), uid);
}
