import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../home/providers/home_providers.dart';

final selectedLevelProvider = StateProvider.autoDispose<CmaLevel>((ref) {
  final user = ref.watch(currentUserProfileProvider).valueOrNull;
  return user?.level ?? CmaLevel.intermediate;
});

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedLevelProvider);
    final subjectsAsync = ref.watch(subjectsProvider(selectedLevel));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _SubjectHeader(),
            Expanded(
              child: subjectsAsync.when(
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => AppLoading.card(),
                ),
                error: (e, __) => AppEmptyState(
                  heading: 'Error Loading Subjects',
                  body: e.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(subjectsProvider(selectedLevel)),
                ),
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return AppEmptyState(
                      heading: 'No Subjects',
                      body: 'No subjects found for ${selectedLevel.displayName}.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final subject = subjects[i];

                      // Subject colors
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
                      final color = colors[i % colors.length];

                      // Subject icon
                      IconData icon = Icons.menu_book;
                      final code = subject.code.toUpperCase();
                      if (code.contains('SCM')) {
                        icon = Icons.bar_chart;
                      } else if (code.contains('LAW')) {
                        icon = Icons.gavel;
                      } else if (code.contains('TAX') ||
                          code.contains('DT') ||
                          code.contains('IDT')) {
                        icon = Icons.account_balance;
                      } else if (code.contains('FM')) {
                        icon = Icons.trending_up;
                      }

                      // Dummy progress 
                      const practicedRatio = 0.0;

                      return _SubjectCard(
                        subject: subject,
                        color: color,
                        icon: icon,
                        practicedRatio: practicedRatio,
                        onTap: () => context.go(AppRoutes.chapters(subject.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).padding.top;
    final selectedLevel = ref.watch(selectedLevelProvider);
    final subjectsAsync = ref.watch(subjectsProvider(selectedLevel));

    int subjectCount = 0;
    int questionCount = 0;

    if (subjectsAsync.hasValue) {
      subjectCount = subjectsAsync.value!.length;
      questionCount =
          subjectsAsync.value!.fold(0, (sum, s) => sum + s.totalQuestions);
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Subjects',
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 22)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search),
                color: AppColors.navy,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _LevelToggle(
                  label: 'CMA Inter',
                  isSelected: selectedLevel == CmaLevel.intermediate,
                  onTap: () => ref.read(selectedLevelProvider.notifier).state =
                      CmaLevel.intermediate,
                ),
                _LevelToggle(
                  label: 'CMA Final',
                  isSelected: selectedLevel == CmaLevel.final_,
                  onTap: () => ref.read(selectedLevelProvider.notifier).state =
                      CmaLevel.final_,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$subjectCount Subjects · $questionCount Questions',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LevelToggle extends StatelessWidget {
  const _LevelToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelBold.copyWith(
              color: isSelected ? Colors.white : AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.color,
    required this.icon,
    required this.practicedRatio,
    required this.onTap,
  });

  final SubjectModel subject;
  final Color color;
  final IconData icon;
  final double practicedRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subject.code.isEmpty ? 'CMA' : subject.code,
                            style: AppTextStyles.monospace.copyWith(
                                color: Colors.white, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${subject.totalChapters} Chapters · ${subject.totalQuestions} Questions',
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: practicedRatio,
                      backgroundColor: AppColors.border,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(practicedRatio * 100).round()}%',
                    style: AppTextStyles.labelBold
                        .copyWith(color: AppColors.gold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.bookmark_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Tap to explore chapters',
                  style: AppTextStyles.caption.copyWith(fontSize: 12)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }
}
