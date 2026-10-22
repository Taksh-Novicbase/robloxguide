import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';

/// A small logic quiz (mirrors the "Logic Quiz" feature). Answering all
/// questions correctly awards a Robux bonus.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _score = 0;

  static const List<_Question> _questions = [
    _Question(
      prompt: 'If a shirt costs 15 Robux and you have 60, how many can you buy?',
      options: ['3', '4', '5', '2'],
      answer: 1,
    ),
    _Question(
      prompt: '1 Dollar converts to how many Robux in this app?',
      options: ['60', '80', '100', '35'],
      answer: 1,
    ),
    _Question(
      prompt: 'Which membership tier gives the highest Robux rate?',
      options: ['BC', 'TBC', 'OBC', 'None'],
      answer: 2,
    ),
    _Question(
      prompt: 'What is 92 + 8?',
      options: ['100', '98', '90', '102'],
      answer: 0,
    ),
    _Question(
      prompt: 'How many segments are on the spin wheel?',
      options: ['8', '10', '12', '6'],
      answer: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Logic Quiz'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: _index / _questions.length,
                backgroundColor: AppTheme.surface,
                color: AppTheme.accent,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${_index + 1} / ${_questions.length}',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.prompt,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (var i = 0; i < q.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _answerButton(i, q.options[i]),
                      ),
                    const SizedBox(height: 8),
                    MediumNativeAdWidget(
                      margin: EdgeInsets.zero,
                      adUnitId: AdIds.toolsNativeId,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Banner Ad Container (mirrors activity_quiz.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }


  Widget _answerButton(int i, String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _answer(i),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          side: const BorderSide(color: AppTheme.surface),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _answer(int i) {
    final q = _questions[_index];
    if (i == q.answer) _score++;
    if (_index + 1 < _questions.length) {
      setState(() => _index++);
    } else {
      final win = _score == _questions.length;
      appState.addRobux(win ? 50 : 5);
      // Precached interstitial ad after quiz completion
      AdService.instance.showInterstitial(
        context: context,
        adUnitId: AdIds.toolsInterstitialId,
      );
      showDialog<void>(

        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            win ? 'Perfect Score!' : 'Quiz Complete',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Text(
            'You scored $_score / ${_questions.length}.\n'
            'Earned ${win ? 50 : 5} Robux!',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}

class _Question {
  final String prompt;
  final List<String> options;
  final int answer;

  const _Question({
    required this.prompt,
    required this.options,
    required this.answer,
  });
}
