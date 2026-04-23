import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/models.dart';
import '../providers/practice_providers.dart';

class PracticeConfigScreen extends ConsumerStatefulWidget {
  const PracticeConfigScreen({super.key});

  @override
  ConsumerState<PracticeConfigScreen> createState() =>
      _PracticeConfigScreenState();
}

class _PracticeConfigScreenState extends ConsumerState<PracticeConfigScreen> {
  SubjectModel? _selectedSubject;
  Set<String> _selectedChapterIds = {};
  PracticeFilter _selectedFilter = PracticeFilter.all;
  bool _shuffle = false;
  final bool _isLoading = false;

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

  void _selectAllChapters(List<ChapterModel> chapters) {
    setState(() {
      _selectedChapterIds = chapters.map((c) => c.id).toSet();
    });
  }

  void _startSession() {
    if (_selectedSubject == null || _selectedChapterIds.isEmpty) return;

    final config = PracticeConfig(
      subjectId: _selectedSubject!.id,
      subjectName: _selectedSubject!.name,
      selectedChapterIds: _selectedChapterIds.toList(),
      filter: _selectedFilter,
      shuffle: _shuffle,
    );

    ref.read(activePracticeConfigProvider.notifier).state = config;
    context.go('/home/practice/session');
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
          'Practice Mode',
          style: AppTextStyles.displaySmall.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to practice?',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 24),

            // Subject Selector
            Text(
              'Subject',
              style: AppTextStyles.labelBold,
            ),
            const SizedBox(height: 8),
            subjectsAsync.when(
              data: (subjects) => DropdownButtonFormField<SubjectModel>(
                // ignore: deprecated_member_use
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
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: _onSubjectChanged,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading subjects: $err'),
            ),

            const SizedBox(height: 16),

            // Chapter Selector
            Row(
              children: [
                Text(
                  'Chapters ',
                  style: AppTextStyles.labelBold,
                ),
                Text(
                  '(select one or more)',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedSubject == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Select a subject first',
                  style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              )
            else
              ref.watch(practiceChaptersProvider(_selectedSubject!.id)).when(
                    data: (chapters) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: chapters.map((ChapterModel c) {
                              final isSelected = _selectedChapterIds.contains(c.id);
                              return FilterChip(
                                label: Text(c.name),
                                labelStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected ? Colors.white : AppColors.navy,
                                ),
                                selected: isSelected,
                                onSelected: (val) => _onChapterToggled(c.id, val),
                                selectedColor: AppColors.navy,
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.navy : AppColors.border,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _selectAllChapters(chapters),
                          child: Text(
                            'Select All Chapters',
                            style: AppTextStyles.labelBold.copyWith(color: AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error loading chapters: $err'),
                  ),

            const SizedBox(height: 16),

            // Filter Options
            Text(
              'Include',
              style: AppTextStyles.labelBold,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PracticeFilter.values.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.navy,
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.navy,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isSelected ? AppColors.navy : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Shuffle Toggle
            Row(
              children: [
                const Icon(Icons.shuffle, color: AppColors.navy),
                const SizedBox(width: 8),
                Text(
                  'Shuffle Questions',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy),
                ),
                const Spacer(),
                Switch(
                  value: _shuffle,
                  onChanged: (val) => setState(() => _shuffle = val),
                  activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Summary Card
            AppCard(
              borderLeft: AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice session configuration',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From ${_selectedChapterIds.length} chapter(s) in ${_selectedSubject?.name ?? 'Subject'}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Start Button
            AppButton.primary(
              label: 'Start Practice Session',
              height: 54,
              isLoading: _isLoading,
              onPressed: (_selectedSubject != null && _selectedChapterIds.isNotEmpty)
                  ? _startSession
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
