import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _dotsCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent over navy background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoCtrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authUser = ref.read(authStateChangesProvider).valueOrNull;
    if (authUser == null) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // Check if user has selected their CMA level
    final profile = await ref.read(firestoreServiceProvider).getUserProfile();
    if (!mounted) return;
    if (profile == null) {
      context.go(AppRoutes.levelSelect);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _dotsCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Diagonal lines background ──────────────────────────────────
          CustomPaint(
            size: MediaQuery.sizeOf(context),
            painter: _DiagonalLinesPainter(),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: const _AppLogo(),
                  ),
                ),

                const SizedBox(height: 16),

                // App name
                FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    'Tutor Me',
                    style: AppTextStyles.displayMedium.copyWith(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    'Master Every Question. Ace Every Exam.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Loading dots
                _LoadingDots(controller: _dotsCtrl),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo widget ───────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        // Gold bookmark ribbon — bottom right
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loading dots ──────────────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            // Each dot fades in with a 0.3 offset
            final value = ((controller.value - i * 0.3) % 1.0).clamp(0.0, 1.0);
            final opacity =
                value < 0.5 ? value * 2 : (1.0 - value) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Diagonal lines painter ────────────────────────────────────────────────────

class _DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    const angle = 15.0 * math.pi / 180; // 15 degrees
    final lineLength = size.longestSide * 2;

    for (double i = -lineLength; i < lineLength; i += spacing) {
      final start = Offset(i, 0);
      final end = Offset(
        i + lineLength * math.cos(angle),
        lineLength * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
