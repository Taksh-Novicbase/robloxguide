import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../data/app_repository.dart';
import '../models/item.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';

/// Mirrors `CommanRBXCalculatorActivity`: enter an amount and see the
/// converted result using the preset rate (BC 15, TBC 35, OBC 60, USD 80).
class RbxCalculatorScreen extends StatefulWidget {
  final ConversionType? conversion;

  const RbxCalculatorScreen({
    super.key,
    this.conversion,
  });

  @override
  State<RbxCalculatorScreen> createState() => _RbxCalculatorScreenState();
}

class _RbxCalculatorScreenState extends State<RbxCalculatorScreen> {
  final TextEditingController _input = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  ConversionType get _conversion =>
      widget.conversion ?? AppRepository.conversions.first;

  void _calculate() {
    final value = double.tryParse(_input.text.trim());
    if (value == null) {
      setState(() => _result = '');
      return;
    }
    final c = _conversion;
    final converted = c.toRbx ? value * c.rate : value / c.rate;
    setState(() {
      _result = converted == converted.roundToDouble()
          ? converted.toStringAsFixed(0)
          : converted.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _conversion;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: c.title),
            // Small Native Ad at top (matching frame 00:34)
            SmallNativeAdWidget(adUnitId: AdIds.toolsNativeId),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        c.iconPath,
                        width: 96,
                        height: 96,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.swap_horiz,
                          color: AppTheme.textSecondary,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _input,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Enter ${c.inputLabel}',
                        labelStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Result',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _result.isEmpty ? '0' : _result,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: AppTheme.accent,
                            ),
                          ),
                          Text(
                            c.outputLabel,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _calculate();
                        AdService.instance.showInterstitial(
                          context: context,
                          adUnitId: AdIds.toolsInterstitialId,
                        );
                      },
                      child: const Text('Convert'),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Banner Ad Container (mirrors activity_comman_rbxcalculator.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }

}
