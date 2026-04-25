import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Shimmer skeleton for a single card row (3 text lines).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < lines; i++) ...[
              Container(
                height: 14,
                width: i == 0 ? double.infinity : 200,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (i < lines - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton list — [count] cards stacked vertically.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 5, this.lines = 3});

  final int count;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => SkeletonCard(lines: lines),
    );
  }
}

/// Shimmer skeleton for the HomeScreen hero card + 4-item grid.
class SkeletonHome extends StatelessWidget {
  const SkeletonHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // Section title
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            // 2x2 grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(16),
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

/// Shimmer skeleton for the SubjectListScreen — 5 cards.
class SkeletonSubjectList extends StatelessWidget {
  const SkeletonSubjectList({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(count: 5, lines: 2);
}

/// Shimmer skeleton for the QuestionListScreen — 6 cards with 3 lines.
class SkeletonQuestionList extends StatelessWidget {
  const SkeletonQuestionList({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(count: 6, lines: 3);
}
