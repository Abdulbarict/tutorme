// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserProfileHash() =>
    r'8ca196de9be0abb38f3e4009b4ebf60e44e15a9a';

/// See also [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeStreamProvider<UserModel?>.internal(
  currentUserProfile,
  name: r'currentUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeStreamProviderRef<UserModel?>;
String _$homeStatsHash() => r'4c52043ea12ce92acae63b1b27d18f3aa9effd50';

/// See also [homeStats].
@ProviderFor(homeStats)
final homeStatsProvider = AutoDisposeFutureProvider<HomeStats>.internal(
  homeStats,
  name: r'homeStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$homeStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeStatsRef = AutoDisposeFutureProviderRef<HomeStats>;
String _$continueLearningHash() => r'607dc857d7e89486a175479644f4d5be1905a2dc';

/// See also [continueLearning].
@ProviderFor(continueLearning)
final continueLearningProvider =
    AutoDisposeFutureProvider<List<ContinueLearningItem>>.internal(
  continueLearning,
  name: r'continueLearningProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$continueLearningHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContinueLearningRef
    = AutoDisposeFutureProviderRef<List<ContinueLearningItem>>;
String _$recentQuestionsHash() => r'901b2ffc2562d890e651036bf33deabff64ffc87';

/// See also [recentQuestions].
@ProviderFor(recentQuestions)
final recentQuestionsProvider =
    AutoDisposeFutureProvider<List<QuestionModel>>.internal(
  recentQuestions,
  name: r'recentQuestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentQuestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentQuestionsRef = AutoDisposeFutureProviderRef<List<QuestionModel>>;
String _$hasNotificationsHash() => r'9f6c4833f4c4c3ff6a6e1227981fa32595247301';

/// See also [hasNotifications].
@ProviderFor(hasNotifications)
final hasNotificationsProvider = AutoDisposeProvider<bool>.internal(
  hasNotifications,
  name: r'hasNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasNotificationsRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
