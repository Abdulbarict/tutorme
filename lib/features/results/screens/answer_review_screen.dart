import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/question_model.dart';
import '../../../models/result_model.dart';
import '../providers/result_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter enum
// ─────────────────────────────────────────────────────────────────────────────

enum ReviewFilter { all, correct, wrong, notAttempted }

extension ReviewFilterX on ReviewFilter {
  String get label => switch (this) {
        ReviewFilter.all => 'All Questions',
        ReviewFilter.correct => 'Correct ✓',
        ReviewFilter.wrong => 'Wrong ✗',
        ReviewFilter.notAttempted => 'Not Attempted',
      };

  Color get activeColor => switch (this) {
        ReviewFilter.all => AppColors.navy,
        ReviewFilter.correct => AppColors.success,
        ReviewFilter.wrong => AppColors.error,
        ReviewFilter.notAttempted => AppColors.textSecondary,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// AnswerReviewScreen
// ─────────────────────────────────────────────────────────────────────────────

class AnswerReviewScreen extends ConsumerStatefulWidget {
  const AnswerReviewScreen({super.key, required this.resultId});
  final String resultId;

  @override
  ConsumerState<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends ConsumerState<AnswerReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;
  bool _wrongOnly = false;

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeResultProvider);

    if (activeState.isReady) {
      return _ReviewBody(
        result: activeState.result!,
        questions: activeState.questions,
        filter: _filter,
        wrongOnly: _wrongOnly,
        onFilterChanged: (f) => setState(() => _filter = f),
        onWrongOnlyChanged: (v) => setState(() {
          _wrongOnly = v;
          if (v) _filter = ReviewFilter.wrong;
        }),
      );
    }

    final resultAsync = ref.watch(resultByIdProvider(widget.resultId));
    final questionsAsync = ref.watch(resultQuestionsProvider(widget.resultId));

    return resultAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (result) => questionsAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        data: (questions) => _ReviewBody(
          result: result,
          questions: questions,
          filter: _filter,
          wrongOnly: _wrongOnly,
          onFilterChanged: (f) => setState(() => _filter = f),
          onWrongOnlyChanged: (v) => setState(() {
            _wrongOnly = v;
            if (v) _filter = ReviewFilter.wrong;
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReviewBody
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewBody extends StatelessWidget {
  const _ReviewBody({
    required this.result,
    required this.questions,
    required this.filter,
    required this.wrongOnly,
    required this.onFilterChanged,
    required this.onWrongOnlyChanged,
  });

  final ResultModel result;
  final List<QuestionModel> questions;
  final ReviewFilter filter;
  final bool wrongOnly;
  final ValueChanged<ReviewFilter> onFilterChanged;
  final ValueChanged<bool> onWrongOnlyChanged;

  bool _isCorrect(QuestionModel q) =>
      result.selectedAnswers[q.id] != null &&
      result.selectedAnswers[q.id] == result.correctAnswers[q.id];

  bool _isNotAttempted(QuestionModel q) =>
      result.selectedAnswers[q.id] == null;

  bool _isWrong(QuestionModel q) =>
      !_isCorrect(q) && !_isNotAttempted(q);

  List<QuestionModel> get _filtered => questions.where((q) {
        if (filter == ReviewFilter.correct) return _isCorrect(q);
        if (filter == ReviewFilter.wrong) return _isWrong(q);
        if (filter == ReviewFilter.notAttempted) return _isNotAttempted(q);
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final correctCount = questions.where(_isCorrect).length;
    final wrongCount = questions.where(_isWrong).length;
    final skippedCount = questions.where(_isNotAttempted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Custom App Bar ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: AppColors.navy, size: 20),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Answer Review',
                          style: AppTextStyles.headingSmall,
                        ),
                        const Spacer(),
                        Text(
                          '${filtered.length}/${questions.length}',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: wrongOnly,
                            onChanged: onWrongOnlyChanged,
                            activeThumbColor: AppColors.gold,
                            activeTrackColor: AppColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        Text('Wrong Only',
                            style: AppTextStyles.caption.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),

                  // Filter chips
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: 6),
                      children: ReviewFilter.values.map((f) {
                        final selected = filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => onFilterChanged(f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? f.activeColor
                                    : AppColors.surface,
                                border: Border.all(
                                  color: selected
                                      ? f.activeColor
                                      : AppColors.border,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Text(
                                f.label,
                                style: GoogleFonts.dmSans(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                ],
              ),
            ),
          ),

          // ── Question List ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No questions in this category.',
                        style: AppTextStyles.bodySmall))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final q = filtered[i];
                      final globalIndex =
                          questions.indexOf(q);
                      if (_isCorrect(q)) {
                        return _CorrectCard(
                          q: q,
                          questionNumber: globalIndex + 1,
                          result: result,
                        );
                      } else if (_isNotAttempted(q)) {
                        return _NotAttemptedCard(
                          q: q,
                          questionNumber: globalIndex + 1,
                        );
                      } else {
                        return _WrongCard(
                          q: q,
                          questionNumber: globalIndex + 1,
                          result: result,
                        );
                      }
                    },
                  ),
          ),

          // ── Bottom Summary Bar ───────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border:
                  Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    _SummaryCount(
                        value: correctCount,
                        label: 'Correct',
                        color: AppColors.success),
                    Container(
                        width: 1,
                        height: 32,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md)),
                    _SummaryCount(
                        value: wrongCount,
                        label: 'Wrong',
                        color: AppColors.error),
                    Container(
                        width: 1,
                        height: 32,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md)),
                    _SummaryCount(
                        value: skippedCount,
                        label: 'Skipped',
                        color: AppColors.textSecondary),
                    const Spacer(),
                    AppButton.primary(
                      label: 'Done',
                      onPressed: () => context.go(AppRoutes.home),
                      fullWidth: false,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary count widget
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCount extends StatelessWidget {
  const _SummaryCount(
      {required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: GoogleFonts.dmSans(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label,
            style:
                GoogleFonts.dmSans(color: color, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: option label for MCQ (A, B, C, D…)
// ─────────────────────────────────────────────────────────────────────────────

String _optionLabel(QuestionModel q, int? idx) {
  if (idx == null) return 'Not attempted';
  if (q.options.isEmpty || idx >= q.options.length) return 'Option $idx';
  final labels = ['A', 'B', 'C', 'D', 'E'];
  final prefix = idx < labels.length ? '${labels[idx]}. ' : '';
  return '$prefix${q.options[idx]}';
}

String _correctLabel(QuestionModel q, ResultModel result) {
  final idx = result.correctAnswers[q.id];
  if (idx == null) return q.solution ?? 'See model answer';
  return _optionLabel(q, idx);
}

// ─────────────────────────────────────────────────────────────────────────────
// Correct Question Card
// ─────────────────────────────────────────────────────────────────────────────

class _CorrectCard extends StatefulWidget {
  const _CorrectCard(
      {required this.q,
      required this.questionNumber,
      required this.result});
  final QuestionModel q;
  final int questionNumber;
  final ResultModel result;

  @override
  State<_CorrectCard> createState() => _CorrectCardState();
}

class _CorrectCardState extends State<_CorrectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderLeft: AppColors.success,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Q${widget.questionNumber}',
                style: AppTextStyles.caption),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('✓ Correct',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(widget.q.question,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.navy),
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? null : TextOverflow.ellipsis),
          if (!_expanded)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Text('Read more',
                  style: GoogleFonts.dmSans(
                      color: AppColors.gold, fontSize: 13)),
            ),
          const SizedBox(height: 8),

          // Your Answer
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Row(children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text('Your Answer',
                  style: GoogleFonts.dmSans(
                      color: AppColors.success, fontSize: 14)),
            ]),
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF5),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                    _optionLabel(widget.q,
                        widget.result.selectedAnswers[widget.q.id]),
                    style: AppTextStyles.bodyMedium),
              ),
            ],
          ),

          // Model Answer
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text('Model Answer',
                style: GoogleFonts.dmSans(
                    color: AppColors.success, fontSize: 14)),
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF5),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                    _correctLabel(widget.q, widget.result),
                    style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrong Question Card
