// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$practiceSubjectsHash() => r'7de087fe91a1c430cd08e572345ec3e59a9500fc';

/// See also [practiceSubjects].
@ProviderFor(practiceSubjects)
final practiceSubjectsProvider =
    AutoDisposeStreamProvider<List<SubjectModel>>.internal(
  practiceSubjects,
  name: r'practiceSubjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$practiceSubjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PracticeSubjectsRef = AutoDisposeStreamProviderRef<List<SubjectModel>>;
String _$practiceChaptersHash() => r'db07cebef00c8ba733cb8b8d2a5728a3225620b2';

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

/// See also [practiceChapters].
@ProviderFor(practiceChapters)
const practiceChaptersProvider = PracticeChaptersFamily();

/// See also [practiceChapters].
class PracticeChaptersFamily extends Family<AsyncValue<List<ChapterModel>>> {
  /// See also [practiceChapters].
  const PracticeChaptersFamily();

  /// See also [practiceChapters].
  PracticeChaptersProvider call(
    String subjectId,
  ) {
    return PracticeChaptersProvider(
      subjectId,
    );
  }

  @override
  PracticeChaptersProvider getProviderOverride(
    covariant PracticeChaptersProvider provider,
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
  String? get name => r'practiceChaptersProvider';
}

/// See also [practiceChapters].
class PracticeChaptersProvider
    extends AutoDisposeStreamProvider<List<ChapterModel>> {
  /// See also [practiceChapters].
  PracticeChaptersProvider(
    String subjectId,
  ) : this._internal(
          (ref) => practiceChapters(
            ref as PracticeChaptersRef,
            subjectId,
          ),
          from: practiceChaptersProvider,
          name: r'practiceChaptersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$practiceChaptersHash,
          dependencies: PracticeChaptersFamily._dependencies,
          allTransitiveDependencies:
              PracticeChaptersFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  PracticeChaptersProvider._internal(
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
    Stream<List<ChapterModel>> Function(PracticeChaptersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PracticeChaptersProvider._internal(
        (ref) => create(ref as PracticeChaptersRef),
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
    return _PracticeChaptersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PracticeChaptersProvider && other.subjectId == subjectId;
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
mixin PracticeChaptersRef on AutoDisposeStreamProviderRef<List<ChapterModel>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _PracticeChaptersProviderElement
    extends AutoDisposeStreamProviderElement<List<ChapterModel>>
    with PracticeChaptersRef {
  _PracticeChaptersProviderElement(super.provider);

  @override
  String get subjectId => (origin as PracticeChaptersProvider).subjectId;
}

String _$practiceSessionQuestionsHash() =>
    r'742aa0591cdc00b612059d1edb368ffbd1dbea73';

/// See also [practiceSessionQuestions].
@ProviderFor(practiceSessionQuestions)
const practiceSessionQuestionsProvider = PracticeSessionQuestionsFamily();

/// See also [practiceSessionQuestions].
class PracticeSessionQuestionsFamily
    extends Family<AsyncValue<List<QuestionModel>>> {
  /// See also [practiceSessionQuestions].
  const PracticeSessionQuestionsFamily();

  /// See also [practiceSessionQuestions].
  PracticeSessionQuestionsProvider call(
    String subjectId,
    List<String> chapterIds,
  ) {
    return PracticeSessionQuestionsProvider(
      subjectId,
      chapterIds,
    );
  }

  @override
  PracticeSessionQuestionsProvider getProviderOverride(
    covariant PracticeSessionQuestionsProvider provider,
  ) {
    return call(
      provider.subjectId,
      provider.chapterIds,
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
  String? get name => r'practiceSessionQuestionsProvider';
}

/// See also [practiceSessionQuestions].
class PracticeSessionQuestionsProvider
    extends AutoDisposeFutureProvider<List<QuestionModel>> {
  /// See also [practiceSessionQuestions].
  PracticeSessionQuestionsProvider(
    String subjectId,
    List<String> chapterIds,
  ) : this._internal(
          (ref) => practiceSessionQuestions(
            ref as PracticeSessionQuestionsRef,
            subjectId,
            chapterIds,
          ),
          from: practiceSessionQuestionsProvider,
          name: r'practiceSessionQuestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$practiceSessionQuestionsHash,
          dependencies: PracticeSessionQuestionsFamily._dependencies,
          allTransitiveDependencies:
              PracticeSessionQuestionsFamily._allTransitiveDependencies,
          subjectId: subjectId,
          chapterIds: chapterIds,
        );

  PracticeSessionQuestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
    required this.chapterIds,
  }) : super.internal();

  final String subjectId;
  final List<String> chapterIds;

  @override
  Override overrideWith(
    FutureOr<List<QuestionModel>> Function(PracticeSessionQuestionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PracticeSessionQuestionsProvider._internal(
        (ref) => create(ref as PracticeSessionQuestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
        chapterIds: chapterIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuestionModel>> createElement() {
    return _PracticeSessionQuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PracticeSessionQuestionsProvider &&
        other.subjectId == subjectId &&
        other.chapterIds == chapterIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);
    hash = _SystemHash.combine(hash, chapterIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PracticeSessionQuestionsRef
    on AutoDisposeFutureProviderRef<List<QuestionModel>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;

  /// The parameter `chapterIds` of this provider.
  List<String> get chapterIds;
}

class _PracticeSessionQuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<QuestionModel>>
    with PracticeSessionQuestionsRef {
  _PracticeSessionQuestionsProviderElement(super.provider);

  @override
  String get subjectId =>
      (origin as PracticeSessionQuestionsProvider).subjectId;
  @override
  List<String> get chapterIds =>
      (origin as PracticeSessionQuestionsProvider).chapterIds;
}

String _$userNeedReviewIdsHash() => r'161dbb05ae06a1e82e4d06424d28088a577924e2';

/// See also [userNeedReviewIds].
@ProviderFor(userNeedReviewIds)
final userNeedReviewIdsProvider =
    AutoDisposeStreamProvider<Set<String>>.internal(
  userNeedReviewIds,
  name: r'userNeedReviewIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userNeedReviewIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserNeedReviewIdsRef = AutoDisposeStreamProviderRef<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
