import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/result_model.dart';
import '../providers/result_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Performance Band helpers
// ─────────────────────────────────────────────────────────────────────────────

enum PerformanceBand { excellent, good, average, poor }

extension PerformanceBandX on PerformanceBand {
  Color get color => switch (this) {
        PerformanceBand.excellent => AppColors.gold,
        PerformanceBand.good => AppColors.success,
        PerformanceBand.average => AppColors.warning,
        PerformanceBand.poor => AppColors.error,
      };

  IconData get icon => switch (this) {
        PerformanceBand.excellent => Icons.emoji_events,
        PerformanceBand.good => Icons.thumb_up,
        PerformanceBand.average => Icons.trending_up,
        PerformanceBand.poor => Icons.refresh,
      };

  String get label => switch (this) {
        PerformanceBand.excellent => 'Excellent!',
        PerformanceBand.good => 'Good Performance',
        PerformanceBand.average => 'Keep Going',
        PerformanceBand.poor => 'Needs More Practice',
      };

  String get message => switch (this) {
        PerformanceBand.excellent =>
          'Outstanding! You have mastered this chapter.',
        PerformanceBand.good =>
          "Great effort! A little more revision and you're exam-ready.",
        PerformanceBand.average =>
          'Fair attempt. Focus on highlighted weak areas before your next test.',
        PerformanceBand.poor =>
          "Don't worry! Revisit the chapter and try practice mode first.",
      };

  String get grade => switch (this) {
        PerformanceBand.excellent => 'A',
        PerformanceBand.good => 'B',
        PerformanceBand.average => 'C',
        PerformanceBand.poor => 'D',
      };
}

PerformanceBand bandFor(double accuracy) {
  final pct = accuracy * 100;
  if (pct >= 90) return PerformanceBand.excellent;
  if (pct >= 75) return PerformanceBand.good;
  if (pct >= 50) return PerformanceBand.average;
  return PerformanceBand.poor;
}

String formatTime(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  if (m == 0) return '${s}s';
  if (s == 0) return '${m}m';
  return '${m}m ${s}s';
}

// ─────────────────────────────────────────────────────────────────────────────
// CircularScorePainter
// ─────────────────────────────────────────────────────────────────────────────

class CircularScorePainter extends CustomPainter {
  const CircularScorePainter({
    required this.score,
    required this.trackColor,
    required this.fillColor,
    this.strokeWidth = 10,
  });

  final double score;       // 0.0 – 1.0
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background track
    canvas.drawCircle(center, radius, trackPaint);

    // Score arc
    final sweepAngle = 2 * math.pi * score.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(CircularScorePainter oldDelegate) =>
      oldDelegate.score != score ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// ResultSummaryScreen
// ─────────────────────────────────────────────────────────────────────────────

class ResultSummaryScreen extends ConsumerWidget {
  const ResultSummaryScreen({super.key, required this.resultId});
  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try in-memory result first (fresh from session), then fetch from Firestore
    final activeState = ref.watch(activeResultProvider);
    if (activeState.isReady) {
      return _ResultBody(
        result: activeState.result!,
        subjectName: activeState.subjectName,
        chapterName: activeState.chapterName,
        resultId: resultId,
      );
    }

    // Fallback: load from Firestore
    final resultAsync = ref.watch(resultByIdProvider(resultId));
    final subjectAsync = ref.watch(resultSubjectNameProvider(resultId));
    final chapterAsync = ref.watch(resultChapterNameProvider(resultId));

