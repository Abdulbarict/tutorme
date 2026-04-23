// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resultByIdHash() => r'8a46cd8adae4f1a5c5105a4d7babc7bbc750b600';

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

/// See also [resultById].
@ProviderFor(resultById)
const resultByIdProvider = ResultByIdFamily();

/// See also [resultById].
class ResultByIdFamily extends Family<AsyncValue<ResultModel>> {
  /// See also [resultById].
  const ResultByIdFamily();

  /// See also [resultById].
  ResultByIdProvider call(
    String resultId,
  ) {
    return ResultByIdProvider(
      resultId,
    );
  }

  @override
  ResultByIdProvider getProviderOverride(
    covariant ResultByIdProvider provider,
  ) {
    return call(
      provider.resultId,
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
  String? get name => r'resultByIdProvider';
}

/// See also [resultById].
class ResultByIdProvider extends AutoDisposeFutureProvider<ResultModel> {
  /// See also [resultById].
  ResultByIdProvider(
    String resultId,
  ) : this._internal(
          (ref) => resultById(
            ref as ResultByIdRef,
            resultId,
          ),
          from: resultByIdProvider,
          name: r'resultByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resultByIdHash,
          dependencies: ResultByIdFamily._dependencies,
          allTransitiveDependencies:
              ResultByIdFamily._allTransitiveDependencies,
          resultId: resultId,
        );

  ResultByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resultId,
  }) : super.internal();

  final String resultId;

