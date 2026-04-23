import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';
import '../providers/question_providers.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  const QuestionDetailScreen({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.questionId,
  });

  final String subjectId;
  final String chapterId;
  final String questionId;

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _answerRevealed = false;
  bool _explanationExpanded = false;
  bool _markingPracticed = false;

  // Animated button color for "Mark as Practiced"
  late AnimationController _practiceAnim;
  late Animation<Color?> _practiceColor;

  @override
  void initState() {
    super.initState();
    _practiceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _practiceColor = ColorTween(
      begin: AppColors.navy,
      end: AppColors.success,
    ).animate(CurvedAnimation(parent: _practiceAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _practiceAnim.dispose();
    super.dispose();
  }

  Future<void> _markPracticed(String questionId) async {
    if (_markingPracticed) return;
    setState(() => _markingPracticed = true);
    await ref.read(userServiceProvider).markAsPracticed([questionId]);
    await _practiceAnim.forward();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Marked as practiced!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToQuestion(
      List<QuestionModel> allQuestions, int currentIndex, int delta) {
    final next = currentIndex + delta;
    if (next < 0 || next >= allQuestions.length) return;
    context.go(AppRoutes.questionDetail(
      widget.subjectId,
      widget.chapterId,
      allQuestions[next].id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final questionAsync = ref.watch(questionProvider(
        widget.subjectId, widget.chapterId, widget.questionId));
    final allQuestionsAsync = ref.watch(
        chapterQuestionsProvider(widget.subjectId, widget.chapterId));
    final bookmarkedIds =
        ref.watch(userBookmarkIdsProvider).valueOrNull ?? {};
    final practicedIds =
        ref.watch(userPracticedIdsProvider).valueOrNull ?? {};

    final isBookmarked = bookmarkedIds.contains(widget.questionId);
    final isPracticed = practicedIds.contains(widget.questionId);

    final allQuestions = allQuestionsAsync.valueOrNull ?? [];
    final currentIndex =
        allQuestions.indexWhere((q) => q.id == widget.questionId);
    final questionNumber = currentIndex == -1 ? 1 : currentIndex + 1;

    // Reset animation when practiced state changes externally
    if (isPracticed && _practiceAnim.value == 0 && !_markingPracticed) {
      _practiceAnim.value = 1.0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.navy),
        title: questionAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('Question'),
          data: (q) => Text(
            'Q$questionNumber · ${q.session.name[0].toUpperCase()}${q.session.name.substring(1)} ${q.year}',
            style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.navy, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppColors.gold : AppColors.navy,
            ),
            onPressed: () => ref
                .read(userServiceProvider)
                .toggleBookmark(widget.questionId, isBookmarked),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.navy),
            onPressed: () {},
          ),
        ],
      ),
      body: questionAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (question) => Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meta badges ────────────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _OutlinedChip(
                          label: question.sessionDisplay,
                          color: AppColors.navy),
                      _FilledChip(
                          label: '${question.marks} Marks',
                          bg: AppColors.gold,
                          fg: Colors.white),
                      _FilledChip(
                          label: 'CMA Inter',
                          bg: AppColors.border,
                          fg: AppColors.textSecondary),
                      _FilledChip(
                          label: question.type == QuestionType.descriptive
                              ? 'Descriptive'
                              : 'MCQ',
                          bg: AppColors.lightBlueTint,
                          fg: AppColors.navy),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Question card ──────────────────────────────────────────
                  AppCard(
                    borderLeft: AppColors.navy,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'QUESTION',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.navy,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${question.marks}M',
                                style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          question.question,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Model Answer card ──────────────────────────────────────
                  _AnswerCard(
                    question: question,
                    isRevealed: _answerRevealed,
                    isPracticed: isPracticed,
                    markingPracticed: _markingPracticed,
                    practiceColor: _practiceColor,
                    onReveal: () => setState(() => _answerRevealed = true),
                    onCollapse: () => setState(() => _answerRevealed = false),
                    onMarkPracticed: () => _markPracticed(question.id),
                  ),
                  const SizedBox(height: 12),

                  // ── Wrong answer explanation ────────────────────────────────
                  if ((question.tags.isNotEmpty))
                    _ExplanationCard(
                      explanation: question.tags.join('\n• '),
                      isExpanded: _explanationExpanded,
                      onToggle: () => setState(
                          () => _explanationExpanded = !_explanationExpanded),
                    ),

                  // ── Bookmark reminder ──────────────────────────────────────
                  if (isBookmarked) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.navy.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Text('📌',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Saved to Bookmarks',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.navy, fontSize: 13),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(userServiceProvider)
                                .toggleBookmark(widget.questionId, true),
                            child: Text(
                              'Remove',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Fixed bottom action bar ────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomActionBar(
                isPracticed: isPracticed,
                markingPracticed: _markingPracticed,
                practiceColor: _practiceColor,
                hasPrev: currentIndex > 0,
                hasNext: currentIndex < allQuestions.length - 1,
                onPrev: () =>
                    _navigateToQuestion(allQuestions, currentIndex, -1),
                onNext: () =>
                    _navigateToQuestion(allQuestions, currentIndex, 1),
                onMarkPracticed: () => _markPracticed(question.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Answer Card (animated reveal)
// ─────────────────────────────────────────────────────────────────────────────

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.question,
    required this.isRevealed,
    required this.isPracticed,
    required this.markingPracticed,
    required this.practiceColor,
    required this.onReveal,
    required this.onCollapse,
    required this.onMarkPracticed,
  });

  final QuestionModel question;
  final bool isRevealed;
  final bool isPracticed;
  final bool markingPracticed;
  final Animation<Color?> practiceColor;
  final VoidCallback onReveal;
  final VoidCallback onCollapse;
  final VoidCallback onMarkPracticed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderLeft: AppColors.success,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: isRevealed ? onCollapse : null,
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  isRevealed ? '✓ Model Answer' : 'Model Answer',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.success, fontSize: 15),
                ),
                const Spacer(),
                Icon(
                  isRevealed
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          // Animated cross-fade between collapsed / expanded
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: isRevealed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: onReveal,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.navyGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Reveal Answer',
                      style: AppTextStyles.buttonLabel,
                    ),
                  ),
                ),
              ),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Answer text or solution steps
                if (question.solution != null)
                  Text(
                    question.solution!,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary, height: 1.7),
                  )
                else if (question.solutionSteps.isNotEmpty)
                  ...question.solutionSteps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}. ',
                                style: AppTextStyles.labelBold
                                    .copyWith(color: AppColors.gold)),
                            Expanded(
                              child: Text(e.value,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(height: 1.6)),
                            ),
                          ],
                        ),
                      ))
                else
                  Text(
                    'No model answer available for this question.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 16),
                if (!isPracticed)
                  AnimatedBuilder(
                    animation: practiceColor,
                    builder: (_, __) => GestureDetector(
                      onTap: onMarkPracticed,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: practiceColor.value ?? AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Mark as Practiced ✓',
                            style: AppTextStyles.buttonLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrong Answer Explanation Card
// ─────────────────────────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.explanation,
    required this.isExpanded,
    required this.onToggle,
  });

  final String explanation;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.amberLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: AppColors.warning,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Common Mistakes & Examiner Tips',
                              style: AppTextStyles.headingSmall.copyWith(
                                  color: AppColors.warning, fontSize: 15),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                      if (!isExpanded) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to expand',
                          style: AppTextStyles.caption.copyWith(
                              fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      ],
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Text(
                          explanation,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary, height: 1.7),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '💡 This section helps you understand what examiners look for.',
                            style: AppTextStyles.caption.copyWith(
                                fontStyle: FontStyle.italic, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Action Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isPracticed,
    required this.markingPracticed,
    required this.practiceColor,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
    required this.onMarkPracticed,
  });

  final bool isPracticed;
  final bool markingPracticed;
  final Animation<Color?> practiceColor;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onMarkPracticed;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev button
          _NavBtn(
            icon: Icons.arrow_back_ios_rounded,
            label: 'Prev',
            color: AppColors.navy,
            enabled: hasPrev,
            onTap: onPrev,
          ),
          const SizedBox(width: 12),

          // Center practiced button
          Expanded(
            child: AnimatedBuilder(
              animation: practiceColor,
              builder: (_, __) => GestureDetector(
                onTap: isPracticed ? null : onMarkPracticed,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isPracticed
                        ? null
                        : AppColors.navyGradient,
                    color: isPracticed
                        ? AppColors.success.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: isPracticed
                        ? Border.all(color: AppColors.success, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: isPracticed
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: 18),
                              const SizedBox(width: 6),
                              Text('Practiced ✓',
                                  style: AppTextStyles.buttonLabel
                                      .copyWith(color: AppColors.success)),
                            ],
                          )
                        : Text('Mark Practiced',
                            style: AppTextStyles.buttonLabel),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Next button
          _NavBtn(
            icon: Icons.arrow_forward_ios_rounded,
            label: 'Next',
            color: AppColors.gold,
            enabled: hasNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        enabled ? color : AppColors.border;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveColor, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption
                .copyWith(color: effectiveColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip helpers
// ─────────────────────────────────────────────────────────────────────────────

class _OutlinedChip extends StatelessWidget {
  const _OutlinedChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: AppTextStyles.caption
                .copyWith(color: color, fontSize: 12)),
      );
}

class _FilledChip extends StatelessWidget {
  const _FilledChip(
      {required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: AppTextStyles.caption
                .copyWith(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppLoading.textLine(height: 20),
            const SizedBox(height: 16),
            AppLoading.card(),
            const SizedBox(height: 16),
            AppLoading.card(),
          ],
        ),
      );
}
