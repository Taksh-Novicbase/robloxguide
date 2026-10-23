import 'dart:math';

import '../engine/engine.dart';
import 'easy_ai.dart';
import 'hard_ai.dart';
import 'medium_ai.dart';

enum Difficulty { easy, medium, hard }

extension DifficultyNames on Difficulty {
  String get displayName => switch (this) {
    Difficulty.easy => 'Easy (Novice)',
    Difficulty.medium => 'Medium (Tactician)',
    Difficulty.hard => 'Hard (Grandmaster Minimax)',
  };

  String get description => switch (this) {
    Difficulty.easy =>
      'Rushes forward with direct moves. Occasionally places random walls.',
    Difficulty.medium =>
      'Calculates BFS shortest paths greedily and blocks your route whenever it gains >= 2 steps.',
    Difficulty.hard =>
      'Advanced Minimax with Alpha-Beta pruning (depth 2-3). Anticipates counter-traps and values wall economy.',
  };
}

abstract interface class AiPlayer {
  Move chooseMove(GameState state);
}

AiPlayer createAi(Difficulty difficulty, {Random? random}) {
  final rng = random ?? Random();
  return switch (difficulty) {
    Difficulty.easy => EasyAi(rng),
    Difficulty.medium => MediumAi(rng),
    Difficulty.hard => HardAi(rng),
  };
}
