import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/models.dart';
import '../../practice/providers/practice_providers.dart';
import '../../results/providers/result_providers.dart';
import '../providers/test_providers.dart';

class TestSessionScreen extends ConsumerStatefulWidget {
  const TestSessionScreen({super.key});

  @override
  ConsumerState<TestSessionScreen> createState() => _TestSessionScreenState();
}

class _TestSessionScreenState extends ConsumerState<TestSessionScreen> {
  bool _isInit = false;
  late TestConfig _config;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _initSession(List<QuestionModel> questions) async {
    if (_isInit) return;
    _isInit = true;

    // Filter by type
    var filtered = questions;
    if (_config.questionType != TestQuestionType.all) {
      final targetType = _config.questionType == TestQuestionType.mcq
          ? QuestionType.mcq
          : _config.questionType == TestQuestionType.descriptive
              ? QuestionType.descriptive
              : QuestionType.numericalMcq;
      filtered = filtered.where((q) => q.type == targetType).toList();
    }

    // Shuffle and Limit
    filtered.shuffle(Random());
    if (_config.questionCount != null && filtered.length > _config.questionCount!) {
      filtered = filtered.sublist(0, _config.questionCount);
    }

    // Delay state update to avoid during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testSessionProvider.notifier).loadQuestions(filtered);

      if (_config.timerEnabled) {
        final totalSeconds = _config.calculateTotalTimeInSeconds(filtered.length);
        ref.read(testTimerProvider.notifier).start(totalSeconds, () {
          _handleAutoSubmit();
        });
      }
    });
  }

  void _handleAutoSubmit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏰ Time\'s Up!', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, color: AppColors.navy, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Submitting your test...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColors.gold),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // pop dialog
        _submitTest();
      }
    });
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?', style: TextStyle(fontFamily: 'Playfair Display', color: AppColors.navy, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel', style: TextStyle(color: AppColors.navy))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSubmitDialog() {
    final sessionState = ref.read(testSessionProvider);
    final total = sessionState.questions.length;
    final answered = sessionState.answers.length;
    final flagged = sessionState.flaggedQuestions.length;
    final notAttempted = total - answered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?', style: TextStyle(fontFamily: 'Playfair Display', color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 16), const SizedBox(width: 8), Text('Answered: $answered/$total', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.flag, color: AppColors.gold, size: 16), const SizedBox(width: 8), Text('Flagged: $flagged', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gold))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.radio_button_unchecked, color: AppColors.textSecondary, size: 16), const SizedBox(width: 8), Text('Not Attempted: $notAttempted', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))]),
            if (notAttempted > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Text('You have $notAttempted unattempted questions.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning))),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Continue Test', style: TextStyle(color: AppColors.navy))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Submit Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitTest() {
    final sessionState = ref.read(testSessionProvider);
    ref.read(testSessionProvider.notifier).submitTest();
    ref.read(testTimerProvider.notifier).dispose();

    // Build correct-answer map from questions
    final correctAnswers = <String, int>{};
    for (final q in sessionState.questions) {
      correctAnswers[q.id] = q.correctAnswerIndex;
    }

    // Build selected-answer map (only int answers for MCQ; skip descriptive)
    final selectedAnswers = <String, int?>{};
    for (final q in sessionState.questions) {
      final ans = sessionState.answers[q.id];
      selectedAnswers[q.id] = ans is int ? ans : null;
    }

    final correctCount = selectedAnswers.entries
        .where((e) => e.value != null && e.value == correctAnswers[e.key])
        .length;

    final result = ResultModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: '',
      subjectId: _config.subjectId,
      chapterId: _config.selectedChapterIds.isNotEmpty
          ? _config.selectedChapterIds.first
          : '',
      questionIds: sessionState.questions.map((q) => q.id).toList(),
      selectedAnswers: selectedAnswers,
      correctAnswers: correctAnswers,
      marksObtained: correctCount,
      totalMarks: sessionState.questions.length,
      timeTakenSeconds: 0,
      completedAt: DateTime.now(),
      mode: ResultMode.test,
    );

    ref.read(activeResultProvider.notifier).setResult(
          result: result,
          questions: sessionState.questions,
          subjectName: _config.subjectName,
          chapterName: _config.selectedChapterIds.isNotEmpty
              ? _config.selectedChapterIds.first
              : '',
        );

    context.go(AppRoutes.testResult(result.id));
  }

  void _showPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Questions Overview', style: AppTextStyles.headingMedium),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(testSessionProvider);
                  return GridView.builder(
                    controller: controller,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: state.questions.length,
                    itemBuilder: (context, index) {
                      final q = state.questions[index];
                      final isAnswered = state.answers.containsKey(q.id);
                      final isFlagged = state.flaggedQuestions.contains(q.id);
                      
                      Color bgColor = Colors.white;
                      Color borderColor = AppColors.navy;
                      Color textColor = AppColors.navy;
                      
                      if (isAnswered) {
                        bgColor = AppColors.navy;
                        textColor = Colors.white;
                      }
                      if (isFlagged && !isAnswered) {
                        bgColor = Colors.white;
                        borderColor = AppColors.error;
                      } else if (isFlagged && isAnswered) {
                        bgColor = AppColors.gold;
                        borderColor = AppColors.gold;
                        textColor = Colors.white;
                      }
                      
                      return GestureDetector(
                        onTap: () {
                          ref.read(testSessionProvider.notifier).goToIndex(index);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: borderColor, width: isFlagged && !isAnswered ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text('${index + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              if (isFlagged)
                                const Positioned(
                                  top: 2, right: 2,
                                  child: Icon(Icons.flag, size: 12, color: Colors.white), // or gold if white bg
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegend(AppColors.navy, 'Answered'),
                  _buildLegend(AppColors.gold, 'Flagged'),
                  _buildLegend(Colors.white, 'Not Visited', border: AppColors.navy),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSubmitDialog();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Submit Test', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, {Color? border}) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: border != null ? Border.all(color: border) : null),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final configOpt = ref.watch(activeTestConfigProvider);
    if (configOpt == null) {
      return const Scaffold(body: Center(child: Text('No configuration found')));
    }
    _config = configOpt;

    final questionsAsync = ref.watch(practiceSessionQuestionsProvider(_config.subjectId, _config.selectedChapterIds));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) return const Center(child: Text('No questions available.'));
              
              _initSession(questions);

              final state = ref.watch(testSessionProvider);
              if (state.questions.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.navy));

              final currentQ = state.currentQuestion!;
              final isFlagged = state.flaggedQuestions.contains(currentQ.id);

              return Column(
                children: [
                  // Status Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.navy, width: 1.5)),
                          child: Text('Q${state.currentIndex + 1}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        if (_config.timerEnabled)
                          Consumer(
                            builder: (context, ref, child) {
                              final seconds = ref.watch(testTimerProvider);
                              Color timerColor = AppColors.navy;
                              if (seconds < 300) {
                                timerColor = AppColors.error; // < 5 min
                              } else if (seconds < 600) {
                                timerColor = AppColors.gold; // < 10 min
                              }

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: timerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer, size: 16, color: timerColor),
                                    const SizedBox(width: 8),
                                    Text(_formatTime(seconds), style: AppTextStyles.headingMedium.copyWith(color: timerColor, fontSize: 18)),
                                  ],
                                ),
                              );
                            },
                          ),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.grid_view, color: AppColors.navy), onPressed: _showPalette),
                      ],
                    ),
                  ),

                  // Question Display
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta Row
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              Chip(label: Text(_config.subjectName, style: AppTextStyles.caption.copyWith(color: AppColors.navy)), backgroundColor: AppColors.lightBlueTint, side: BorderSide.none),
                              Chip(label: Text('${currentQ.marks} Marks', style: AppTextStyles.caption.copyWith(color: AppColors.gold)), backgroundColor: AppColors.amberLight, side: BorderSide.none),
                              if (currentQ.year != 0)
                                Chip(label: Text(currentQ.year.toString(), style: AppTextStyles.caption), backgroundColor: Colors.grey[200], side: BorderSide.none),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          AppCard(
                            borderLeft: AppColors.navy,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QUESTION ${state.currentIndex + 1} OF ${state.questions.length}', style: AppTextStyles.caption.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(currentQ.question, style: AppTextStyles.bodyMedium.copyWith(fontSize: 16, height: 1.7)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Answer Area
                          if (currentQ.type == QuestionType.mcq || currentQ.type == QuestionType.numericalMcq)
                            ...currentQ.options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final optText = entry.value;
                              final isSelected = state.answers[currentQ.id] == optionIndex;
                              final optionLabels = ['A', 'B', 'C', 'D'];
                              final label = optionIndex < optionLabels.length ? optionLabels[optionIndex] : '';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => ref.read(testSessionProvider.notifier).updateAnswer(currentQ.id, optionIndex),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.navy : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isSelected ? AppColors.navy : AppColors.border),
                                      boxShadow: AppShadow.card,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32, height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.white : AppColors.background,
                                          ),
                                          child: Text(label, style: TextStyle(color: isSelected ? AppColors.navy : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Text(optText, style: AppTextStyles.bodyMedium.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary))),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                          else
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Answer', style: AppTextStyles.labelBold.copyWith(color: AppColors.navy)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    maxLines: null,
                                    minLines: 6,
                                    decoration: InputDecoration(
                                      hintText: 'Write your answer here...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.navy)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.navy, width: 2)),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    controller: TextEditingController(text: state.answers[currentQ.id] as String? ?? '')..selection = TextSelection.fromPosition(TextPosition(offset: (state.answers[currentQ.id] as String? ?? '').length)),
                                    onChanged: (val) => ref.read(testSessionProvider.notifier).updateAnswer(currentQ.id, val),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => ref.read(testSessionProvider.notifier).toggleFlag(currentQ.id),
                            icon: Icon(isFlagged ? Icons.flag : Icons.flag_outlined, color: isFlagged ? AppColors.gold : AppColors.textSecondary),
                            label: Text('Flag', style: TextStyle(color: isFlagged ? AppColors.gold : AppColors.textSecondary)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isFlagged ? AppColors.gold : AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: state.currentIndex > 0 ? () => ref.read(testSessionProvider.notifier).goToPrev() : null,
                                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('← Prev'),
                              ),
                              const SizedBox(width: 12),
                              if (state.isLastQuestion)
                                ElevatedButton(
                                  onPressed: _showSubmitDialog,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => ref.read(testSessionProvider.notifier).goToNext(),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  child: const Text('Next →', style: TextStyle(color: Colors.white)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}
