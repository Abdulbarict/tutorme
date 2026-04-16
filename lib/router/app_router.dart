import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/app_routes.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/level_selection_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/bookmarks/screens/bookmarks_screen.dart';
import '../features/chapters/screens/chapter_list_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/home_shell.dart';
import '../features/practice/screens/practice_config_screen.dart';
import '../features/practice/screens/practice_session_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/questions/screens/question_detail_screen.dart';
import '../features/questions/screens/question_list_screen.dart';
import '../features/results/screens/answer_review_screen.dart';
import '../features/results/screens/result_summary_screen.dart';
import '../features/subjects/screens/subject_list_screen.dart';
import '../features/test/screens/test_config_screen.dart';
import '../features/test/screens/test_session_screen.dart';
import '../services/auth_service.dart';

part 'app_router.g.dart';

// ── Root navigator key ────────────────────────────────────────────────────────
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// ─────────────────────────────────────────────────────────────────────────────
// FIX C5: keepAlive = true prevents GoRouter from being disposed and
// re-created every time the authStateChanges stream emits. Without this,
// the full navigation stack is wiped on every auth state change (e.g.,
// after a token refresh), which is a severe UX regression.
// ─────────────────────────────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.uri.toString();

      // Paths that never require authentication
      final publicPaths = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.levelSelect,
      ];

      final isPublic = publicPaths.any((p) => location.startsWith(p));

      if (!isLoggedIn && !isPublic) return AppRoutes.login;

      // FIX S1: Also redirect away from /signup and /onboarding while logged-in,
      // not only /login. Without this a logged-in user can type those URLs and
      // reach the auth flow, causing duplicate signup / account confusion.
      final authOnlyPaths = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.onboarding,
      ];
      if (isLoggedIn && authOnlyPaths.any((p) => location.startsWith(p))) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Public ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.levelSelect,
        builder: (_, __) => const LevelSelectionScreen(),
      ),

      // ── FIX M1: Full-screen overlays — rendered above the shell ─────────
      // These are NOT nested inside StatefulShellRoute, so they display
      // without the bottom navigation bar and do not switch the active tab.
      // Any screen (Home quick-actions, Profile page) can navigate here
      // via context.go(AppRoutes.bookmarks) / context.go(AppRoutes.progress).
      GoRoute(
        path: AppRoutes.bookmarks,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const ProgressScreen(),
      ),

      // ── Authenticated Shell (StatefulShellRoute) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // ── Tab 0: Home ─────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // ── Tab 1: Subjects ─────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (_, __) => const SubjectListScreen(),
                routes: [
                  GoRoute(
                    path: ':subjectId/chapters',
                    builder: (_, state) => ChapterListScreen(
                      subjectId: state.pathParameters['subjectId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: ':chapterId/questions',
                        builder: (_, state) => QuestionListScreen(
                          subjectId: state.pathParameters['subjectId']!,
                          chapterId: state.pathParameters['chapterId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':questionId',
                            parentNavigatorKey: _rootKey,
                            builder: (_, state) => QuestionDetailScreen(
                              subjectId: state.pathParameters['subjectId']!,
                              chapterId: state.pathParameters['chapterId']!,
                              questionId: state.pathParameters['questionId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 2: Practice ─────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practiceConfig,
                builder: (_, __) => const PracticeConfigScreen(),
                routes: [
                  GoRoute(
                    path: 'session',
                    parentNavigatorKey: _rootKey,
                    builder: (_, __) => const PracticeSessionScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 3: Tests ─────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.testConfig,
                builder: (_, __) => const TestConfigScreen(),
                routes: [
                  GoRoute(
                    path: 'session',
                    parentNavigatorKey: _rootKey,
                    builder: (_, __) => const TestSessionScreen(),
                  ),
                  GoRoute(
                    path: 'result/:resultId',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) => ResultSummaryScreen(
                      resultId: state.pathParameters['resultId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'review',
                        builder: (_, state) => AnswerReviewScreen(
                          resultId: state.pathParameters['resultId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 4: Profile ──────────────────────────────────────
          // Bookmarks and progress are now root-level routes (above) so
          // navigating to them from any tab does not switch to profile.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => _ErrorScreen(error: state.error),
  );
}

// ── Error fallback ────────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(
            'Route not found\n${error?.toString() ?? ''}',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
