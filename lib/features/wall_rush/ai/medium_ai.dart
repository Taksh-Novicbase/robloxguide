import 'dart:math';

import '../engine/engine.dart';
import 'ai_player.dart';
import 'ai_utils.dart';

/// Greedy tactician: places a wall if it gains >= 2 steps (or >= 1 when falling behind),
/// otherwise advances pawn on the BFS shortest path.
class MediumAi implements AiPlayer {
  MediumAi(this._rng);

  final Random _rng;

  @override
  Move chooseMove(GameState state) {
    final me = state.currentPlayer;
    final step = bestPawnMove(state, _rng);
    if (state.isGoal(me, step.to)) return step;

    final myLen = pathLengthOf(state, me);
    final oppLen = [
      for (final opp in state.activePlayers)
        if (opp != me) pathLengthOf(state, opp),
    ].reduce(min);

    Wall? bestWall;
    var bestGain = 0;
    final walls = candidateWalls(state)..shuffle(_rng);
    for (final w in walls) {
      final gain = wallGain(state, w);
      if (gain > bestGain) {
        bestGain = gain;
        bestWall = w;
      }
    }

    final opponentAhead = oppLen <= myLen;
    if (bestWall != null &&
        (bestGain >= 2 || (opponentAhead && bestGain >= 1))) {
      return WallMove(bestWall);
    }
    return step;
  }
}
