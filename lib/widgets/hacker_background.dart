// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';

class HackerBackground extends StatefulWidget {
  final Widget child;
  const HackerBackground({super.key, required this.child});

  @override
  State<HackerBackground> createState() => _HackerBackgroundState();
}

class _HackerBackgroundState extends State<HackerBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _HackerPainter(_controller.value, _random),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.child,
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Encrypt File'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HackerPainter extends CustomPainter {
  final double progress;
  final Random random;
  _HackerPainter(this.progress, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    // Draw random binary code
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() + progress) % 1 * size.height;
      final binary = random.nextBool() ? '0' : '1';
      textPainter.text = TextSpan(
        text: binary,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 18,
          fontFamily: 'Courier',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _HackerPainter oldDelegate) => true;
}
