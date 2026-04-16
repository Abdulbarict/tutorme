import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    await _fadeCtrl.reverse();
    _pageCtrl.jumpToPage(page);
    setState(() => _currentPage = page);
    await _fadeCtrl.forward();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _onSkip() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          FadeTransition(
            opacity: _fadeAnim,
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Slide1(onNext: _onNext, onSkip: _onSkip, currentPage: _currentPage),
                _Slide2(onNext: _onNext, onSkip: _onSkip, currentPage: _currentPage),
                _Slide3(onNext: _onNext, onLoginTap: () => context.go(AppRoutes.login), currentPage: _currentPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared bottom nav area ───────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentPage,
    required this.onNext,
    required this.nextLabel,
    required this.nextVariant,
    this.belowButton,
  });

  final int currentPage;
  final VoidCallback onNext;
  final String nextLabel;
  final _ButtonVariant nextVariant;
  final Widget? belowButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 7,
                height: active ? 7 : 7,
                decoration: BoxDecoration(
                  color: active ? AppColors.navy : AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nextVariant == _ButtonVariant.primary)
            AppButton.primary(label: nextLabel, onPressed: onNext)
          else
            AppButton.secondary(label: nextLabel, onPressed: onNext),
          if (belowButton != null) ...[
            const SizedBox(height: AppSpacing.lg),
            belowButton!,
          ],
        ],
      ),
    );
  }
}

enum _ButtonVariant { primary, secondary }

// ── Slide 1 ──────────────────────────────────────────────────────────────────

class _Slide1 extends StatelessWidget {
  const _Slide1({
    required this.onNext,
    required this.onSkip,
    required this.currentPage,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // White background
        Container(color: Colors.white),

        // Navy wave — top 45 %
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: size.height * 0.48,
            decoration: const BoxDecoration(
              gradient: AppColors.navyGradient,
            ),
          ),
        ),

