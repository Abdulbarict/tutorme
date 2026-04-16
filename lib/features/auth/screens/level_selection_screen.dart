import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class LevelSelectionScreen extends ConsumerStatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  ConsumerState<LevelSelectionScreen> createState() =>
      _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends ConsumerState<LevelSelectionScreen>
    with TickerProviderStateMixin {
  String? _selected; // 'inter' | 'final'
  bool _isLoading = false;

  late final AnimationController _bgCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _contentCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selected == null) return;
    setState(() => _isLoading = true);

    try {
      final uid = ref.read(authServiceProvider).currentUid;
      if (uid == null) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      // FIX S3: Use UserService instead of raw FirebaseFirestore.instance.
      // This keeps all Firestore writes inside the service layer, ensuring
      // the level value always uses CmaLevel.firestoreValue, not a magic string.
      final cmaLevel =
          _selected == 'inter' ? CmaLevel.intermediate : CmaLevel.final_;

      await ref.read(userServiceProvider).updateProfile(level: cmaLevel);

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onDecideLater() async {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateChangesProvider).valueOrNull;
    final displayName = authUser?.displayName ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Animated background decoration ──────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _LevelBgPainter(animation: _bgCtrl)),
          ),

          // ── Content ──────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Greeting ──────────────────────────────────
                      Text(
                        'Welcome, ${_formatName(displayName)}!',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'What are you preparing for?',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxxxl),

                      // ── CMA Intermediate card ─────────────────────
                      _LevelCard(
                        title: 'CMA Intermediate',
                        subtitle: 'Paper 1–8',
                        icon: Icons.menu_book_rounded,
                        isSelected: _selected == 'inter',
                        onTap: () => setState(() {
                          _selected = _selected == 'inter' ? null : 'inter';
                        }),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── CMA Final card ────────────────────────────
                      _LevelCard(
                        title: 'CMA Final',
                        subtitle: 'Paper 1–8',
                        icon: Icons.school_rounded,
                        isSelected: _selected == 'final',
                        onTap: () => setState(() {
                          _selected = _selected == 'final' ? null : 'final';
                        }),
                      ),

                      const SizedBox(height: AppSpacing.xxxxxl),

                      // ── Continue button ───────────────────────────
                      AppButton.primary(
                        label: 'Continue →',
                        onPressed:
                            (_selected == null || _isLoading) ? null : _onContinue,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Decide later ──────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: _onDecideLater,
                          child: Text(
                            "I'll decide later",
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatName(String name) {
    if (name.isEmpty) return 'there';
    final first = name.split(' ').first;
    if (first.length > 12) return first.substring(0, 12);
    return first;
  }
}

// ── Level Card ────────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Icon in gold circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.gold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Title + subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.65)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Check circle (visible when selected)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
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

// ── Background Painter ────────────────────────────────────────────────────────

class _LevelBgPainter extends CustomPainter {
  _LevelBgPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    // Large gold circle top-right
    final circlePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.06 * t)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width + 40, -60),
      200 * t,
      circlePaint,
    );

    // Small accent circle bottom-left
    final accentPaint = Paint()
      ..color = AppColors.navyLight.withValues(alpha: 0.4 * t)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-60, size.height + 40),
      160 * t,
      accentPaint,
    );

    // Subtle horizontal rule lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04 * t)
      ..strokeWidth = 1;

    for (double y = 80; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelBgPainter old) => true;
}
