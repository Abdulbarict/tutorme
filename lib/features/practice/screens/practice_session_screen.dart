import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/question_model.dart';
import '../providers/practice_providers.dart';
import '../widgets/practice_session_widgets.dart';

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState
    extends ConsumerState<PracticeSessionScreen> {
  final _pageController = PageController();
  bool _initialized = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Init questions from config ─────────────────────────────────────────────

  void _initSession(PracticeConfig config, List<QuestionModel> questions) {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(practiceSessionProvider.notifier)
          .loadQuestions(questions, shuffle: config.shuffle);
    });
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goToIndex(int index) {
    ref.read(practiceSessionProvider.notifier).goToIndex(index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _next() {
    final state = ref.read(practiceSessionProvider);
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      ref.read(practiceSessionProvider.notifier).goToNext();
    } else {
      ref.read(practiceSessionProvider.notifier).goToNext();
      _pageController.animateToPage(nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  void _prev() {
    final state = ref.read(practiceSessionProvider);
    if (state.currentIndex == 0) return;
    ref.read(practiceSessionProvider.notifier).goToPrev();
    _pageController.animateToPage(state.currentIndex - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // ── Exit dialog ────────────────────────────────────────────────────────────

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Exit Practice?',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.navy)),
        content: Text(
            'Your progress will be lost if you exit now.',
            style: GoogleFonts.dmSans(
                fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Stay',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Exit',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(activePracticeConfigProvider);

    if (config == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: AppColors.navy, size: 48),
              const SizedBox(height: 16),
              Text('No session config found.',
                  style: GoogleFonts.dmSans(
                      fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              AppButton.ghost(
                  label: 'Go Back', onPressed: () => context.pop()),
            ],
          ),
        ),
      );
    }

    final questionsAsync = ref.watch(practiceSessionQuestionsProvider(
        config.subjectId, config.selectedChapterIds));

    return questionsAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (e, _) => _buildErrorScreen(e.toString()),
      data: (allQuestions) {
        _initSession(config, allQuestions);
        return _buildSession(config);
      },
    );
  }

  Widget _buildLoadingScreen() => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.navy),
              const SizedBox(height: 16),
              Text('Loading questions…',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      );

  Widget _buildErrorScreen(String error) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(error,
                    style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppButton.ghost(
                    label: 'Go Back', onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      );

  Widget _buildSession(PracticeConfig config) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(practiceSessionProvider);
      final notifier = ref.read(practiceSessionProvider.notifier);

      // Complete screen
      if (state.isComplete) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SessionCompleteView(
              total: state.questions.length,
              gotItCount: state.gotItCount,
              needReviewCount: state.needReviewCount,
              onReviewWeak: () => notifier.filterToNeedReview(),
              onBack: () => context.pop(),
              onPracticeAgain: () {
                notifier.loadQuestions(state.questions, shuffle: true);
                _pageController.jumpToPage(0);
              },
            ),
          ),
        );
      }

      if (state.questions.isEmpty) {
        return Scaffold(
          body: Center(
            child: Text('No questions found.',
                style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary, fontSize: 15)),
          ),
        );
      }

      final currentQ = state.currentQuestion!;
      final assessment = state.assessments[currentQ.id];
      final isAssessed = assessment != null;
      final isLast = state.currentIndex == state.questions.length - 1;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ────────────────────────────────────────────────
                  SessionHeader(
                    current: state.currentIndex + 1,
                    total: state.questions.length,
                    shuffleActive: state.shuffleActive,
                    onExit: _confirmExit,
                    onToggleShuffle: notifier.toggleShuffle,
                  ),
                  // ── Page content ──────────────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.questions.length,
                      onPageChanged: (i) =>
                          notifier.goToIndex(i),
                      itemBuilder: (_, index) {
                        final q = state.questions[index];
                        final revealed =
                            state.revealedIndices.contains(index);
                        final assess = state.assessments[q.id];
                        return _QuestionPage(
                          key: ValueKey(q.id),
                          question: q,
                          isRevealed: revealed,
                          assessment: assess,
                          onReveal: () => notifier.revealCurrent(),
                          onGotIt: () =>
                              notifier.assess(q.id, SelfAssessment.gotIt),
                          onNeedReview: () => notifier.assess(
                              q.id, SelfAssessment.needReview),
                        );
                      },
                    ),
                  ),
                  // ── Bottom nav ────────────────────────────────────────────
                  SessionBottomNav(
                    onPrev: _prev,
                    onNext: _next,
                    canGoPrev: state.currentIndex > 0,
                    isAssessed: isAssessed,
                    isLastQuestion: isLast,
                  ),
                  // Space for bottom sheet handle
                  const SizedBox(height: 32),
                ],
              ),
              // ── Progress bottom sheet ─────────────────────────────────────
              Positioned.fill(
                child: ProgressBottomSheet(
                  state: state,
                  onGoToQuestion: _goToIndex,
                  onReset: notifier.resetSession,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Single question page ──────────────────────────────────────────────────────

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    super.key,
    required this.question,
    required this.isRevealed,
    required this.assessment,
    required this.onReveal,
    required this.onGotIt,
    required this.onNeedReview,
  });

  final QuestionModel question;
  final bool isRevealed;
  final SelfAssessment? assessment;
  final VoidCallback onReveal;
  final VoidCallback onGotIt;
  final VoidCallback onNeedReview;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          QuestionCard(
            question: question,
            isRevealed: isRevealed,
            isBookmarked: false,
            onToggleBookmark: () {},
          ),
          if (!isRevealed)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: 4),
              child: AppButton.primary(
                label: 'Reveal Answer',
                height: 52,
                onPressed: onReveal,
              ),
            ),
          if (isRevealed)
            AnswerSection(
              question: question,
              assessment: assessment,
              onGotIt: onGotIt,
              onNeedReview: onNeedReview,
            ),
        ],
      ),
    );
  }
}
