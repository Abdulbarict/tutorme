import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../home/providers/home_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    final homeStatsAsync = ref.watch(homeStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Progress',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (val) => setState(() => _selectedPeriod = val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'Month', child: Text('Month')),
              PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
            icon: const Icon(Icons.calendar_today, color: AppColors.navy, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: homeStatsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOverallStats(stats),
              const SizedBox(height: 20),
              _buildSubjectAccuracy(),
              const SizedBox(height: 16),
              _buildStreakAndActivity(stats),
              const SizedBox(height: 16),
              _buildRecentTests(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildOverallStats(HomeStats stats) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Performance',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${stats.questionsThisWeek}',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Practiced',
                      style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${stats.testsThisWeek}',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tests',
                      style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(stats.avgAccuracy * 100).round()}%',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You're in the top 30% of CMA Foundation students",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectAccuracy() {
    // Mock subject data
    final subjects = [
      {'name': 'Financial Accounting', 'accuracy': 0.85},
      {'name': 'Cost Accounting', 'accuracy': 0.72},
      {'name': 'Law & Ethics', 'accuracy': 0.65},
      {'name': 'Maths & Stats', 'accuracy': 0.58},
    ];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy by Subject',
            style: GoogleFonts.dmSans(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((sub) {
            final double acc = sub['accuracy'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      sub['name'] as String,
                      style: GoogleFonts.dmSans(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: acc,
                        color: AppColors.gold,
                        backgroundColor: AppColors.border,
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(acc * 100).round()}%',
                      style: GoogleFonts.dmSans(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStreakAndActivity(HomeStats stats) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🔥 Current Streak',
                style: GoogleFonts.dmSans(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${stats.streak} days',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Best streak: ${stats.bestStreak} days',
            style: GoogleFonts.dmSans(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Activity Last 30 Days',
            style: GoogleFonts.dmSans(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _HeatmapPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTests() {
    // Mock recent tests
    final tests = [
      {'date': 'Dec 22, 2025', 'desc': 'Cost Accounting • Material Cost', 'acc': 85},
      {'date': 'Dec 18, 2025', 'desc': 'Financial Accounting • Final Accounts', 'acc': 72},
      {'date': 'Dec 15, 2025', 'desc': 'Maths & Stats • Probability', 'acc': 45},
    ];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Tests',
                style: GoogleFonts.dmSans(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'See All →',
                style: GoogleFonts.dmSans(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tests.asMap().entries.map((entry) {
            final idx = entry.key;
            final test = entry.value;
            final acc = test['acc'] as int;

            Color bandColor = AppColors.success;
            String bandText = 'Excellent';
            if (acc < 50) {
              bandColor = AppColors.error;
              bandText = 'Needs Work';
            } else if (acc < 75) {
              bandColor = AppColors.warning;
              bandText = 'Good';
            }

            return Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test['date'] as String,
                                style: GoogleFonts.dmSans(
                                  color: AppColors.navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                test['desc'] as String,
                                style: GoogleFonts.dmSans(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bandColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bandText,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$acc%',
                            style: GoogleFonts.dmSans(
                              color: bandColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.gold, size: 20),
                      ],
                    ),
                  ),
                ),
                if (idx < tests.length - 1)
                  const Divider(color: AppColors.border, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 28.0;
    const double gap = 3.0;
    const double startX = 30.0;
    const double startY = 20.0;
    
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw day labels
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    for (int i = 0; i < 7; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(startX + (i * (cellSize + gap)) + (cellSize / 2) - (textPainter.width / 2), 0),
      );
    }
    
    // Draw week labels (approximate)
    final weeks = ['W1', 'W2', 'W3', 'W4', 'W5'];
    for (int i = 0; i < 5; i++) {
      textPainter.text = TextSpan(
        text: weeks[i],
        style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(0, startY + (i * (cellSize + gap)) + (cellSize / 2) - (textPainter.height / 2)),
      );
    }
    
    // Draw cells
    final random = Random(42); // fixed seed for consistent demo
    
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        final val = random.nextInt(100);
        Color cellColor = Colors.white;
        
        if (val < 40) {
          cellColor = Colors.white; // no activity
        } else if (val < 70) {
          cellColor = const Color(0xFFBFD5F5); // light
        } else if (val < 85) {
          cellColor = AppColors.navy.withValues(alpha: 0.6); // medium
        } else if (val < 95) {
          cellColor = AppColors.navy; // high
        } else {
          cellColor = AppColors.gold; // test taken
        }
        
        paint.color = cellColor;
        if (cellColor == Colors.white) {
          // Add border for white cells
          paint.color = AppColors.border;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX + col * (cellSize + gap), startY + row * (cellSize + gap), cellSize, cellSize),
              const Radius.circular(4),
            ),
            paint,
          );
          paint.color = Colors.white;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX + col * (cellSize + gap) + 1, startY + row * (cellSize + gap) + 1, cellSize - 2, cellSize - 2),
              const Radius.circular(4),
            ),
            paint,
          );
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX + col * (cellSize + gap), startY + row * (cellSize + gap), cellSize, cellSize),
              const Radius.circular(4),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
