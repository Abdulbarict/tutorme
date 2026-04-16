import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

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

class _QuestionDetailScreenState
    extends ConsumerState<QuestionDetailScreen> {
  bool _showSolution = false;
  int? _selectedOption;
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final questionAsync = ref.watch(questionProvider(
      widget.subjectId,
      widget.chapterId,
      widget.questionId,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
              color: _bookmarked ? AppColors.gold : AppColors.textSecondary,
            ),
            onPressed: () async {
              final newState = await ref
                  .read(userServiceProvider)
                  .toggleBookmark(widget.questionId, _bookmarked);
              setState(() => _bookmarked = newState);
            },
          ),
        ],
      ),
      body: questionAsync.when(
        loading: () => const _QuestionDetailSkeleton(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (question) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta badges
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppBadge.year(label: question.sessionDisplay),
                  AppBadge.marks(label: '${question.marks} Marks'),
                  if (question.difficulty != null)
                    AppBadge.status(
                      label: question.difficulty!.toUpperCase(),
                      backgroundColor: _diffColor(question.difficulty!),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Question text
              AppCard(
                child: Text(question.question,
                    style: AppTextStyles.bodyLarge),
              ),
              const SizedBox(height: AppSpacing.lg),

              // MCQ Options
              if (question.options.isNotEmpty) ...[
                Text('Select your answer:',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.md),
                ...List.generate(question.options.length, (i) {
                  final isSelected = _selectedOption == i;
                  final isCorrect = i == question.correctAnswerIndex;
                  final showResult = _showSolution;

                  Color borderColor = AppColors.border;
                  Color bgColor = AppColors.surface;
                  if (showResult && isSelected) {
                    borderColor = isCorrect
                        ? AppColors.success
                        : AppColors.error;
                    bgColor = isCorrect
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.error.withValues(alpha: 0.08);
                  } else if (showResult && isCorrect) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withValues(alpha: 0.08);
                  } else if (isSelected) {
                    borderColor = AppColors.navy;
                    bgColor = AppColors.lightBlueTint;
                  }

                  return GestureDetector(
                    onTap: _showSolution
                        ? null
                        : () => setState(() => _selectedOption = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius:
                            BorderRadius.circular(AppRadius.input),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.navy
                                  : AppColors.border,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: AppTextStyles.labelBold.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(question.options[i],
                                style: AppTextStyles.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Solution toggle
              AppButton.secondary(
                label: _showSolution ? 'Hide Solution' : 'View Solution',
                onPressed: () =>
                    setState(() => _showSolution = !_showSolution),
              ),

              // Solution content
              if (_showSolution && question.solution != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  borderLeft: AppColors.success,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solution',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.success,
                          )),
                      const SizedBox(height: AppSpacing.md),
                      Text(question.solution!,
                          style: AppTextStyles.bodyMedium),
                      if (question.solutionSteps.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        ...question.solutionSteps.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('${e.key + 1}. ',
                                        style: AppTextStyles.labelBold
                                            .copyWith(
                                                color: AppColors.gold)),
                                    Expanded(
                                      child: Text(e.value,
                                          style: AppTextStyles.bodyMedium),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxxl),
            ],
          ),
        ),
      ),
    );
  }

  Color _diffColor(String difficulty) => switch (difficulty.toLowerCase()) {
        'easy' => AppColors.success,
        'hard' => AppColors.error,
        _ => AppColors.warning,
      };
}

class _QuestionDetailSkeleton extends StatelessWidget {
  const _QuestionDetailSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppLoading.textLine(height: 24),
            const SizedBox(height: AppSpacing.lg),
            AppLoading.card(),
          ],
        ),
      );
}
