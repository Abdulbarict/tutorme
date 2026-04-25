import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FadeInUp
// ─────────────────────────────────────────────────────────────────────────────

/// Simple fade + slide-up entrance animation.
/// Wrap a widget that should animate on first load.
class FadeInUp extends StatefulWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.offset = 24.0,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How many pixels the widget slides from below.
  final double offset;

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// StaggeredList — wraps children with incremental FadeInUp delays
// ─────────────────────────────────────────────────────────────────────────────

class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.baseDelay = Duration.zero,
  });

  final List<Widget> children;
  final Duration itemDelay;
  final Duration baseDelay;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (int i = 0; i < children.length; i++)
            FadeInUp(
              delay: baseDelay + itemDelay * i,
              child: children[i],
            ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CardFlip3D — 3-D flip card (front ↔ back)
// ─────────────────────────────────────────────────────────────────────────────

class CardFlip3D extends StatefulWidget {
  const CardFlip3D({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 400),
    this.showBack = false,
  });

  final Widget front;
  final Widget back;
  final Duration duration;
  final bool showBack;

  @override
  State<CardFlip3D> createState() => _CardFlip3DState();
}

class _CardFlip3DState extends State<CardFlip3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.showBack) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(CardFlip3D old) {
    super.didUpdateWidget(old);
    if (widget.showBack != old.showBack) {
      widget.showBack ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final angle = _anim.value * math.pi;
          final showFront = angle < math.pi / 2;
          final displayAngle = showFront ? angle : angle - math.pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(displayAngle),
            child: showFront ? widget.front : widget.back,
          );
        },
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ScoreRing — animated circular score indicator
// ─────────────────────────────────────────────────────────────────────────────

class ScoreRing extends StatefulWidget {
  const ScoreRing({
    super.key,
    required this.score, // 0.0 – 1.0
    this.size = 140.0,
    this.strokeWidth = 12.0,
    this.duration = const Duration(milliseconds: 1200),
    this.child,
  });

  final double score;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final Widget? child;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, child) => CustomPaint(
              painter: _ScoreRingPainter(
                value: _anim.value,
                strokeWidth: widget.strokeWidth,
              ),
              child: child,
            ),
            child: widget.child != null
                ? Center(child: widget.child)
                : null,
          ),
        ),
      );
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.value, required this.strokeWidth});

  final double value;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Score arc
    final scoreColor = value >= 0.75
        ? AppColors.success
        : value >= 0.5
            ? AppColors.warning
            : AppColors.error;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * value,
      false,
      Paint()
        ..color = scoreColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.value != value;
}

// ─────────────────────────────────────────────────────────────────────────────
// StreakShimmer — gold shimmer sweep over streak banner
// ─────────────────────────────────────────────────────────────────────────────

class StreakShimmer extends StatefulWidget {
  const StreakShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<StreakShimmer> createState() => _StreakShimmerState();
}

class _StreakShimmerState extends State<StreakShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: const [
                AppColors.gold,
                AppColors.goldLight,
                AppColors.gold,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcATop,
            child: child,
          ),
          child: widget.child,
        ),
      );
}
