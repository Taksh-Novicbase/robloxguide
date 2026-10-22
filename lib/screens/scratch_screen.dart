import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';

/// A scratch-to-reveal card that awards a random Robux amount.
class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key});

  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  final List<Offset> _points = [];
  final Set<String> _cells = {};
  int? _reward;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _reward = 10 + math.Random().nextInt(90);
  }

  void _scratch(Offset local) {
    if (_revealed) return;
    setState(() {
      _points.add(local);
      // Track scratched grid cells to estimate coverage.
      final cx = (local.dx ~/ 24);
      final cy = (local.dy ~/ 24);
      _cells.add('$cx,$cy');
      if (_cells.length >= 90) _finish();
    });
  }

  void _finish() {
    _revealed = true;
    appState.addRobux(_reward ?? 0);
    AdService.instance.showInterstitial(
      context: context,
      adUnitId: AdIds.toolsInterstitialId,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Scratch & Win'),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _revealed
                          ? 'You won $_reward Robux!'
                          : 'Scratch the card to reveal your prize',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onPanUpdate: (d) => _scratch(d.localPosition),
                      onPanDown: (d) => _scratch(d.localPosition),
                      child: SizedBox(
                        width: 300,
                        height: 180,
                        child: Stack(
                          children: [
                            // Prize layer.
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.accent,
                                    AppTheme.accentSoft,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _reward != null ? '$_reward RBX' : '?',
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 34,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Scratch layer.
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ScratchPainter(points: _points),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _points.clear();
                          _cells.clear();
                          _revealed = false;
                          _reward = 10 + math.Random().nextInt(90);
                        });
                      },
                      child: const Text('New Card'),
                    ),
                    const SizedBox(height: 16),
                    MediumNativeAdWidget(
                      margin: EdgeInsets.zero,
                      adUnitId: AdIds.toolsNativeId,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Banner Ad Container (mirrors activity_scratch.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }

}

class _ScratchPainter extends CustomPainter {
  final List<Offset> points;

  _ScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF55555F);
    canvas.drawRect(Offset.zero & size, bg);

    final eraser = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
    for (final p in points) {
      canvas.drawCircle(p, 22, eraser);
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) => true;
}
