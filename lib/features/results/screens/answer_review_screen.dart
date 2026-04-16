import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class AnswerReviewScreen extends StatelessWidget {
  const AnswerReviewScreen({super.key, required this.resultId});
  final String resultId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Answer Review')),
      body: Center(child: Text('Review for $resultId', style: AppTextStyles.bodyLarge)),
    );
  }
}
