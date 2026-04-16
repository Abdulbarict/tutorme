import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../services/firestore_service.dart';

class QuestionListScreen extends ConsumerWidget {
  const QuestionListScreen({
    super.key,
    required this.subjectId,
    required this.chapterId,
  });

  final String subjectId;
  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync =
        ref.watch(questionsProvider(subjectId, chapterId));

    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: questionsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => AppLoading.listItem(),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (questions) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) {
            final q = questions[i];
            return AppCard(
              onTap: () => context.go(
                '/home/subjects/$subjectId/chapters/$chapterId/questions/${q.id}',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBadge.year(label: q.sessionDisplay),
                      const SizedBox(width: AppSpacing.sm),
                      AppBadge.marks(label: '${q.marks} Marks'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    q.question.length > 120
                        ? '${q.question.substring(0, 120)}…'
                        : q.question,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
