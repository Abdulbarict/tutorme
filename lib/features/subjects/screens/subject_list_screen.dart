import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(day-5): replace CmaLevel.foundation with the level read from
    // currentUserProfileProvider once the profile stream is wired in here.
    final subjectsAsync = ref.watch(subjectsProvider(CmaLevel.foundation));

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: subjectsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => AppLoading.card(),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (subjects) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) {
            final s = subjects[i];
            return AppCard(
              onTap: () => context.go('/home/subjects/${s.id}/chapters'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBadge.subjectCode(label: s.code),
                        const SizedBox(height: AppSpacing.sm),
                        Text(s.name, style: AppTextStyles.headingSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${s.totalChapters} chapters · ${s.totalQuestions} questions',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
