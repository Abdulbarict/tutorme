import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/models.dart';
import '../../../services/user_service.dart';
import '../providers/question_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuestionListScreen
// ─────────────────────────────────────────────────────────────────────────────

class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({
    super.key,
    required this.subjectId,
    required this.chapterId,
  });

  final String subjectId;
  final String chapterId;

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  // Active filter chips
  final Set<String> _activeMarksFilters = {};
  final Set<int> _activeYearFilters = {};
  bool _showBookmarkedOnly = false;
  bool _showNotPracticedOnly = false;
  _SortMode _sortMode = _SortMode.yearDesc;

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<QuestionModel> _applyFilters(
    List<QuestionModel> questions,
    Set<String> bookmarkedIds,
    Set<String> practicedIds,
  ) {
    var filtered = questions.where((q) {
      if (_activeMarksFilters.isNotEmpty && !_activeMarksFilters.contains('${q.marks}M')) {
        return false;
      }
      if (_activeYearFilters.isNotEmpty && !_activeYearFilters.contains(q.year)) {
        return false;
      }
      if (_showBookmarkedOnly && !bookmarkedIds.contains(q.id)) {
        return false;
      }
      if (_showNotPracticedOnly && practicedIds.contains(q.id)) {
        return false;
      }
      return true;
    }).toList();

    if (_sortMode == _SortMode.marksDesc) {
      filtered.sort((a, b) => b.marks.compareTo(a.marks));
    } else {
      // Default: year descending (already ordered from Firestore)
    }
    return filtered;
  }

  int get _activeFilterCount {
    return _activeMarksFilters.length +
        _activeYearFilters.length +
        (_showBookmarkedOnly ? 1 : 0) +
        (_showNotPracticedOnly ? 1 : 0);
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortBottomSheet(
        current: _sortMode,
        onSelected: (mode) => setState(() => _sortMode = mode),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chapterAsync =
        ref.watch(chapterDetailProvider(widget.subjectId, widget.chapterId));
    final questionsAsync =
        ref.watch(chapterQuestionsProvider(widget.subjectId, widget.chapterId));
    final bookmarkedIds = ref.watch(userBookmarkIdsProvider).valueOrNull ?? {};
    final practicedIds = ref.watch(userPracticedIdsProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.navy),
        title: chapterAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('Questions'),
          data: (chapter) => Text(
            chapter.name,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.navy,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.navy),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter row ──────────────────────────────────────────────────────
          _FilterRow(
            activeMarks: _activeMarksFilters,
            activeYears: _activeYearFilters,
            showBookmarkedOnly: _showBookmarkedOnly,
            showNotPracticedOnly: _showNotPracticedOnly,
            activeFilterCount: _activeFilterCount,
            onMarksToggle: (marks) => setState(() {
              if (_activeMarksFilters.contains(marks)) {
                _activeMarksFilters.remove(marks);
              } else {
                _activeMarksFilters.add(marks);
              }
            }),
            onYearToggle: (year) => setState(() {
              if (_activeYearFilters.contains(year)) {
                _activeYearFilters.remove(year);
              } else {
                _activeYearFilters.add(year);
              }
            }),
            onBookmarkedToggle: () =>
                setState(() => _showBookmarkedOnly = !_showBookmarkedOnly),
            onNotPracticedToggle: () =>
                setState(() => _showNotPracticedOnly = !_showNotPracticedOnly),
          ),

          // ── Stats row ───────────────────────────────────────────────────────
          questionsAsync.when(
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox.shrink(),
            data: (questions) {
              final filtered =
                  _applyFilters(questions, bookmarkedIds, practicedIds);
              return _StatsRow(
                totalCount: filtered.length,
                sortMode: _sortMode,
                onSortTap: _showSortSheet,
              );
            },
          ),

          // ── Question list ───────────────────────────────────────────────────
          Expanded(
            child: questionsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => AppLoading.listItem(),
              ),
              error: (e, _) => AppEmptyState(
                heading: 'Failed to Load Questions',
                body: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(
                    chapterQuestionsProvider(
                        widget.subjectId, widget.chapterId)),
              ),
              data: (questions) {
                final filtered =
                    _applyFilters(questions, bookmarkedIds, practicedIds);
                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    heading: 'No Questions Match',
                    body:
                        'Try adjusting your filters to see more questions.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final q = filtered[i];
                    final isBookmarked = bookmarkedIds.contains(q.id);
                    final isPracticed = practicedIds.contains(q.id);
                    return _QuestionCard(
                      question: q,
                      questionNumber: i + 1,
                      isBookmarked: isBookmarked,
                      isPracticed: isPracticed,
                      onTap: () => context.go(
                        AppRoutes.questionDetail(
                            widget.subjectId, widget.chapterId, q.id),
                      ),
                      onBookmarkToggle: () async {
                        await ref
                            .read(userServiceProvider)
                            .toggleBookmark(q.id, isBookmarked);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Row
// ─────────────────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.activeMarks,
    required this.activeYears,
    required this.showBookmarkedOnly,
    required this.showNotPracticedOnly,
    required this.activeFilterCount,
    required this.onMarksToggle,
    required this.onYearToggle,
    required this.onBookmarkedToggle,
    required this.onNotPracticedToggle,
  });

  final Set<String> activeMarks;
  final Set<int> activeYears;
  final bool showBookmarkedOnly;
  final bool showNotPracticedOnly;
  final int activeFilterCount;
  final void Function(String) onMarksToggle;
  final void Function(int) onYearToggle;
  final VoidCallback onBookmarkedToggle;
  final VoidCallback onNotPracticedToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildAllChip(),
            const SizedBox(width: 8),
            _buildMarksChip('10M'),
            const SizedBox(width: 8),
            _buildMarksChip('5M'),
            const SizedBox(width: 8),
            _buildMarksChip('2M'),
            const SizedBox(width: 8),
            _buildBookmarkChip(),
            const SizedBox(width: 8),
            _buildNotPracticedChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChip() {
    final isAll = activeMarks.isEmpty &&
        activeYears.isEmpty &&
        !showBookmarkedOnly &&
        !showNotPracticedOnly;
    return _FilterChip(
      label: 'All',
      isActive: isAll,
      activeColor: AppColors.navy,
      onTap: () {
        // "All" clears other filters — handled in parent setState
        // but here we signal by calling no-op; parent manages via the count
      },
    );
  }

  Widget _buildMarksChip(String label) {
    final isActive = activeMarks.contains(label);
    return _FilterChip(
      label: label,
      isActive: isActive,
      activeColor: AppColors.gold,
      onTap: () => onMarksToggle(label),
    );
  }

  Widget _buildBookmarkChip() {
    return _FilterChip(
      label: 'Bookmarked',
      isActive: showBookmarkedOnly,
      activeColor: AppColors.gold,
      icon: Icons.bookmark_rounded,
      onTap: onBookmarkedToggle,
    );
  }

  Widget _buildNotPracticedChip() {
    return _FilterChip(
      label: 'Not Practiced',
      isActive: showNotPracticedOnly,
      activeColor: AppColors.navy,
      onTap: onNotPracticedToggle,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : AppColors.navy,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isActive ? Colors.white : AppColors.navy,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: isActive ? Colors.white : AppColors.navy,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalCount,
    required this.sortMode,
    required this.onSortTap,
  });

  final int totalCount;
  final _SortMode sortMode;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            '$totalCount Question${totalCount == 1 ? '' : 's'}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSortTap,
            child: Row(
              children: [
                const Icon(Icons.sort_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  sortMode == _SortMode.marksDesc
                      ? 'By Marks'
                      : 'By Year',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question Card
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.isBookmarked,
    required this.isPracticed,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final QuestionModel question;
  final int questionNumber;
  final bool isBookmarked;
  final bool isPracticed;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  Color get _accentColor {
    if (isBookmarked && isPracticed) return AppColors.navy;
    if (isBookmarked) return AppColors.gold;
    if (isPracticed) return AppColors.success;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderLeft: _accentColor,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: year chip + marks chip + bookmark
            Row(
              children: [
                _YearChip(label: question.sessionDisplay),
                const SizedBox(width: 8),
                _MarksChip(marks: question.marks),
                const Spacer(),
                _BookmarkButton(
                  isBookmarked: isBookmarked,
                  onTap: onBookmarkToggle,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: question text preview
            Text(
              question.question,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.55,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Row 3: practiced status + practice arrow
            Row(
              children: [
                if (isPracticed)
                  _StatusChip(
                    label: '✓ Practiced',
                    background: AppColors.success.withValues(alpha: 0.12),
                    textColor: AppColors.success,
                  )
                else
                  _StatusChip(
                    label: 'Not Started',
                    background: AppColors.border.withValues(alpha: 0.5),
                    textColor: AppColors.textSecondary,
                  ),
                const Spacer(),
                Text(
                  'Practice →',
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _YearChip extends StatelessWidget {
  const _YearChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.navy, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.navy,
            fontSize: 12,
          ),
        ),
      );
}

class _MarksChip extends StatelessWidget {
  const _MarksChip({required this.marks});

  final int marks;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${marks}M',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.isBookmarked,
    required this.onTap,
  });

  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 22,
            color: isBookmarked ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort Mode
// ─────────────────────────────────────────────────────────────────────────────

enum _SortMode { yearDesc, marksDesc }

class _SortBottomSheet extends StatelessWidget {
  const _SortBottomSheet({
    required this.current,
    required this.onSelected,
  });

  final _SortMode current;
  final void Function(_SortMode) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort Questions',
            style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _SortOption(
            label: 'Newest Year First',
            icon: Icons.calendar_today_rounded,
            isSelected: current == _SortMode.yearDesc,
            onTap: () {
              onSelected(_SortMode.yearDesc);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _SortOption(
            label: 'Highest Marks First',
            icon: Icons.stars_rounded,
            isSelected: current == _SortMode.marksDesc,
            onTap: () {
              onSelected(_SortMode.marksDesc);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.navy.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.navy
                      : AppColors.textPrimary,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.navy,
              ),
          ],
        ),
      ),
    );
  }
}
