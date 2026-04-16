// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreHash() => r'597b1a9eb96f2fae51f5b578f4b5debe4f6d30c6';

/// See also [firestore].
@ProviderFor(firestore)
final firestoreProvider = AutoDisposeProvider<FirebaseFirestore>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$firestoreServiceHash() => r'64a0a27da87ff32b67be857ceb236fa131a2ee54';

/// See also [firestoreService].
@ProviderFor(firestoreService)
final firestoreServiceProvider = AutoDisposeProvider<FirestoreService>.internal(
  firestoreService,
  name: r'firestoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreServiceRef = AutoDisposeProviderRef<FirestoreService>;
String _$subjectsHash() => r'93124456e8f904b1abcbd07134b4f9b312e082b0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Watch subjects by level
///
/// Copied from [subjects].
@ProviderFor(subjects)
const subjectsProvider = SubjectsFamily();

/// Watch subjects by level
///
/// Copied from [subjects].
class SubjectsFamily extends Family<AsyncValue<List<SubjectModel>>> {
  /// Watch subjects by level
  ///
  /// Copied from [subjects].
  const SubjectsFamily();

  /// Watch subjects by level
  ///
  /// Copied from [subjects].
  SubjectsProvider call(
    CmaLevel level,
  ) {
    return SubjectsProvider(
      level,
    );
  }

  @override
  SubjectsProvider getProviderOverride(
    covariant SubjectsProvider provider,
  ) {
    return call(
      provider.level,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectsProvider';
}

/// Watch subjects by level
///
/// Copied from [subjects].
class SubjectsProvider extends AutoDisposeStreamProvider<List<SubjectModel>> {
  /// Watch subjects by level
  ///
  /// Copied from [subjects].
  SubjectsProvider(
    CmaLevel level,
  ) : this._internal(
          (ref) => subjects(
            ref as SubjectsRef,
            level,
          ),
          from: subjectsProvider,
          name: r'subjectsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subjectsHash,
          dependencies: SubjectsFamily._dependencies,
          allTransitiveDependencies: SubjectsFamily._allTransitiveDependencies,
          level: level,
        );

  SubjectsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.level,
  }) : super.internal();

  final CmaLevel level;

  @override
  Override overrideWith(
    Stream<List<SubjectModel>> Function(SubjectsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectsProvider._internal(
        (ref) => create(ref as SubjectsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        level: level,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SubjectModel>> createElement() {
    return _SubjectsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectsProvider && other.level == level;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, level.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectsRef on AutoDisposeStreamProviderRef<List<SubjectModel>> {
  /// The parameter `level` of this provider.
  CmaLevel get level;
}

class _SubjectsProviderElement
    extends AutoDisposeStreamProviderElement<List<SubjectModel>>
    with SubjectsRef {
  _SubjectsProviderElement(super.provider);

  @override
  CmaLevel get level => (origin as SubjectsProvider).level;
}

String _$chaptersHash() => r'1f332c3ec5bb091e97b52a22d5b8c941f64362c7';

/// Watch chapters for a subject
///
/// Copied from [chapters].
@ProviderFor(chapters)
const chaptersProvider = ChaptersFamily();

/// Watch chapters for a subject
///
/// Copied from [chapters].
class ChaptersFamily extends Family<AsyncValue<List<ChapterModel>>> {
  /// Watch chapters for a subject
  ///
  /// Copied from [chapters].
  const ChaptersFamily();

  /// Watch chapters for a subject
  ///
  /// Copied from [chapters].
  ChaptersProvider call(
    String subjectId,
  ) {
    return ChaptersProvider(
      subjectId,
    );
  }

  @override
  ChaptersProvider getProviderOverride(
    covariant ChaptersProvider provider,
  ) {
    return call(
      provider.subjectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chaptersProvider';
}

/// Watch chapters for a subject
///
/// Copied from [chapters].
class ChaptersProvider extends AutoDisposeStreamProvider<List<ChapterModel>> {
  /// Watch chapters for a subject
  ///
  /// Copied from [chapters].
  ChaptersProvider(
    String subjectId,
  ) : this._internal(
          (ref) => chapters(
            ref as ChaptersRef,
            subjectId,
          ),
          from: chaptersProvider,
          name: r'chaptersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chaptersHash,
          dependencies: ChaptersFamily._dependencies,
          allTransitiveDependencies: ChaptersFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  ChaptersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    Stream<List<ChapterModel>> Function(ChaptersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChaptersProvider._internal(
        (ref) => create(ref as ChaptersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ChapterModel>> createElement() {
    return _ChaptersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChaptersProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChaptersRef on AutoDisposeStreamProviderRef<List<ChapterModel>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _ChaptersProviderElement
    extends AutoDisposeStreamProviderElement<List<ChapterModel>>
    with ChaptersRef {
  _ChaptersProviderElement(super.provider);

  @override
  String get subjectId => (origin as ChaptersProvider).subjectId;
}

String _$questionsHash() => r'893dd8f656f1b4d6fd22cdc24d7e899f68b6c1f6';

/// Fetch questions (one-off)
///
/// Copied from [questions].
@ProviderFor(questions)
const questionsProvider = QuestionsFamily();

/// Fetch questions (one-off)
///
/// Copied from [questions].
class QuestionsFamily extends Family<AsyncValue<List<QuestionModel>>> {
  /// Fetch questions (one-off)
  ///
  /// Copied from [questions].
  const QuestionsFamily();

  /// Fetch questions (one-off)
  ///
  /// Copied from [questions].
  QuestionsProvider call(
    String subjectId,
    String chapterId,
  ) {
    return QuestionsProvider(
      subjectId,
      chapterId,
    );
  }

  @override
  QuestionsProvider getProviderOverride(
    covariant QuestionsProvider provider,
  ) {
    return call(
      provider.subjectId,
      provider.chapterId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'questionsProvider';
}

/// Fetch questions (one-off)
///
/// Copied from [questions].
class QuestionsProvider extends AutoDisposeFutureProvider<List<QuestionModel>> {
  /// Fetch questions (one-off)
  ///
  /// Copied from [questions].
  QuestionsProvider(
    String subjectId,
    String chapterId,
  ) : this._internal(
          (ref) => questions(
            ref as QuestionsRef,
            subjectId,
            chapterId,
          ),
          from: questionsProvider,
          name: r'questionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$questionsHash,
          dependencies: QuestionsFamily._dependencies,
          allTransitiveDependencies: QuestionsFamily._allTransitiveDependencies,
          subjectId: subjectId,
          chapterId: chapterId,
        );

  QuestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
    required this.chapterId,
  }) : super.internal();

  final String subjectId;
  final String chapterId;

  @override
  Override overrideWith(
    FutureOr<List<QuestionModel>> Function(QuestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionsProvider._internal(
        (ref) => create(ref as QuestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuestionModel>> createElement() {
    return _QuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionsProvider &&
        other.subjectId == subjectId &&
        other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuestionsRef on AutoDisposeFutureProviderRef<List<QuestionModel>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;

  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _QuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<QuestionModel>>
    with QuestionsRef {
  _QuestionsProviderElement(super.provider);

  @override
  String get subjectId => (origin as QuestionsProvider).subjectId;
  @override
  String get chapterId => (origin as QuestionsProvider).chapterId;
}

String _$questionHash() => r'4094d79c2859f7f453c7e2f38300c497604709fa';

/// Fetch single question
///
/// Copied from [question].
@ProviderFor(question)
const questionProvider = QuestionFamily();

/// Fetch single question
///
/// Copied from [question].
class QuestionFamily extends Family<AsyncValue<QuestionModel>> {
  /// Fetch single question
  ///
  /// Copied from [question].
  const QuestionFamily();

  /// Fetch single question
  ///
  /// Copied from [question].
  QuestionProvider call(
    String subjectId,
    String chapterId,
    String questionId,
  ) {
    return QuestionProvider(
      subjectId,
      chapterId,
      questionId,
    );
  }

  @override
  QuestionProvider getProviderOverride(
    covariant QuestionProvider provider,
  ) {
    return call(
      provider.subjectId,
      provider.chapterId,
      provider.questionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'questionProvider';
}

/// Fetch single question
///
/// Copied from [question].
class QuestionProvider extends AutoDisposeFutureProvider<QuestionModel> {
  /// Fetch single question
  ///
  /// Copied from [question].
  QuestionProvider(
    String subjectId,
    String chapterId,
    String questionId,
  ) : this._internal(
          (ref) => question(
            ref as QuestionRef,
            subjectId,
            chapterId,
            questionId,
          ),
          from: questionProvider,
          name: r'questionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$questionHash,
          dependencies: QuestionFamily._dependencies,
          allTransitiveDependencies: QuestionFamily._allTransitiveDependencies,
          subjectId: subjectId,
          chapterId: chapterId,
          questionId: questionId,
        );

  QuestionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
    required this.chapterId,
    required this.questionId,
  }) : super.internal();

  final String subjectId;
  final String chapterId;
  final String questionId;

  @override
  Override overrideWith(
    FutureOr<QuestionModel> Function(QuestionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionProvider._internal(
        (ref) => create(ref as QuestionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
        chapterId: chapterId,
        questionId: questionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<QuestionModel> createElement() {
    return _QuestionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionProvider &&
        other.subjectId == subjectId &&
        other.chapterId == chapterId &&
        other.questionId == questionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);
    hash = _SystemHash.combine(hash, questionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuestionRef on AutoDisposeFutureProviderRef<QuestionModel> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;

  /// The parameter `chapterId` of this provider.
  String get chapterId;

  /// The parameter `questionId` of this provider.
  String get questionId;
}

class _QuestionProviderElement
    extends AutoDisposeFutureProviderElement<QuestionModel> with QuestionRef {
  _QuestionProviderElement(super.provider);

  @override
  String get subjectId => (origin as QuestionProvider).subjectId;
  @override
  String get chapterId => (origin as QuestionProvider).chapterId;
  @override
  String get questionId => (origin as QuestionProvider).questionId;
}

String _$userProfileHash() => r'e84f4ff2636ae68da707a8a05989518f301c6a8f';

/// Watch live user profile
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeStreamProvider<UserModel?>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeStreamProviderRef<UserModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
