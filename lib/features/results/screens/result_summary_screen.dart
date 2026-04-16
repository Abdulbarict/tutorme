import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class ResultSummaryScreen extends StatelessWidget {
  const ResultSummaryScreen({super.key, required this.resultId});
  final String resultId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Result')),
      body: Center(
        child: Text('Result ID: $resultId', style: AppTextStyles.bodyLarge),
      ),
    );
  }
}