    return resultAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error loading result: $e')),
      ),
      data: (result) => subjectAsync.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.navy,
          body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
        ),
        error: (e, _) => _ResultBody(
          result: result,
          subjectName: 'Subject',
          chapterName: 'Chapter',
          resultId: resultId,
        ),
        data: (subjectName) => chapterAsync.when(
          loading: () => const Scaffold(
            backgroundColor: AppColors.navy,
            body:
                Center(child: CircularProgressIndicator(color: AppColors.gold)),
          ),
          error: (e, _) => _ResultBody(
            result: result,
            subjectName: subjectName,
            chapterName: 'Chapter',
            resultId: resultId,
          ),
          data: (chapterName) => _ResultBody(
            result: result,
            subjectName: subjectName,
            chapterName: chapterName,
            resultId: resultId,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResultBody  — the actual UI
// ─────────────────────────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.result,
    required this.subjectName,
    required this.chapterName,
    required this.resultId,
  });

  final ResultModel result;
  final String subjectName;
  final String chapterName;
  final String resultId;

  @override
  Widget build(BuildContext context) {
    final band = bandFor(result.accuracy);
    final screenHeight = MediaQuery.of(context).size.height;
    final accuracyPct = (result.accuracy * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Upper Navy Gradient ──────────────────────────────────────────
          SizedBox(
            height: screenHeight * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.navyDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      // Title row
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            'Test Complete!',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Subject · Chapter subtitle
                      Text(
                        '$subjectName · $chapterName',
                        style: GoogleFonts.dmSans(
                          color: AppColors.gold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Score Ring
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(140, 140),
                              painter: CircularScorePainter(
                                score: result.accuracy,
                                trackColor: Colors.white.withValues(alpha: 0.15),
                                fillColor: AppColors.gold,
                                strokeWidth: 10,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${result.marksObtained}',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  '/ ${result.totalMarks}',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'SCORE',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4 Stats Row
                      _StatsRow(
                        result: result,
                        accuracyPct: accuracyPct,
                        band: band,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable Lower Section ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Performance Badge (overlapping)
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: AppCard(
                        borderLeft: band.color,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(band.icon, color: band.color, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    band.label,
                                    style: GoogleFonts.dmSans(
                                      color: band.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    band.message,
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Lower body content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    child: Column(
                      children: [
                        // Chapter Breakdown
                        _ChapterBreakdownCard(
                          result: result,
                          chapterName: chapterName,
                          band: band,
                          accuracy: result.accuracy,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Action Buttons
                        AppButton.primary(
                          label: 'Review Answers →',
                          onPressed: () => context.go(
                              AppRoutes.testResultReview(resultId)),
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        AppButton.ghost(
                          label: 'Retake This Test',
                          onPressed: () => context.go(AppRoutes.testConfig),
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: Text(
                              'Back to Dashboard',
                              style: GoogleFonts.dmSans(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsRow
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.result,
    required this.accuracyPct,
    required this.band,
  });

  final ResultModel result;
  final int accuracyPct;
  final PerformanceBand band;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(value: '$accuracyPct%', label: 'Accuracy'),
      _StatItem(value: formatTime(result.timeTakenSeconds), label: 'Time'),
      _StatItem(
        value: '${result.correctCount + result.wrongCount}/${result.totalQuestions}',
        label: 'Answered',
      ),
      _StatItem(value: band.grade, label: 'Grade'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 32,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppColors.gold,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChapterBreakdownCard
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterBreakdownCard extends StatelessWidget {
  const _ChapterBreakdownCard({
    required this.result,
    required this.chapterName,
    required this.band,
    required this.accuracy,
  });

  final ResultModel result;
  final String chapterName;
  final PerformanceBand band;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (accuracy * 100).round();
    final isWeak = accuracy < 0.5;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter Performance',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),

          // Chapter row
          Row(
            children: [
              Expanded(
                child: Text(
                  chapterName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.navy,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '$accuracyPct%',
                style: GoogleFonts.dmSans(
                  color: band.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: accuracy.clamp(0.0, 1.0),
              color: band.color,
              backgroundColor: AppColors.border,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),

          // Stats summary row
          Row(
            children: [
              _MiniStat(
                  label: 'Correct',
                  value: '${result.correctCount}',
                  color: AppColors.success),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'Wrong',
                  value: '${result.wrongCount}',
                  color: AppColors.error),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'Skipped',
                  value: '${result.skippedCount}',
                  color: AppColors.textSecondary),
            ],
          ),

          // Focus area warning
          if (isWeak) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amberLight,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Focus Area: $chapterName',
                      style: GoogleFonts.dmSans(
                        color: AppColors.warning,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
