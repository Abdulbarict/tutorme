// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userChapterProgressHash() =>
    r'dbc39e76d8b43120bd661273ac41e4608e3f98d8';

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

/// See also [userChapterProgress].
@ProviderFor(userChapterProgress)
const userChapterProgressProvider = UserChapterProgressFamily();

/// See also [userChapterProgress].
class UserChapterProgressFamily
    extends Family<AsyncValue<Map<String, ChapterProgress>>> {
  /// See also [userChapterProgress].
  const UserChapterProgressFamily();

  /// See also [userChapterProgress].
  UserChapterProgressProvider call(
    String subjectId,
  ) {
    return UserChapterProgressProvider(
      subjectId,
    );
  }

  @override
  UserChapterProgressProvider getProviderOverride(
    covariant UserChapterProgressProvider provider,
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
  String? get name => r'userChapterProgressProvider';
}

/// See also [userChapterProgress].
class UserChapterProgressProvider
    extends AutoDisposeFutureProvider<Map<String, ChapterProgress>> {
  /// See also [userChapterProgress].
  UserChapterProgressProvider(
    String subjectId,
  ) : this._internal(
          (ref) => userChapterProgress(
            ref as UserChapterProgressRef,
            subjectId,
          ),
          from: userChapterProgressProvider,
          name: r'userChapterProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userChapterProgressHash,
          dependencies: UserChapterProgressFamily._dependencies,
          allTransitiveDependencies:
              UserChapterProgressFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  UserChapterProgressProvider._internal(
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
    FutureOr<Map<String, ChapterProgress>> Function(
            UserChapterProgressRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserChapterProgressProvider._internal(
        (ref) => create(ref as UserChapterProgressRef),
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
  AutoDisposeFutureProviderElement<Map<String, ChapterProgress>>
      createElement() {
    return _UserChapterProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserChapterProgressProvider && other.subjectId == subjectId;
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
mixin UserChapterProgressRef
    on AutoDisposeFutureProviderRef<Map<String, ChapterProgress>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _UserChapterProgressProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, ChapterProgress>>
    with UserChapterProgressRef {
  _UserChapterProgressProviderElement(super.provider);

  @override
  String get subjectId => (origin as UserChapterProgressProvider).subjectId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
