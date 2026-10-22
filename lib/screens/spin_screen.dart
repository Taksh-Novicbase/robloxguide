import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../data/app_repository.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';
import '../widgets/wheel_painter.dart';

/// Mirrors `SpinActivity`: a 12-segment reward wheel that spins on tap and
/// awards the Robux value that lands under the pointer.
class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _rotation = 0;
  double _spinTarget = 0;
  double _startRotation = 0;
  String? _result;
  bool _spinning = false;

  static const List<Color> _palette = [
    Color(0xFFE8652D),
    Color(0xFF2E2E38),
    Color(0xFFF08A57),
    Color(0xFF3B3B46),
    Color(0xFFD4561E),
    Color(0xFF2A2A33),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addListener(() {
        setState(() {
          _rotation = _controller.value * _spinTarget;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _result = null;
      _startRotation = _rotation;
      // Mirrors the original: (Math.random() * 4320) + 1080 degrees.
      _spinTarget = (math.Random().nextDouble() * 4320.0) + 1080.0;
    });
    _controller.forward(from: 0).whenComplete(() {
      final total = (_startRotation + _spinTarget) % 360;
      final segments = AppRepository.spinValues.length;
      final idx = ((360 - total) % 360 ~/ (360 / segments))
          .clamp(0, segments - 1);
      final won = AppRepository.spinValues[idx];
      setState(() {
        _rotation = 0;
        _spinning = false;
        _result = won == '0' ? 'Better luck next time!' : 'You won $won Robux!';
      });
      if (won != '0') {
        appState.addRobux(int.tryParse(won) ?? 0);
      }
      // Show precached interstitial ad after spin
      AdService.instance.showInterstitial(
        context: context,
        adUnitId: AdIds.toolsInterstitialId,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Spin Wheel'),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _rotation * math.pi / 180,
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: WheelPainter(
                                values: AppRepository.spinValues,
                                palette: _palette,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            child: Transform.rotate(
                              angle: math.pi,
                              child: const Icon(
                                Icons.arrow_drop_down,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _result ?? 'Tap spin to try your luck!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: _result == null
                            ? AppTheme.textSecondary
                            : AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _spinning ? null : _spin,
                      child: Text(_spinning ? 'Spinning…' : 'Spin Now'),
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
            // Bottom Banner Ad Container (mirrors activity_spin.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }

}
