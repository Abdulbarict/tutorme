import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/question_model.dart';
import '../providers/practice_providers.dart';

// ── Header ────────────────────────────────────────────────────────────────────

class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.current,
    required this.total,
    required this.shuffleActive,
    required this.onExit,
    required this.onToggleShuffle,
  });

  final int current;
  final int total;
  final bool shuffleActive;
  final VoidCallback onExit;
  final VoidCallback onToggleShuffle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: onExit,
                child: Text('Exit',
                    style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
              Text(
                'Question $current of $total',
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy),
              ),
              const Spacer(),
              IconButton(
                onPressed: onToggleShuffle,
                icon: Icon(Icons.shuffle_rounded,
                    color: shuffleActive ? AppColors.gold : AppColors.textSecondary,
                    size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : current / total,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.navy),
            ),
          ),
          if (shuffleActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shuffle_rounded,
                      color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text('Shuffle ON',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.gold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.isRevealed,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  final QuestionModel question;
  final bool isRevealed;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final sessionLabel =
        '${question.session.name[0].toUpperCase()}${question.session.name.substring(1)} ${question.year} · ${question.marks} Mark${question.marks == 1 ? '' : 's'}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(sessionLabel,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onToggleBookmark();
                  },
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.gold : AppColors.textSecondary,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              question.question,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.navy,
                  height: 1.7),
            ),
            if (!isRevealed) ...[
              const SizedBox(height: AppSpacing.xxl),
              const DashedRevealBox(),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'Practice freely — no timer, no pressure.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.gold,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashedRevealBox extends StatelessWidget {
  const DashedRevealBox({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Tap to reveal answer',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final radius = Radius.circular(16);
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), radius);
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    double distance = 0;
    while (distance < metric.length) {
      canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}

// ── Answer section ────────────────────────────────────────────────────────────

class AnswerSection extends StatefulWidget {
  const AnswerSection({
    super.key,
    required this.question,
    required this.assessment,
    required this.onGotIt,
    required this.onNeedReview,
  });

  final QuestionModel question;
  final SelfAssessment? assessment;
  final VoidCallback onGotIt;
  final VoidCallback onNeedReview;

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  bool _mistakesExpanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solution = widget.question.solution ?? '';
    final steps = widget.question.solutionSteps;
    final answerText = solution.isNotEmpty
        ? solution
        : steps.isNotEmpty
            ? steps.join('\n\n')
            : 'See textbook for the model answer.';

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _ctrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answer card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border(
                    left: BorderSide(color: AppColors.success, width: 4)),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓  Model Answer',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                  const SizedBox(height: 8),
                  Text(answerText,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Common mistakes / explanation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.amberLight,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border(
                    left: BorderSide(color: AppColors.warning, width: 4)),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _mistakesExpanded,
                  onExpansionChanged: (v) =>
                      setState(() => _mistakesExpanded = v),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  title: Text('💡  Common Mistakes',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Text(
                        'Review the concepts carefully and compare with the model answer. Note where your reasoning differed.',
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Self-assessment
            _SelfAssessmentRow(
              assessment: widget.assessment,
              onGotIt: widget.onGotIt,
              onNeedReview: () {
                setState(() => _mistakesExpanded = true);
                widget.onNeedReview();
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SelfAssessmentRow extends StatelessWidget {
  const _SelfAssessmentRow({
    required this.assessment,
    required this.onGotIt,
    required this.onNeedReview,
  });

  final SelfAssessment? assessment;
  final VoidCallback onGotIt;
  final VoidCallback onNeedReview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text('How did you do?',
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child: _AssessCard(
                label: 'Need Review',
                icon: '✗',
                selected: assessment == SelfAssessment.needReview,
                selectedColor: AppColors.error,
                onTap: onNeedReview,
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: _AssessCard(
                label: 'Got It!',
                icon: '✓',
                selected: assessment == SelfAssessment.gotIt,
                selectedColor: AppColors.success,
                onTap: onGotIt,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssessCard extends StatelessWidget {
  const _AssessCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
              color: selected ? selectedColor : AppColors.border,
              width: 1.5),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon,
                style: TextStyle(
                    fontSize: 28,
                    color: selected ? Colors.white : selectedColor,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : selectedColor)),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────

class SessionBottomNav extends StatelessWidget {
  const SessionBottomNav({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.canGoPrev,
    required this.isAssessed,
    required this.isLastQuestion,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canGoPrev;
  final bool isAssessed;
  final bool isLastQuestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: canGoPrev ? onPrev : null,
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
            label: const Text('Prev'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: BorderSide(
                  color: canGoPrev ? AppColors.navy : AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Spacer(),
          if (isAssessed)
            OutlinedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              label: Text(isLastQuestion ? 'Finish' : 'Next'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else
            Text(
              'Assess yourself to continue',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

// ── Session complete ──────────────────────────────────────────────────────────

class SessionCompleteView extends StatelessWidget {
  const SessionCompleteView({
    super.key,
    required this.total,
    required this.gotItCount,
    required this.needReviewCount,
    required this.onReviewWeak,
    required this.onBack,
    required this.onPracticeAgain,
  });

  final int total;
  final int gotItCount;
  final int needReviewCount;
  final VoidCallback onReviewWeak;
  final VoidCallback onBack;
  final VoidCallback onPracticeAgain;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxxxl),
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.lg),
          Text('Session Complete!',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('You practiced $total question${total == 1 ? '' : 's'}.',
              style: GoogleFonts.dmSans(
                  fontSize: 15, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  count: gotItCount,
                  label: 'Got It',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ResultTile(
                  count: needReviewCount,
                  label: 'Need Review',
                  icon: Icons.refresh_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (needReviewCount > 0) ...[
            AppButton.secondary(
              label: 'Review Weak Questions',
              onPressed: onReviewWeak,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton.ghost(label: 'Back to Chapter', onPressed: onBack),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onPracticeAgain,
            child: Text('Practice Again (Shuffled)',
                style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text('$count',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9))),
        ],
      ),
    );
  }
}

// ── Progress bottom sheet ─────────────────────────────────────────────────────

class ProgressBottomSheet extends StatelessWidget {
  const ProgressBottomSheet({
    super.key,
    required this.state,
    required this.onGoToQuestion,
    required this.onReset,
  });

  final PracticeSessionState state;
  final ValueChanged<int> onGoToQuestion;
  final VoidCallback onReset;

  Color _colorFor(int index) {
    if (index == state.currentIndex) return AppColors.navy;
    final q = state.questions[index];
    final a = state.assessments[q.id];
    if (a == SelfAssessment.gotIt) return AppColors.success;
    if (a == SelfAssessment.needReview) return AppColors.error;
    if (state.revealedIndices.contains(index)) {
      return AppColors.navy.withValues(alpha: 0.5);
    }
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.6,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: AppShadow.modal,
        ),
        child: ListView(
          controller: scrollCtrl,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text('Your Progress',
                      style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy)),
                  const Spacer(),
                  TextButton(
                    onPressed: onReset,
                    child: Text('Reset Session',
                        style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.questions.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => onGoToQuestion(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _colorFor(i),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
