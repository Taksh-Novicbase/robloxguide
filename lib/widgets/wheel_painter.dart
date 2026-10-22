import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a 12-segment prize wheel with a label on each segment.
class WheelPainter extends CustomPainter {
  final List<String> values;
  final List<Color> palette;

  WheelPainter({required this.values, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi / values.length;

    for (var i = 0; i < values.length; i++) {
      final paint = Paint()..color = palette[i % palette.length];
      canvas.drawArc(rect, -math.pi / 2 + i * sweep, sweep, true, paint);
    }

    for (var i = 0; i < values.length; i++) {
      final angle = -math.pi / 2 + i * sweep + sweep / 2;
      final labelRadius = radius * 0.68;
      final pos = Offset(
        center.dx + math.cos(angle) * labelRadius,
        center.dy + math.sin(angle) * labelRadius,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: values[i],
          style: const TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(center, radius * 0.14, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()..color = const Color(0xFFE8652D),
    );
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      oldDelegate.values != values;
}
