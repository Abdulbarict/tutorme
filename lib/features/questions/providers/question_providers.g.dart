// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chapterQuestionsHash() => r'fc2dee5f9e733c5483f3e9a452c6c0e803db2dac';

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

/// Stream of questions for a given chapter, ordered by year desc.
///
/// Copied from [chapterQuestions].
@ProviderFor(chapterQuestions)
const chapterQuestionsProvider = ChapterQuestionsFamily();

/// Stream of questions for a given chapter, ordered by year desc.
///
/// Copied from [chapterQuestions].
class ChapterQuestionsFamily extends Family<AsyncValue<List<QuestionModel>>> {
  /// Stream of questions for a given chapter, ordered by year desc.
  ///
  /// Copied from [chapterQuestions].
  const ChapterQuestionsFamily();

  /// Stream of questions for a given chapter, ordered by year desc.
  ///
  /// Copied from [chapterQuestions].
  ChapterQuestionsProvider call(
    String subjectId,
    String chapterId,
  ) {
    return ChapterQuestionsProvider(
      subjectId,
      chapterId,
    );
  }

  @override
  ChapterQuestionsProvider getProviderOverride(
    covariant ChapterQuestionsProvider provider,
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
  String? get name => r'chapterQuestionsProvider';
}

/// Stream of questions for a given chapter, ordered by year desc.
///
/// Copied from [chapterQuestions].
class ChapterQuestionsProvider
    extends AutoDisposeStreamProvider<List<QuestionModel>> {
  /// Stream of questions for a given chapter, ordered by year desc.
  ///
  /// Copied from [chapterQuestions].
  ChapterQuestionsProvider(
    String subjectId,
    String chapterId,
  ) : this._internal(
          (ref) => chapterQuestions(
            ref as ChapterQuestionsRef,
            subjectId,
            chapterId,
          ),
          from: chapterQuestionsProvider,
          name: r'chapterQuestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterQuestionsHash,
          dependencies: ChapterQuestionsFamily._dependencies,
          allTransitiveDependencies:
              ChapterQuestionsFamily._allTransitiveDependencies,
          subjectId: subjectId,
          chapterId: chapterId,
        );

  ChapterQuestionsProvider._internal(
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
    Stream<List<QuestionModel>> Function(ChapterQuestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterQuestionsProvider._internal(
        (ref) => create(ref as ChapterQuestionsRef),
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
  AutoDisposeStreamProviderElement<List<QuestionModel>> createElement() {
    return _ChapterQuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterQuestionsProvider &&
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
mixin ChapterQuestionsRef on AutoDisposeStreamProviderRef<List<QuestionModel>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;

  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _ChapterQuestionsProviderElement
    extends AutoDisposeStreamProviderElement<List<QuestionModel>>
    with ChapterQuestionsRef {
  _ChapterQuestionsProviderElement(super.provider);

  @override
  String get subjectId => (origin as ChapterQuestionsProvider).subjectId;
  @override
  String get chapterId => (origin as ChapterQuestionsProvider).chapterId;
}

String _$chapterDetailHash() => r'6a21fad19072c851b9c2f73485a9fb0fd12052b0';

/// See also [chapterDetail].
@ProviderFor(chapterDetail)
const chapterDetailProvider = ChapterDetailFamily();

/// See also [chapterDetail].
class ChapterDetailFamily extends Family<AsyncValue<ChapterModel>> {
  /// See also [chapterDetail].
  const ChapterDetailFamily();

  /// See also [chapterDetail].
  ChapterDetailProvider call(
    String subjectId,
    String chapterId,
  ) {
    return ChapterDetailProvider(
      subjectId,
      chapterId,
    );
  }

  @override
  ChapterDetailProvider getProviderOverride(
    covariant ChapterDetailProvider provider,
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
  String? get name => r'chapterDetailProvider';
}

/// See also [chapterDetail].
class ChapterDetailProvider extends AutoDisposeFutureProvider<ChapterModel> {
  /// See also [chapterDetail].
  ChapterDetailProvider(
    String subjectId,
    String chapterId,
  ) : this._internal(
          (ref) => chapterDetail(
            ref as ChapterDetailRef,
            subjectId,
            chapterId,
          ),
          from: chapterDetailProvider,
          name: r'chapterDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterDetailHash,
          dependencies: ChapterDetailFamily._dependencies,
          allTransitiveDependencies:
              ChapterDetailFamily._allTransitiveDependencies,
          subjectId: subjectId,
          chapterId: chapterId,
        );

  ChapterDetailProvider._internal(
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
    FutureOr<ChapterModel> Function(ChapterDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterDetailProvider._internal(
        (ref) => create(ref as ChapterDetailRef),
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
  AutoDisposeFutureProviderElement<ChapterModel> createElement() {
    return _ChapterDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterDetailProvider &&
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
mixin ChapterDetailRef on AutoDisposeFutureProviderRef<ChapterModel> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;

  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _ChapterDetailProviderElement
    extends AutoDisposeFutureProviderElement<ChapterModel>
    with ChapterDetailRef {
  _ChapterDetailProviderElement(super.provider);

  @override
  String get subjectId => (origin as ChapterDetailProvider).subjectId;
  @override
  String get chapterId => (origin as ChapterDetailProvider).chapterId;
}

String _$userBookmarkIdsHash() => r'5bfaf0118ea5b462b5681668a8a6ec86904ca1e0';

/// Emits the set of bookmarked question IDs for the current user.
///
/// Copied from [userBookmarkIds].
@ProviderFor(userBookmarkIds)
final userBookmarkIdsProvider = AutoDisposeStreamProvider<Set<String>>.internal(
  userBookmarkIds,
  name: r'userBookmarkIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userBookmarkIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserBookmarkIdsRef = AutoDisposeStreamProviderRef<Set<String>>;
String _$userPracticedIdsHash() => r'053e8b094a9d1acc337c90c456bb8b01fc12be35';

/// Emits the set of practiced question IDs for the current user.
///
/// Copied from [userPracticedIds].
@ProviderFor(userPracticedIds)
final userPracticedIdsProvider =
    AutoDisposeStreamProvider<Set<String>>.internal(
  userPracticedIds,
  name: r'userPracticedIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userPracticedIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserPracticedIdsRef = AutoDisposeStreamProviderRef<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
