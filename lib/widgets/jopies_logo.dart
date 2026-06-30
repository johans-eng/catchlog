import 'dart:math';

import 'package:flutter/material.dart';

/// In-app logo: dark circle, blue ring, white J — matches the home screen ring.
class JopiesLogo extends StatelessWidget {
  final double size;

  const JopiesLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CustomPaint(
          size: Size.square(size),
          painter: _JopiesLogoPainter(),
          child: Center(
            child: Text(
              'J',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w800,
                height: 1,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.5),
                    blurRadius: size * 0.12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JopiesLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = side / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF141416),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF0A84FF).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.04,
    );

    final rect = Rect.fromCircle(center: center, radius: radius - side * 0.06);
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF64D2FF), Color(0xFF0A84FF)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, pi * 0.55, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
