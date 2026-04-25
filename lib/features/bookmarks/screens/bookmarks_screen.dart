import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/question_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  final _filters = ['All', 'MCQ', 'Descriptive', 'Practical'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<QuestionModel>> _bookmarkedQuestionsStream(String uid) async* {
    // Stream the user doc for bookmark IDs, then fetch those questions
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((snap) async {
      final data = snap.data();
      if (data == null) return <QuestionModel>[];
      final ids = List<String>.from(data['bookmarkedQuestionIds'] as List? ?? []);
      if (ids.isEmpty) return <QuestionModel>[];

      // Firestore `whereIn` limited to 30 — batching not needed for typical bookmarks
      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 30) {
        chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
      }
      final questions = <QuestionModel>[];
      for (final chunk in chunks) {
        final snap2 = await FirebaseFirestore.instance
            .collectionGroup('questions')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        questions.addAll(
            snap2.docs.map((d) => QuestionModel.fromFirestore(d)));
      }
      return questions;
    });
  }

  List<QuestionModel> _applyFilters(List<QuestionModel> all) {
    var result = all;
    if (_selectedFilter != 'All') {
      result = result.where((q) {
        return switch (_selectedFilter) {
          'MCQ' => q.type == QuestionType.mcq || q.type == QuestionType.numericalMcq,
          'Descriptive' => q.type == QuestionType.descriptive,
          'Practical' => q.type == QuestionType.descriptive,
          _ => true,
        };
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((e) => e.question.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  void _showQuestionOptions(BuildContext context, QuestionModel q, String uid) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_remove_outlined,
                  color: AppColors.error),
              title: Text('Remove Bookmark',
                  style: GoogleFonts.dmSans(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(userServiceProvider).removeBookmark(q.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bookmark removed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppColors.gold,
                        onPressed: () =>
                            ref.read(userServiceProvider).addBookmark(q.id),
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline,
                  color: AppColors.navy),
              title: Text('Add to Practice Session',
                  style: GoogleFonts.dmSans(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              onTap: () {
                Navigator.pop(ctx);
                // Navigate to practice config with pre-selected question
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.navy),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search bookmarks...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                'Bookmarks',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              color: AppColors.navy,
            ),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.navy),
              onPressed: () {},
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<QuestionModel>>(
              stream: _bookmarkedQuestionsStream(uid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final filtered = _applyFilters(all);

                if (all.isEmpty) {
                  return AppEmptyState(
                    heading: 'No bookmarks yet',
                    body:
                        'Start saving questions you want to revisit',
                    actionLabel: 'Browse Questions',
                    onAction: () {},
                  );
                }

                return Column(
                  children: [
                    // ── Stats bar ────────────────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Text(
                            '${all.length} Saved Question${all.length == 1 ? '' : 's'}',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Practice Bookmarks',
                              style: GoogleFonts.dmSans(
                                color: AppColors.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Filter chips ─────────────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: _filters.map((f) {
                            final active = _selectedFilter == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedFilter = f),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  height: 34,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        active ? AppColors.navy : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: active
                                          ? AppColors.navy
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      f,
                                      style: GoogleFonts.dmSans(
                                        color: active
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: active
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // ── List ──────────────────────────────────────────────────
                    Expanded(
                      child: filtered.isEmpty
                          ? const AppEmptyState(
                              heading: 'No matches',
                              body: 'Try a different filter',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 12, 20, 32),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final q = filtered[i];
                                return Dismissible(
                                  key: ValueKey(q.id),
                                  direction:
                                      DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(
                                        right: 20),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                        Icons.bookmark_remove_rounded,
                                        color: AppColors.error),
                                  ),
                                  onDismissed: (_) async {
                                    await ref
                                        .read(userServiceProvider)
                                        .removeBookmark(q.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            const Text('Bookmark removed'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: AppColors.gold,
                                          onPressed: () => ref
                                              .read(userServiceProvider)
                                              .addBookmark(q.id),
                                        ),
                                      ));
                                    }
                                  },
                                  child: GestureDetector(
                                    onLongPress: () =>
                                        _showQuestionOptions(
                                            context, q, uid),
                                    child: _BookmarkCard(question: q),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bookmark card — same style as QuestionListScreen card
// ─────────────────────────────────────────────────────────────────────────────

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.question});
  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (question.type) {
      QuestionType.mcq => 'MCQ',
      QuestionType.numericalMcq => 'Numerical MCQ',
      QuestionType.descriptive => 'Descriptive',
    };

    return AppCard(
      borderLeft: AppColors.gold,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: year • type chip • marks
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.navy),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.sessionDisplay,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.navy, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.navy, fontSize: 11),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${question.marks}M',
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.question,
              style: AppTextStyles.bodyMedium
                  .copyWith(height: 1.55, color: AppColors.textPrimary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.bookmark_rounded,
                    size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  'Bookmarked',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  'View Answer →',
                  style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.navy, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
