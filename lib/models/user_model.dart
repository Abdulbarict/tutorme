import 'package:cloud_firestore/cloud_firestore.dart';

/// CMA level enum
enum CmaLevel { foundation, intermediate, final_ }

extension CmaLevelX on CmaLevel {
  String get displayName => switch (this) {
        CmaLevel.foundation => 'Foundation',
        CmaLevel.intermediate => 'Intermediate',
        CmaLevel.final_ => 'Final',
      };
  String get firestoreValue => name;
}

/// TutorMe user profile stored in Firestore `/users/{uid}`.
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.level,
    required this.createdAt,
    this.photoUrl,
    this.phone,
    this.bookmarkedQuestionIds = const [],
    this.practicedQuestionIds = const [],
    this.totalQuestionsAttempted = 0,
    this.totalCorrect = 0,
  });

  final String uid;
  final String email;
  final String fullName;
  final CmaLevel level;
  final DateTime createdAt;
  final String? photoUrl;
  final String? phone;
  final List<String> bookmarkedQuestionIds;
  final List<String> practicedQuestionIds;
  final int totalQuestionsAttempted;
  final int totalCorrect;

  // ── Firestore factory ─────────────────────────────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      // FIX C3: null-safe cast — Google sign-in users may not have email
      // stored in Firestore if the document was created before email capture.
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      level: CmaLevel.values.firstWhere(
        (l) => l.firestoreValue == (data['level'] as String?),
        orElse: () => CmaLevel.foundation,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      bookmarkedQuestionIds:
          List<String>.from(data['bookmarkedQuestionIds'] as List? ?? []),
      practicedQuestionIds:
          List<String>.from(data['practicedQuestionIds'] as List? ?? []),
      totalQuestionsAttempted:
          (data['totalQuestionsAttempted'] as int?) ?? 0,
      totalCorrect: (data['totalCorrect'] as int?) ?? 0,
    );
  }

  // ── toMap ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'level': level.firestoreValue,
        'createdAt': Timestamp.fromDate(createdAt),
        'photoUrl': photoUrl,
        'phone': phone,
        'bookmarkedQuestionIds': bookmarkedQuestionIds,
        'practicedQuestionIds': practicedQuestionIds,
        'totalQuestionsAttempted': totalQuestionsAttempted,
        'totalCorrect': totalCorrect,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    CmaLevel? level,
    DateTime? createdAt,
    String? photoUrl,
    String? phone,
    List<String>? bookmarkedQuestionIds,
    List<String>? practicedQuestionIds,
    int? totalQuestionsAttempted,
    int? totalCorrect,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        level: level ?? this.level,
        createdAt: createdAt ?? this.createdAt,
        photoUrl: photoUrl ?? this.photoUrl,
        phone: phone ?? this.phone,
        bookmarkedQuestionIds:
            bookmarkedQuestionIds ?? this.bookmarkedQuestionIds,
        practicedQuestionIds:
            practicedQuestionIds ?? this.practicedQuestionIds,
        totalQuestionsAttempted:
            totalQuestionsAttempted ?? this.totalQuestionsAttempted,
        totalCorrect: totalCorrect ?? this.totalCorrect,
      );

  double get accuracy => totalQuestionsAttempted == 0
      ? 0
      : totalCorrect / totalQuestionsAttempted;

  @override
  String toString() => 'UserModel(uid: $uid, name: $fullName)';
}