        // Skip button top right
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Main column
        Column(
          children: [
            // Top heading area
            SizedBox(
              height: size.height * 0.38,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'All PYQs.',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        'One App.',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Illustration
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _PaperStackIllustration(),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Access chapter-wise Previous Year Questions for CMA Inter and Final — with model answers and explanations.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _BottomNav(
              currentPage: currentPage,
              onNext: onNext,
              nextLabel: 'Next',
              nextVariant: _ButtonVariant.primary,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Slide 2 ──────────────────────────────────────────────────────────────────

class _Slide2 extends StatelessWidget {
  const _Slide2({
    required this.onNext,
    required this.onSkip,
    required this.currentPage,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBlueTint,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'Practice at Your Pace.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Test Under Pressure.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Two phone mockups
                const _DualPhoneMockup(),

                const SizedBox(height: AppSpacing.xxl),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Switch between relaxed practice sessions and exam-style mock tests — all in one place.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),

                const Spacer(),

                _BottomNav(
                  currentPage: currentPage,
                  onNext: onNext,
                  nextLabel: 'Next',
                  nextVariant: _ButtonVariant.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 3 ──────────────────────────────────────────────────────────────────

class _Slide3 extends StatelessWidget {
  const _Slide3({
    required this.onNext,
    required this.onLoginTap,
    required this.currentPage,
  });

  final VoidCallback onNext;
  final VoidCallback onLoginTap;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Radial glow top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "See How Far\nYou've Come.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      height: 1.25,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Trophy + chart illustration
                const _TrophyIllustration(),

                const SizedBox(height: AppSpacing.xxl),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Get your score, accuracy, time analysis, and smart feedback — instantly after every test.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),

                const Spacer(),

                _BottomNav(
                  currentPage: currentPage,
                  onNext: onNext,
                  nextLabel: 'Get Started',
                  nextVariant: _ButtonVariant.secondary,
                  belowButton: GestureDetector(
                    onTap: onLoginTap,
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ── Wave Clipper ──────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height + 20,
      size.width * 0.5,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Illustration: Paper Stack ─────────────────────────────────────────────────

class _PaperStackIllustration extends StatelessWidget {
  const _PaperStackIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back paper
          Transform.rotate(
            angle: 0.12,
            child: _ExamPaper(
              label: 'Paper 5',
              color: AppColors.lightBlueTint,
              offset: const Offset(12, 8),
            ),
          ),
          // Middle paper
          Transform.rotate(
            angle: -0.06,
            child: _ExamPaper(
              label: 'Paper 3',
              color: const Color(0xFFF0F4FF),
              offset: const Offset(-6, 6),
            ),
          ),
          // Front paper
          _ExamPaper(
            label: 'Paper 1',
            color: Colors.white,
            offset: Offset.zero,
          ),
          // Floating gold bookmarks
          Positioned(
            top: 10,
            right: 20,
            child: Transform.rotate(
              angle: 0.3,
              child: const Icon(Icons.bookmark_rounded,
                  color: AppColors.gold, size: 22),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Transform.rotate(
              angle: -0.2,
              child: const Icon(Icons.bookmark_rounded,
                  color: AppColors.goldLight, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamPaper extends StatelessWidget {
  const _ExamPaper({
    required this.label,
    required this.color,
    required this.offset,
  });

  final String label;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    height: 4,
                    width: [100.0, 80.0, 90.0][i],
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Illustration: Dual Phone Mockup ───────────────────────────────────────────

class _DualPhoneMockup extends StatelessWidget {
  const _DualPhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Practice phone
        _PhoneMockup(
          bgColor: Colors.white,
          child: _PracticeCard(),
        ),
        const SizedBox(width: 16),
        // Test phone
        _PhoneMockup(
          bgColor: AppColors.navy,
          child: _TestCard(),
          elevated: true,
        ),
      ],
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({
    required this.bgColor,
    required this.child,
    this.elevated = false,
  });

  final Color bgColor;
  final Widget child;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: elevated ? 190 : 170,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: elevated ? AppColors.gold : AppColors.border,
          width: elevated ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notch
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Practice Mode',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.lightBlueTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'What is the formula for Working Capital?',
              style: GoogleFonts.dmSans(
                fontSize: 8,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '✓  Got it!',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Mock Test',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '12:34',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Q 8 of 30',
            style: GoogleFonts.dmSans(
              fontSize: 8,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: 0.27,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ── Illustration: Trophy ──────────────────────────────────────────────────────

class _TrophyIllustration extends StatelessWidget {
  const _TrophyIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bar chart bars behind trophy
          Positioned(
            bottom: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(height: 60, label: 'Apr'),
                const SizedBox(width: 10),
                _Bar(height: 85, label: 'May', isHighlight: true),
                const SizedBox(width: 10),
                _Bar(height: 110, label: 'Jun', isHighlight: true),
              ],
            ),
          ),

          // Trophy outline (CustomPaint)
          CustomPaint(
            size: const Size(80, 90),
            painter: _TrophyPainter(),
          ),

          // Badge circles
          Positioned(
            top: 8,
            left: 20,
            child: _Badge(percent: '71%'),
          ),
          Positioned(
            top: 0,
            right: 18,
            child: _Badge(percent: '92%', isGold: true),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    required this.label,
    this.isHighlight = false,
  });

  final double height;
  final String label;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: isHighlight ? 1.0 : 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.percent, this.isGold = false});

  final String percent;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isGold ? AppColors.gold : AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: (isGold ? AppColors.gold : AppColors.navy)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          percent,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Cup body
    final cupPath = Path()
      ..moveTo(w * 0.18, h * 0.08)
      ..lineTo(w * 0.82, h * 0.08)
      ..lineTo(w * 0.75, h * 0.52)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w * 0.25, h * 0.52)
      ..close();
    canvas.drawPath(cupPath, paint);

    // Handles
    canvas.drawArc(
      Rect.fromLTWH(w * 0.0, h * 0.10, w * 0.25, h * 0.28),
      math.pi / 2,
      math.pi,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.75, h * 0.10, w * 0.25, h * 0.28),
      -math.pi / 2,
      math.pi,
      false,
      paint,
    );

    // Stem
    canvas.drawLine(
      Offset(w * 0.42, h * 0.63),
      Offset(w * 0.42, h * 0.82),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.58, h * 0.63),
      Offset(w * 0.58, h * 0.82),
      paint,
    );

    // Base
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.28,
        h * 0.82,
        w * 0.72,
        h * 0.92,
        const Radius.circular(4),
      ),
      paint,
    );

    // Star in cup
    _drawStar(canvas, Offset(w * 0.5, h * 0.33), 12, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = Offset(
        center.dx + radius * math.cos((i * 4 * math.pi / 5) - math.pi / 2),
        center.dy + radius * math.sin((i * 4 * math.pi / 5) - math.pi / 2),
      );
      final inner = Offset(
        center.dx +
            (radius * 0.4) *
                math.cos(
                    ((i * 4 + 2) * math.pi / 5) - math.pi / 2),
        center.dy +
            (radius * 0.4) *
                math.sin(
                    ((i * 4 + 2) * math.pi / 5) - math.pi / 2),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
