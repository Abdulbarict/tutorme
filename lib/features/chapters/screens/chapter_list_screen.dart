import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../services/firestore_service.dart';

class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key, required this.subjectId});
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider(subjectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: chaptersAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => AppLoading.listItem(),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chapters) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: chapters.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) {
            final ch = chapters[i];
            return AppCard(
              onTap: () => context.go(
                  '/home/subjects/$subjectId/chapters/${ch.id}/questions'),
              borderLeft: AppColors.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chapter ${ch.number}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.gold)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(ch.name, style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${ch.totalQuestions} questions',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
