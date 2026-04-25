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

// ── Root navigator key ─────────────────────────────────────────────────────────
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// ── Transition helpers ─────────────────────────────────────────────────────────

/// Standard push: slide from right.
CustomTransitionPage<void> _slideRight(
  BuildContext context,
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );

/// Modal overlay: fade in.
CustomTransitionPage<void> _fade(
  BuildContext context,
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

// ─────────────────────────────────────────────────────────────────────────────
// FIX C5: keepAlive = true prevents GoRouter from being disposed and
// re-created every time the authStateChanges stream emits.
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

      final publicPaths = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.levelSelect,
      ];
      final isPublic = publicPaths.any((p) => location.startsWith(p));

      if (!isLoggedIn && !isPublic) return AppRoutes.login;

      final authOnlyPaths = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.onboarding,
      ];
      if (isLoggedIn &&
          authOnlyPaths.any((p) => location.startsWith(p))) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Public ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (ctx, state) =>
            _fade(ctx, state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const SignupScreen()),
      ),
      GoRoute(
        path: AppRoutes.levelSelect,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const LevelSelectionScreen()),
      ),

      // ── Full-screen overlays (above shell, no bottom nav) ─────────────────
      GoRoute(
        path: AppRoutes.bookmarks,
        parentNavigatorKey: _rootKey,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const BookmarksScreen()),
      ),
      GoRoute(
        path: AppRoutes.progress,
        parentNavigatorKey: _rootKey,
        pageBuilder: (ctx, state) =>
            _slideRight(ctx, state, const ProgressScreen()),
      ),

      // ── Authenticated Shell ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          // ── Tab 0: Home ──────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (ctx, state) =>
                    _fade(ctx, state, const HomeDashboardScreen()),
              ),
            ],
          ),

          // ── Tab 1: Subjects ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                pageBuilder: (ctx, state) =>
                    _fade(ctx, state, const SubjectListScreen()),
                routes: [
                  GoRoute(
                    path: ':subjectId/chapters',
                    pageBuilder: (ctx, state) => _slideRight(
                      ctx,
                      state,
                      ChapterListScreen(
                        subjectId: state.pathParameters['subjectId']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: ':chapterId/questions',
                        pageBuilder: (ctx, state) => _slideRight(
                          ctx,
                          state,
                          QuestionListScreen(
                            subjectId: state.pathParameters['subjectId']!,
                            chapterId: state.pathParameters['chapterId']!,
                          ),
                        ),
                        routes: [
                          GoRoute(
                            path: ':questionId',
                            parentNavigatorKey: _rootKey,
                            pageBuilder: (ctx, state) => _slideRight(
                              ctx,
                              state,
                              QuestionDetailScreen(
                                subjectId:
                                    state.pathParameters['subjectId']!,
                                chapterId:
                                    state.pathParameters['chapterId']!,
                                questionId:
                                    state.pathParameters['questionId']!,
                              ),
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

          // ── Tab 2: Practice ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practiceConfig,
                pageBuilder: (ctx, state) =>
                    _fade(ctx, state, const PracticeConfigScreen()),
                routes: [
                  GoRoute(
                    path: 'session',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (ctx, state) => _slideRight(
                        ctx, state, const PracticeSessionScreen()),
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
                pageBuilder: (ctx, state) =>
                    _fade(ctx, state, const TestConfigScreen()),
                routes: [
                  GoRoute(
                    path: 'session',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (ctx, state) => _slideRight(
                        ctx, state, const TestSessionScreen()),
                  ),
                  GoRoute(
                    path: 'result/:resultId',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (ctx, state) => _slideRight(
                      ctx,
                      state,
                      ResultSummaryScreen(
                        resultId: state.pathParameters['resultId']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'review',
                        pageBuilder: (ctx, state) => _slideRight(
                          ctx,
                          state,
                          AnswerReviewScreen(
                            resultId: state.pathParameters['resultId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 4: Profile ───────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (ctx, state) =>
                    _fade(ctx, state, const ProfileScreen()),
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
