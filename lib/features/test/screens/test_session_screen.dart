import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class TestSessionScreen extends StatelessWidget {
  const TestSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Session')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text('Timed test engine will be built in Day 3.',
              style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
