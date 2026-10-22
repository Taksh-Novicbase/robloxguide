import 'package:flutter/material.dart';

import '../../../services/default_app_service.dart';

/// Pill-shaped Google Search Bar Widget mirroring Android Launcher home search bar
/// (`fragment_launcher_home.xml` `@+id/search_bar`).
class GoogleSearchBarWidget extends StatelessWidget {
  const GoogleSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DefaultAppService.openCustomTab();
        DefaultAppService.launchSystemApp('search');
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(240),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withAlpha(180),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Google 'G' Logo
            SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: _GoogleGLogoPainter(),
              ),
            ),
            const SizedBox(width: 14),

            // Search text placeholder
            const Expanded(
              child: Text(
                'Search...',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F6368),
                ),
              ),
            ),

            // Voice Search Mic Icon
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  DefaultAppService.openCustomTab();
                  DefaultAppService.launchSystemApp('search');
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.mic_rounded,
                    color: Color(0xFF4285F4),
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Google Lens Camera Icon
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  DefaultAppService.openCustomTab();
                  DefaultAppService.launchSystemApp('camera');
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF34A853),
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw the authentic 4-color Google "G" emblem.
class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 5.0;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const pi = 3.1415926535897932;

    // Red arc (top)
    canvas.drawArc(rect, -pi * 0.75, pi * 0.55, false, paintRed);
    // Yellow arc (left)
    canvas.drawArc(rect, -pi * 1.25, pi * 0.55, false, paintYellow);
    // Green arc (bottom)
    canvas.drawArc(rect, pi * 0.25, pi * 0.55, false, paintGreen);
    // Blue arc & crossbar
    canvas.drawArc(rect, -pi * 0.2, pi * 0.45, false, paintBlue);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Crossbar of G
    final barRect = Rect.fromLTRB(
      center.dx - 1,
      center.dy - strokeWidth / 2,
      size.width - 2,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
