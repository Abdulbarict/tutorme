import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class TestConfigScreen extends StatelessWidget {
  const TestConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure Mock Test', style: AppTextStyles.displaySmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Select subject, duration and question count.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            AppButton.primary(
              label: 'Start Test',
              onPressed: () => context.go(AppRoutes.testSession),
            ),
          ],
        ),
      ),
    );
  }
}
