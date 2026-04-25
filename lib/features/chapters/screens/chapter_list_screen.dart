import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../providers/chapter_providers.dart';

class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectProvider(subjectId));
    final chaptersAsync = ref.watch(chaptersProvider(subjectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.navy),
        title: subjectAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
          data: (subject) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.navy,
                  fontSize: 16,
                ),
              ),
              Text(
                'CMA ${subject.level.displayName}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.navy),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.navy),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: subjectAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (subject) => _SubjectBanner(subject: subject),
            ),
          ),
          SliverToBoxAdapter(
            child: chaptersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (chapters) {
                // Determine how many chapters are started using progress provider
                final progressMapAsync = ref.watch(userChapterProgressProvider(subjectId));
                final progressMap = progressMapAsync.valueOrNull ?? {};

                int started = 0;
                for (final chapter in chapters) {
                  final prog = progressMap[chapter.id];
                  if (prog != null && prog.answeredQuestions > 0) {
                    started++;
                  }
                }

                final progressRatio = chapters.isEmpty ? 0.0 : started / chapters.length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$started of ${chapters.length} chapters started',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.navy),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          chaptersAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 5),
                  child: AppLoading.listItem(),
                ),
                childCount: 6,
              ),
            ),
            error: (e, __) => SliverToBoxAdapter(
              child: AppEmptyState(
                heading: 'Error Loading Chapters',
                body: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(chaptersProvider(subjectId)),
              ),
            ),
            data: (chapters) {
              if (chapters.isEmpty) {
                return const SliverToBoxAdapter(
                  child: AppEmptyState(
                    heading: 'No Chapters Found',
                    body: 'Content for this subject will be added soon.',
                  ),
                );
              }

              final colors = [
                const Color(0xFF1565C0),
                const Color(0xFF00695C),
                const Color(0xFF6A1B9A),
                const Color(0xFFE65100),
                const Color(0xFF558B2F),
                const Color(0xFF37474F),
                const Color(0xFFC62828),
                const Color(0xFF283593),
              ];

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    final color = colors[index % colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: _ChapterCard(
                        subjectId: subjectId,
                        chapter: chapter,
                        subjectColor: color,
                      ),
                    );
                  },
                  childCount: chapters.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

class _SubjectBanner extends StatelessWidget {
  const _SubjectBanner({required this.subject});

  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code.isEmpty ? 'CMA' : subject.code,
                  style: AppTextStyles.monospace.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.totalChapters} Chapters',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.totalQuestions} Total Questions',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your Accuracy',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '62%',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.trending_up,
                      color: AppColors.gold, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends ConsumerWidget {
  const _ChapterCard({
    required this.subjectId,
    required this.chapter,
    required this.subjectColor,
  });

  final String subjectId;
  final ChapterModel chapter;
  final Color subjectColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressMapAsync = ref.watch(userChapterProgressProvider(subjectId));
    final progressMap = progressMapAsync.valueOrNull ?? {};
    final prog = progressMap[chapter.id];

    final int practiced = prog?.answeredQuestions ?? 0;
    // For calculating ratio, ensure we don't divide by 0
    final int total = prog?.totalQuestions ?? (chapter.totalQuestions > 0 ? chapter.totalQuestions : 1);
    final double progress = (total == 0) ? 0.0 : practiced / total;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () =>
          context.go(AppRoutes.questions(subjectId, chapter.id)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${chapter.number}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.name,
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chapter.totalQuestions} Questions · All Years',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (progress >= 1.0)
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20)
              else if (progress <= 0)
                OutlinedButton(
                  onPressed: () =>
                      context.go(AppRoutes.questions(subjectId, chapter.id)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: AppTextStyles.labelBold
                        .copyWith(color: AppColors.gold, fontSize: 13),
                  ),
                )
              else
                Text(
                  '$practiced/$total',
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (progress > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 4,
              ),
            )
          else
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
