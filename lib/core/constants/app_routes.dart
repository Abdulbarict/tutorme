/// Named route paths — kept in sync with [AppRouter].
///
/// Always reference these constants instead of hard-coding path strings.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const levelSelect = '/level-select';

  // ── Shell ────────────────────────────────────────────────────────────────
  static const home = '/home';

  // ── Subjects branch ──────────────────────────────────────────────────────
  static const subjects = '/home/subjects';

  static String chapters(String subjectId) =>
      '/home/subjects/$subjectId/chapters';

  static String questions(String subjectId, String chapterId) =>
      '/home/subjects/$subjectId/chapters/$chapterId/questions';

  static String questionDetail(
          String subjectId, String chapterId, String questionId) =>
      '/home/subjects/$subjectId/chapters/$chapterId/questions/$questionId';

  // ── Practice branch ───────────────────────────────────────────────────────
  static const practiceConfig = '/home/practice';
  static const practiceSession = '/home/practice/session';

  // ── Test branch ───────────────────────────────────────────────────────────
  static const testConfig = '/home/test';
  static const testSession = '/home/test/session';

  static String testResult(String resultId) =>
      '/home/test/result/$resultId';

  static String testResultReview(String resultId) =>
      '/home/test/result/$resultId/review';

  // ── Profile tab ───────────────────────────────────────────────────────────
  static const profile = '/home/profile';

  // ── Full-screen overlays (above the shell, no bottom nav shown) ───────────
  // These live at /home/bookmarks and /home/progress so that Quick Actions
  // from the Home tab navigate here without switching to the Profile tab.
  static const progress = '/home/progress';
  static const bookmarks = '/home/bookmarks';
}