// ─────────────────────────────────────────────────────────────────────────────

class _WrongCard extends StatelessWidget {
  const _WrongCard(
      {required this.q,
      required this.questionNumber,
      required this.result});
  final QuestionModel q;
  final int questionNumber;
  final ResultModel result;

  @override
  Widget build(BuildContext context) {
    final explanation = q.solution ?? '';
    return AppCard(
      borderLeft: AppColors.error,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Q$questionNumber', style: AppTextStyles.caption),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('✗ Incorrect',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(q.question,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.navy),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),

          // Student Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Answer:',
                    style: GoogleFonts.dmSans(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    result.selectedAnswers[q.id] != null
                        ? _optionLabel(q, result.selectedAnswers[q.id])
                        : 'Not attempted',
                    style: result.selectedAnswers[q.id] != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Model Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF0FAF5),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ Model Answer:',
                    style: GoogleFonts.dmSans(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_correctLabel(q, result),
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Explanation Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amberLight,
              border: const Border(
                  left: BorderSide(color: AppColors.warning, width: 4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Common Mistakes & Examiner Tips',
                      style: GoogleFonts.dmSans(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  explanation.isNotEmpty
                      ? explanation
                      : 'No explanation available for this question.',
                  style: explanation.isNotEmpty
                      ? AppTextStyles.bodyMedium.copyWith(height: 1.6)
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action buttons
          Row(children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_add_outlined,
                  size: 16, color: AppColors.navy),
              label: Text('Bookmark',
                  style: GoogleFonts.dmSans(
                      color: AppColors.navy, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16, color: AppColors.gold),
              label: Text('Practice Again',
                  style: GoogleFonts.dmSans(
                      color: AppColors.gold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Not Attempted Card
// ─────────────────────────────────────────────────────────────────────────────

class _NotAttemptedCard extends StatelessWidget {
  const _NotAttemptedCard(
      {required this.q, required this.questionNumber});
  final QuestionModel q;
  final int questionNumber;

  @override
  Widget build(BuildContext context) {
    final explanation = q.solution ?? '';
    return AppCard(
      borderLeft: AppColors.textSecondary,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Q$questionNumber', style: AppTextStyles.caption),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('— Not Attempted',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(q.question,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),

          // Model Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF0FAF5),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ Model Answer:',
                    style: GoogleFonts.dmSans(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  q.options.isNotEmpty
                      ? _optionLabel(q, q.correctAnswerIndex)
                      : q.solution ?? 'See model answer',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amberLight,
              border: const Border(
                  left: BorderSide(color: AppColors.warning, width: 4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Common Mistakes & Examiner Tips',
                      style: GoogleFonts.dmSans(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  explanation.isNotEmpty
                      ? explanation
                      : 'No explanation available for this question.',
                  style: explanation.isNotEmpty
                      ? AppTextStyles.bodyMedium.copyWith(height: 1.6)
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_add_outlined,
                size: 16, color: AppColors.navy),
            label: Text('Bookmark',
                style: GoogleFonts.dmSans(
                    color: AppColors.navy, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.navy),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
