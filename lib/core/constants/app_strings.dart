/// App-wide string constants.
///
/// Keep all user-facing copy here so it's easy to localise later.
class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────────────────────────────────
  static const appName = 'TutorMe';
  static const appTagline = 'CMA Exam Preparation Made Simple';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const login = 'Log In';
  static const signup = 'Sign Up';
  static const logout = 'Log Out';
  static const email = 'Email';
  static const password = 'Password';
  static const confirmPassword = 'Confirm Password';
  static const fullName = 'Full Name';
  static const forgotPassword = 'Forgot Password?';
  static const dontHaveAccount = "Don't have an account?";
  static const alreadyHaveAccount = 'Already have an account?';
  static const orContinueWith = 'Or continue with';
  static const continueWithGoogle = 'Continue with Google';
  static const enterOtp = 'Enter OTP';
  static const verifyOtp = 'Verify';
  static const resendOtp = 'Resend OTP';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const onboardingTitle1 = 'Master CMA with Confidence';
  static const onboardingBody1 =
      'Access 10,000+ past paper questions crafted for Foundation & Intermediate levels.';
  static const onboardingTitle2 = 'Smart Practice & Mock Tests';
  static const onboardingBody2 =
      'Simulate real exam conditions, track performance, and identify weak chapters.';
  static const onboardingTitle3 = 'Detailed Answer Analysis';
  static const onboardingBody3 =
      'Every question comes with a step-by-step solution aligned to ICMAI guidelines.';
  static const getStarted = 'Get Started';
  static const nextStep = 'Next';
  static const skip = 'Skip';

  // ── Home ─────────────────────────────────────────────────────────────────
  static const home = 'Home';
  static const subjects = 'Subjects';
  static const practice = 'Practice';
  static const tests = 'Tests';
  static const progress = 'Progress';
  static const bookmarks = 'Bookmarks';
  static const profile = 'Profile';

  // ── Levels ────────────────────────────────────────────────────────────────
  static const foundation = 'Foundation';
  static const intermediate = 'Intermediate';
  static const final_ = 'Final';
  static const selectLevel = 'Select Your Level';
  static const levelSelectBody =
      'Choose the CMA level you are currently preparing for.';

  // ── Subjects ─────────────────────────────────────────────────────────────
  static const allSubjects = 'All Subjects';
  static const chapters = 'Chapters';
  static const questions = 'Questions';
  static const noSubjectsFound = 'No Subjects Found';
  static const noSubjectsBody =
      'Subjects will appear here once we load your level content.';

  // ── Questions ────────────────────────────────────────────────────────────
  static const questionDetail = 'Question';
  static const viewSolution = 'View Solution';
  static const hideSolution = 'Hide Solution';
  static const bookmark = 'Bookmark';
  static const removeBookmark = 'Remove Bookmark';
  static const reportQuestion = 'Report';
  static const noQuestionsFound = 'No Questions Found';
  static const noQuestionsBody =
      'Try selecting a different chapter or filter.';

  // ── Practice ─────────────────────────────────────────────────────────────
  static const configurePractice = 'Configure Practice';
  static const startPractice = 'Start Practice';
  static const practiceComplete = 'Practice Complete!';
  static const questionsAttempted = 'Questions Attempted';

  // ── Test ─────────────────────────────────────────────────────────────────
  static const configureTest = 'Configure Test';
  static const startTest = 'Start Test';
  static const submitTest = 'Submit Test';
  static const testComplete = 'Test Complete!';
  static const score = 'Score';
  static const timeTaken = 'Time Taken';
  static const accuracy = 'Accuracy';

  // ── Progress ─────────────────────────────────────────────────────────────
  static const myProgress = 'My Progress';
  static const overallAccuracy = 'Overall Accuracy';
  static const totalAttempted = 'Total Attempted';
  static const strongChapters = 'Strong Chapters';
  static const weakChapters = 'Weak Chapters';

  // ── Generic ──────────────────────────────────────────────────────────────
  static const retry = 'Retry';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const save = 'Save';
  static const done = 'Done';
  static const loading = 'Loading…';
  static const error = 'Something went wrong';
  static const networkError = 'Check your internet connection and try again.';
  static const unknownError = 'An unexpected error occurred.';
}
