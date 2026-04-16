import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/models.dart';
import '../providers/home_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Home Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final statsAsync = ref.watch(homeStatsProvider);
    final continueAsync = ref.watch(continueLearningProvider);
    final questionsAsync = ref.watch(recentQuestionsProvider);
    final hasNotifs = ref.watch(hasNotificationsProvider);

    // FIX S5: Use AnnotatedRegion instead of SystemChrome.setSystemUIOverlayStyle
    // directly in build(). The direct call fires on every frame rebuild;
    // AnnotatedRegion is declarative and only updates when the value changes.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: () async {
          ref.invalidate(homeStatsProvider);
          ref.invalidate(continueLearningProvider);
          ref.invalidate(recentQuestionsProvider);
          ref.invalidate(currentUserProfileProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HomeHeader(
                userAsync: userAsync,
                hasNotifications: hasNotifs,
              ),
            ),

            // ── Hero Stats Card + Streak Banner ──────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                loading: () => _StatsCardSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => Column(
                  children: [
                    _HeroStatsCard(stats: stats),
                    _StreakBanner(
                      streak: stats.streak,
                      bestStreak: stats.bestStreak,
                    ),
                  ],
                ),
              ),
            ),

            // ── Quick Actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _QuickActionsSection(),
            ),

            // ── Continue Learning ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: continueAsync.when(
                loading: () => _ContinueLearningSkeletonSection(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : _ContinueLearningSection(items: items),
              ),
            ),

            // ── Recent Questions ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: questionsAsync.when(
                loading: () => _RecentQuestionsSkeletonSection(),
                error: (_, __) => const SizedBox.shrink(),
                data: (questions) => _RecentQuestionsSection(
                  questions: questions,
                ),
              ),
            ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    ),   // closes Scaffold
  );     // closes AnnotatedRegion
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — Top Header
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userAsync,
    required this.hasNotifications,
  });

  // FIX C1: Explicit generic type — without AsyncValue<UserModel?> the data:
  // callback argument is typed as dynamic, which propagates type errors into
  // all user field accesses (user.fullName, user.level.displayName etc.).
  final AsyncValue<UserModel?> userAsync;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
      child: userAsync.when(
        loading: () => _HeaderSkeleton(),
        error: (_, __) => _HeaderContent(
          firstName: 'Student',
          level: 'CMA',
          daysToExam: null,
          initials: 'ST',
          hasNotifications: hasNotifications,
        ),
        data: (user) {
          if (user == null) {
            return _HeaderContent(
              firstName: 'Student',
              level: 'CMA',
              daysToExam: null,
              initials: 'ST',
              hasNotifications: hasNotifications,
            );
          }
          final parts = user.fullName.trim().split(' ');
          final firstName = parts.isNotEmpty ? parts.first : 'Student';
          final initials = parts.length >= 2
              ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
              : firstName.substring(0, firstName.length.clamp(0, 2))
                  .toUpperCase();
          return _HeaderContent(
            firstName: firstName,
            level: 'CMA ${user.level.displayName}',
            daysToExam: null,
            initials: initials,
            hasNotifications: hasNotifications,
          );
        },
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.firstName,
    required this.level,
    required this.daysToExam,
    required this.initials,
    required this.hasNotifications,
  });

  final String firstName;
  final String level;
  final int? daysToExam;
  final String initials;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    final subtitle = daysToExam != null
        ? '$level  ·  $daysToExam days to exam'
        : level;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $firstName 👋',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        // Notification bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.navy,
              iconSize: 24,
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            if (hasNotifications)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.gold,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.lightBlueTint,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 140, height: 18,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(width: 200, height: 13,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
          Container(width: 40, height: 40,
              decoration: const BoxDecoration(color: AppColors.border,
                  shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — Hero Stats Card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final remaining = (stats.weeklyGoal -
        (stats.weeklyGoalProgress * stats.weeklyGoal).round())
        .clamp(0, stats.weeklyGoal);
    final accuracyPct =
        (stats.avgAccuracy * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Your Progress This Week',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All →',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          IntrinsicHeight(
            child: Row(
              children: [
                _StatColumn(
                  value: '${stats.questionsThisWeek}',
                  label: 'Questions\nPracticed',
                ),
                _VerticalDivider(),
                _StatColumn(
                  value: '${stats.testsThisWeek}',
                  label: 'Tests\nTaken',
                ),
                _VerticalDivider(),
                _StatColumn(
                  value: '$accuracyPct%',
                  label: 'Avg\nAccuracy',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Goal progress
          Row(
            children: [
              Text(
                'Weekly Goal',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${(stats.weeklyGoalProgress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: stats.weeklyGoalProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remaining > 0
                ? '$remaining more questions to hit your goal! 💪'
                : 'Weekly goal achieved! 🎉 Keep it up!',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _StatsCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.navyLight,
      highlightColor: AppColors.navy,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — Streak Banner
// ─────────────────────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.bestStreak});

  final int streak;
  // FIX S6: Best streak is now passed in from Firestore (via HomeStats)
  // instead of being hardcoded to a minimum of 12.
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gold, AppColors.goldLight],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Study Streak!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Your best: $bestStreak days',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.navy.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.navy),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: const [
              _QuickActionCard(
                id: 'qa_practice',
                icon: Icons.menu_book_outlined,
                iconBgColor: AppColors.navy,
                iconColor: AppColors.gold,
                title: 'Practice Mode',
                subtitle: 'No time pressure',
                route: AppRoutes.practiceConfig,
              ),
              _QuickActionCard(
                id: 'qa_test',
                icon: Icons.timer_outlined,
                iconBgColor: AppColors.gold,
                iconColor: AppColors.navy,
                title: 'Take a Test',
                subtitle: 'Timed exam mode',
                route: AppRoutes.testConfig,
              ),
              _QuickActionCard(
                id: 'qa_bookmarks',
                icon: Icons.bookmark_outline,
                iconBgColor: AppColors.lightBlueTint,
                iconColor: AppColors.navy,
                title: 'Bookmarks',
                subtitle: '12 saved',
                subtitleHighlight: true,
                route: AppRoutes.bookmarks,
              ),
              _QuickActionCard(
                id: 'qa_progress',
                icon: Icons.bar_chart_outlined,
                iconBgColor: Color(0xFFE8F5EE),
                iconColor: AppColors.success,
                title: 'My Progress',
                subtitle: 'View analytics',
                route: AppRoutes.progress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.id,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
    this.subtitleHighlight = false,
  });

  final String id;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String route;
  final bool subtitleHighlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        key: Key(id),
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppRadius.card),
        splashColor: AppColors.navy.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadow.card,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: subtitleHighlight
                            ? AppColors.gold
                            : AppColors.textSecondary,
                        fontWeight: subtitleHighlight
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — Continue Learning
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  const _ContinueLearningSection({required this.items});

  final List<ContinueLearningItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Text('Continue Learning', style: AppTextStyles.headingSmall),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.subjects),
                child: Text(
                  'See All →',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ContinueLearningCard(item: items[i]),
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.item});

  final ContinueLearningItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              item.subjectCode,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Chapter name
          Text(
            item.chapterName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Progress text
          Text(
            '${item.answeredQuestions} of ${item.totalQuestions} questions',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.navy),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),

          // Resume button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              // FIX M6: Navigate to chapter questions instead of no-op.
              onTap: () => context.go(
                AppRoutes.questions(item.subjectId, item.chapterId),
              ),
              child: Text(
                'Resume →',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningSkeletonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.lightBlueTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
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
// SECTION 6 — Recently Added Questions
// ─────────────────────────────────────────────────────────────────────────────

class _RecentQuestionsSection extends StatelessWidget {
  const _RecentQuestionsSection({required this.questions});

  final List<QuestionModel> questions;

  @override
  Widget build(BuildContext context) {
    final displayQuestions = questions.take(2).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('New Questions Added', style: AppTextStyles.headingSmall),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.subjects),
                child: Text(
                  'See All →',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (displayQuestions.isEmpty) ...[
            _QuestionCardDemo(index: 0),
            const SizedBox(height: 10),
            _QuestionCardDemo(index: 1),
          ] else ...[
            for (int i = 0; i < displayQuestions.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _QuestionPreviewCard(question: displayQuestions[i]),
            ],
          ],
        ],
      ),
    );
  }
}

class _QuestionPreviewCard extends StatelessWidget {
  const _QuestionPreviewCard({required this.question});

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips row
          Row(
            children: [
              // Subject code chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  question.subjectId.toUpperCase().substring(
                      0, question.subjectId.length.clamp(0, 3)),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Year chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navy, width: 1),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '${question.year}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Marks chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '${question.marks}M',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Question text
          Text(
            question.question,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Footer
          Row(
            children: [
              Text(
                question.chapterId,
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionCardDemo extends StatelessWidget {
  const _QuestionCardDemo({required this.index});

  final int index;

  static const _demos = [
    (
      code: 'FA',
      year: '2024',
      marks: '4M',
      question:
          'A company acquired machinery for ₹5,00,000. Estimated useful life is 10 years with a residual value of ₹50,000. Calculate depreciation using the Straight Line Method.',
      chapter: 'Depreciation Accounting',
    ),
    (
      code: 'MA',
      year: '2023',
      marks: '6M',
      question:
          'From the following data, prepare a flexible budget for 80% and 100% activity levels: Fixed overheads ₹30,000, Variable overheads ₹15 per unit at 60% capacity (900 units).',
      chapter: 'Budgetary Control',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = _demos[index.clamp(0, 1)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(label: d.code, bg: AppColors.navy, fg: Colors.white),
              const Spacer(),
              _OutlineChip(label: d.year),
              const SizedBox(width: 8),
              _Chip(
                  label: d.marks,
                  bg: AppColors.amberLight,
                  fg: AppColors.gold),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            d.question,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(d.chapter,
                  style: AppTextStyles.caption.copyWith(fontSize: 12)),
              const Spacer(),
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
              color: fg, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.navy, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
              color: AppColors.navy, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );
}

class _RecentQuestionsSkeletonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.lightBlueTint,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
