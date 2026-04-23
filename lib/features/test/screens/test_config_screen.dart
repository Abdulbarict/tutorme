import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/models.dart';
import '../../practice/providers/practice_providers.dart';
import '../providers/test_providers.dart';

class TestConfigScreen extends ConsumerStatefulWidget {
  const TestConfigScreen({super.key});

  @override
  ConsumerState<TestConfigScreen> createState() => _TestConfigScreenState();
}

class _TestConfigScreenState extends ConsumerState<TestConfigScreen> {
  SubjectModel? _selectedSubject;
  Set<String> _selectedChapterIds = {};
  int? _questionCount = 10;
  final TextEditingController _customCountController = TextEditingController();
  
  bool _timerEnabled = false;
  TimerMode _timerMode = TimerMode.perQuestion;
  double _timeValue = 1.5; // default 1.5 minutes
  
  TestQuestionType _selectedType = TestQuestionType.all;

  @override
  void dispose() {
    _customCountController.dispose();
    super.dispose();
  }

  void _onSubjectChanged(SubjectModel? subject) {
    if (subject == null || _selectedSubject?.id == subject.id) return;
    setState(() {
      _selectedSubject = subject;
      _selectedChapterIds.clear();
    });
  }

  void _onChapterToggled(String chapterId, bool selected) {
    setState(() {
      if (selected) {
        _selectedChapterIds.add(chapterId);
      } else {
        _selectedChapterIds.remove(chapterId);
      }
    });
  }

  void _startTest() {
    if (_selectedSubject == null || _selectedChapterIds.isEmpty) return;

    int? finalCount = _questionCount;
    if (_questionCount == -1) { // -1 means custom
      final parsed = int.tryParse(_customCountController.text);
      if (parsed != null && parsed > 0) {
        finalCount = parsed;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number of questions')),
        );
        return;
      }
    }

    final config = TestConfig(
      subjectId: _selectedSubject!.id,
      subjectName: _selectedSubject!.name,
      selectedChapterIds: _selectedChapterIds.toList(),
      questionCount: finalCount,
      timerEnabled: _timerEnabled,
      timerMode: _timerMode,
      timeValue: _timeValue,
      questionType: _selectedType,
    );

    ref.read(activeTestConfigProvider.notifier).state = config;
    context.go(AppRoutes.testSession);
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.navy),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.navy,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(practiceSubjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Set Up Your Test',
          style: AppTextStyles.displaySmall.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject
            Text('Subject', style: AppTextStyles.labelBold),
            const SizedBox(height: 8),
            subjectsAsync.when(
              data: (subjects) => DropdownButtonFormField<SubjectModel>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.navy),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Select a subject'),
                items: subjects.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name, style: AppTextStyles.bodyMedium));
                }).toList(),
                onChanged: _onSubjectChanged,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading subjects: $err'),
            ),

            const SizedBox(height: 16),

            // Chapters
            Row(
              children: [
                Text('Chapters ', style: AppTextStyles.labelBold),
                Text('(select one or more)', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedSubject == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: const Text('Select a subject first', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              )
            else
              ref.watch(practiceChaptersProvider(_selectedSubject!.id)).when(
                    data: (chapters) => SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (chapters as List<ChapterModel>).map((c) {
                          final isSelected = _selectedChapterIds.contains(c.id);
                          return FilterChip(
                            label: Text(c.name),
                            labelStyle: AppTextStyles.bodyMedium.copyWith(color: isSelected ? Colors.white : AppColors.navy),
                            selected: isSelected,
                            onSelected: (val) => _onChapterToggled(c.id, val),
                            selectedColor: AppColors.navy,
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: isSelected ? AppColors.navy : AppColors.border),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error loading chapters: $err'),
                  ),

            const SizedBox(height: 16),

            // Number of Questions
            Text('Number of Questions', style: AppTextStyles.labelBold),
            const SizedBox(height: 8),
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  children: [5, 10, 15, 20].map((n) {
                    return _buildChip('$n', _questionCount == n, () => setState(() => _questionCount = n));
                  }).toList(),
                ),
                const SizedBox(width: 8),
                _buildChip('All', _questionCount == null, () => setState(() => _questionCount = null)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _customCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Custom',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onTap: () => setState(() => _questionCount = -1), // -1 for custom
                    onChanged: (val) => setState(() => _questionCount = -1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Timer Settings
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.navy),
                const SizedBox(width: 8),
                Text('Enable Timer', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: _timerEnabled,
                  onChanged: (val) => setState(() => _timerEnabled = val),
                  activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _timerEnabled ? 120 : 0,
              curve: Curves.easeInOut,
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<TimerMode>(
                            value: TimerMode.perQuestion,
                            groupValue: _timerMode,
                            onChanged: (val) => setState(() {
                              if (val != null) _timerMode = val;
                              _timeValue = 1.5;
                            }),
                            activeColor: AppColors.navy,
                          ),
                          Text('Per Question', style: AppTextStyles.bodyMedium),
                          const SizedBox(width: 16),
                          Radio<TimerMode>(
                            value: TimerMode.totalTime,
                            groupValue: _timerMode,
                            onChanged: (val) => setState(() {
                              if (val != null) _timerMode = val;
                              _timeValue = 30; // 30 min default total time
                            }),
                            activeColor: AppColors.navy,
                          ),
                          Text('Total Time', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _timerMode == TimerMode.perQuestion
                                ? 'Time per question: ${_timeValue.toStringAsFixed(1)} min'
                                : 'Total test time: ${_timeValue.toInt()} min',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: _timeValue,
                        min: _timerMode == TimerMode.perQuestion ? 0.5 : 5,
                        max: _timerMode == TimerMode.perQuestion ? 10 : 180,
                        divisions: _timerMode == TimerMode.perQuestion ? 19 : 35,
                        activeColor: AppColors.gold,
                        onChanged: (val) => setState(() => _timeValue = val),
                      ),
                      if (_timerMode == TimerMode.perQuestion && _questionCount != null && _questionCount! > 0)
                        Text(
                          'Total: ~${(_timeValue * _questionCount!).toInt()} minutes for $_questionCount questions',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Question Type Filter
            Text('Question Types', style: AppTextStyles.labelBold),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TestQuestionType.values.map((type) {
                return _buildChip(type.label, _selectedType == type, () => setState(() => _selectedType = type));
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Summary Card
            AppCard(
              borderLeft: AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_questionCount == null ? 'All' : _questionCount == -1 ? (_customCountController.text.isEmpty ? '?' : _customCountController.text) : _questionCount} Questions from ${_selectedChapterIds.length} Chapter(s)',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSubject?.name ?? 'No Subject Selected',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timerEnabled
                        ? 'Time Allowed: ${_timerMode == TimerMode.totalTime ? _timeValue.toInt() : (_timeValue * (_questionCount != null && _questionCount! > 0 ? _questionCount! : 0)).toInt()} minutes'
                        : 'No time limit',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Start Test
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: (_selectedSubject != null && _selectedChapterIds.isNotEmpty) ? _startTest : null,
                icon: const Icon(Icons.timer, color: Colors.white),
                label: const Text('Start Test', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
