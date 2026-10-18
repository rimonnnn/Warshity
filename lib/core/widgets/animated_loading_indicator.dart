import 'package:flutter/material.dart';

class AnimatedLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedLoadingIndicator({
    super.key,
    required this.color,
    this.size = 5,
  });

  @override
  State<AnimatedLoadingIndicator> createState() =>
      _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size.clamp(4.0, 6.0);

    return SizedBox(
      width: dotSize * 4,
      height: dotSize * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final phase = (_controller.value - index * 0.2) % 1.0;

              final opacity = (0.35 + 0.65 * (1 - (phase - 0.5).abs() * 2))
                  .clamp(0.35, 1.0);

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
