import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class PracticeSessionScreen extends StatelessWidget {
  const PracticeSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Session')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text('Practice session will be built in Day 2.',
              style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