  @override
  Override overrideWith(
    FutureOr<ResultModel> Function(ResultByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResultByIdProvider._internal(
        (ref) => create(ref as ResultByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resultId: resultId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ResultModel> createElement() {
    return _ResultByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResultByIdProvider && other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResultByIdRef on AutoDisposeFutureProviderRef<ResultModel> {
  /// The parameter `resultId` of this provider.
  String get resultId;
}

class _ResultByIdProviderElement
    extends AutoDisposeFutureProviderElement<ResultModel> with ResultByIdRef {
  _ResultByIdProviderElement(super.provider);

  @override
  String get resultId => (origin as ResultByIdProvider).resultId;
}

String _$resultQuestionsHash() => r'f58dbf0d7d286f9dfd4879bacceb8577b6f1df42';

/// See also [resultQuestions].
@ProviderFor(resultQuestions)
const resultQuestionsProvider = ResultQuestionsFamily();

/// See also [resultQuestions].
class ResultQuestionsFamily extends Family<AsyncValue<List<QuestionModel>>> {
  /// See also [resultQuestions].
  const ResultQuestionsFamily();

  /// See also [resultQuestions].
  ResultQuestionsProvider call(
    String resultId,
  ) {
    return ResultQuestionsProvider(
      resultId,
    );
  }

  @override
  ResultQuestionsProvider getProviderOverride(
    covariant ResultQuestionsProvider provider,
  ) {
    return call(
      provider.resultId,
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
  String? get name => r'resultQuestionsProvider';
}

/// See also [resultQuestions].
class ResultQuestionsProvider
    extends AutoDisposeFutureProvider<List<QuestionModel>> {
  /// See also [resultQuestions].
  ResultQuestionsProvider(
    String resultId,
  ) : this._internal(
          (ref) => resultQuestions(
            ref as ResultQuestionsRef,
            resultId,
          ),
          from: resultQuestionsProvider,
          name: r'resultQuestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resultQuestionsHash,
          dependencies: ResultQuestionsFamily._dependencies,
          allTransitiveDependencies:
              ResultQuestionsFamily._allTransitiveDependencies,
          resultId: resultId,
        );

  ResultQuestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resultId,
  }) : super.internal();

  final String resultId;

  @override
  Override overrideWith(
    FutureOr<List<QuestionModel>> Function(ResultQuestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResultQuestionsProvider._internal(
        (ref) => create(ref as ResultQuestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resultId: resultId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuestionModel>> createElement() {
    return _ResultQuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResultQuestionsProvider && other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResultQuestionsRef on AutoDisposeFutureProviderRef<List<QuestionModel>> {
  /// The parameter `resultId` of this provider.
  String get resultId;
}

class _ResultQuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<QuestionModel>>
    with ResultQuestionsRef {
  _ResultQuestionsProviderElement(super.provider);

  @override
  String get resultId => (origin as ResultQuestionsProvider).resultId;
}

String _$resultSubjectNameHash() => r'c5bb96b1a6b5e4db110de8e5456893e82b61751a';

/// See also [resultSubjectName].
@ProviderFor(resultSubjectName)
const resultSubjectNameProvider = ResultSubjectNameFamily();

/// See also [resultSubjectName].
class ResultSubjectNameFamily extends Family<AsyncValue<String>> {
  /// See also [resultSubjectName].
  const ResultSubjectNameFamily();

  /// See also [resultSubjectName].
  ResultSubjectNameProvider call(
    String resultId,
  ) {
    return ResultSubjectNameProvider(
      resultId,
    );
  }

  @override
  ResultSubjectNameProvider getProviderOverride(
    covariant ResultSubjectNameProvider provider,
  ) {
    return call(
      provider.resultId,
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
  String? get name => r'resultSubjectNameProvider';
}

/// See also [resultSubjectName].
class ResultSubjectNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [resultSubjectName].
  ResultSubjectNameProvider(
    String resultId,
  ) : this._internal(
          (ref) => resultSubjectName(
            ref as ResultSubjectNameRef,
            resultId,
          ),
          from: resultSubjectNameProvider,
          name: r'resultSubjectNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resultSubjectNameHash,
          dependencies: ResultSubjectNameFamily._dependencies,
          allTransitiveDependencies:
              ResultSubjectNameFamily._allTransitiveDependencies,
          resultId: resultId,
        );

  ResultSubjectNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resultId,
  }) : super.internal();

  final String resultId;

  @override
  Override overrideWith(
    FutureOr<String> Function(ResultSubjectNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResultSubjectNameProvider._internal(
        (ref) => create(ref as ResultSubjectNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resultId: resultId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _ResultSubjectNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResultSubjectNameProvider && other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResultSubjectNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `resultId` of this provider.
  String get resultId;
}

class _ResultSubjectNameProviderElement
    extends AutoDisposeFutureProviderElement<String> with ResultSubjectNameRef {
  _ResultSubjectNameProviderElement(super.provider);

  @override
  String get resultId => (origin as ResultSubjectNameProvider).resultId;
}

String _$resultChapterNameHash() => r'07e49da280429a35c9007abae7c966a33d5e387c';

/// See also [resultChapterName].
@ProviderFor(resultChapterName)
const resultChapterNameProvider = ResultChapterNameFamily();

/// See also [resultChapterName].
class ResultChapterNameFamily extends Family<AsyncValue<String>> {
  /// See also [resultChapterName].
  const ResultChapterNameFamily();

  /// See also [resultChapterName].
  ResultChapterNameProvider call(
    String resultId,
  ) {
    return ResultChapterNameProvider(
      resultId,
    );
  }

  @override
  ResultChapterNameProvider getProviderOverride(
    covariant ResultChapterNameProvider provider,
  ) {
    return call(
      provider.resultId,
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
  String? get name => r'resultChapterNameProvider';
}

/// See also [resultChapterName].
class ResultChapterNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [resultChapterName].
  ResultChapterNameProvider(
    String resultId,
  ) : this._internal(
          (ref) => resultChapterName(
            ref as ResultChapterNameRef,
            resultId,
          ),
          from: resultChapterNameProvider,
          name: r'resultChapterNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resultChapterNameHash,
          dependencies: ResultChapterNameFamily._dependencies,
          allTransitiveDependencies:
              ResultChapterNameFamily._allTransitiveDependencies,
          resultId: resultId,
        );

  ResultChapterNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resultId,
  }) : super.internal();

  final String resultId;

  @override
  Override overrideWith(
    FutureOr<String> Function(ResultChapterNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResultChapterNameProvider._internal(
        (ref) => create(ref as ResultChapterNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resultId: resultId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _ResultChapterNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResultChapterNameProvider && other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResultChapterNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `resultId` of this provider.
  String get resultId;
}

class _ResultChapterNameProviderElement
    extends AutoDisposeFutureProviderElement<String> with ResultChapterNameRef {
  _ResultChapterNameProviderElement(super.provider);

  @override
  String get resultId => (origin as ResultChapterNameProvider).resultId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
