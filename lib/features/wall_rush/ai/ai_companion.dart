import 'dart:math';

import '../engine/engine.dart';
import 'ai_player.dart';
import 'ai_utils.dart';
import 'hard_ai.dart';
import 'medium_ai.dart';

class AiAdvice {
  final Move move;
  final String title;
  final String reasoning;
  final int myShortestPath;
  final int opponentShortestPath;

  AiAdvice({
    required this.move,
    required this.title,
    required this.reasoning,
    required this.myShortestPath,
    required this.opponentShortestPath,
  });
}

class AiCompanion {
  static AiAdvice getHint(GameState state) {
    final me = state.currentPlayer;
    final myDist = pathLengthOf(state, me);
    final opp = state.activePlayers.firstWhere((p) => p != me);
    final oppDist = pathLengthOf(state, opp);

    // Run Hard AI evaluator
    final rng = Random();
    final hardAi = HardAi(rng);
    final chosenMove = hardAi.chooseMove(state);

    if (chosenMove is PawnMove) {
      if (state.isGoal(me, chosenMove.to)) {
        return AiAdvice(
          move: chosenMove,
          title: 'Victory Step!',
          reasoning: 'Moving to (${chosenMove.to.row}, ${chosenMove.to.col}) reaches your goal line and claims immediate victory!',
          myShortestPath: 1,
          opponentShortestPath: oppDist,
        );
      }
      return AiAdvice(
        move: chosenMove,
        title: 'Advance Pawn',
        reasoning: 'Step to (${chosenMove.to.row}, ${chosenMove.to.col}). This follows your optimal BFS path towards the goal line ($myDist steps remaining).',
        myShortestPath: myDist,
        opponentShortestPath: oppDist,
      );
    } else if (chosenMove is WallMove) {
      final w = chosenMove.wall;
      final gain = wallGain(state, w);
      final orientationName = w.isHorizontal ? 'Horizontal' : 'Vertical';
      return AiAdvice(
        move: chosenMove,
        title: 'Tactical $orientationName Wall Placement',
        reasoning: 'Drop a $orientationName wall at groove (${w.row}, ${w.col}). This adds +$gain detour steps to the opponent\'s route while leaving your passage clear!',
        myShortestPath: myDist,
        opponentShortestPath: oppDist,
      );
    }

    // Fallback
    final bestPawn = bestPawnMove(state, rng);
    return AiAdvice(
      move: bestPawn,
      title: 'Advance Pawn',
      reasoning: 'Step to (${bestPawn.to.row}, ${bestPawn.to.col}) along the shortest path to goal.',
      myShortestPath: myDist,
      opponentShortestPath: oppDist,
    );
  }
}
