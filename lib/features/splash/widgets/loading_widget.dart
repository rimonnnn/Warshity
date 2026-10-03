// lib/loading_screen.dart
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({
    super.key,
    this.progress,
    required this.messageKey,
    this.animateIntro = true,
  });

  final double? progress;
  final String messageKey;
  final bool animateIntro;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: widget.animateIntro ? 0 : 1,
  )..forward();

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.messageKey.tr();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _spin,
                      child: CustomPaint(
                        size: const Size(150, 150),
                        painter: _RingPainter(),
                      ),
                    ),
                    ScaleTransition(
                      scale: Tween(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _pulse,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppAssets.logo,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'masiter'.tr(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'your_buddiness_under_controle'.tr(),
                style: TextStyle(fontSize: 14, color: context.colors.onSurface),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: widget.progress ?? 0),
                    duration: const Duration(milliseconds: 300),
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: widget.progress == null ? null : v,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF1AA6B7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  msg,
                  key: ValueKey(msg),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurface,
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

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Color(0x001AA6B7), Color(0xFF1AA6B7), Color(0xFF2E9E5B)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(4), 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
