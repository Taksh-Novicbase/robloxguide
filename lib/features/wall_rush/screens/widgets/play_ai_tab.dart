import 'package:flutter/material.dart';

import '../../ai/ai.dart';
import '../../controllers/board_controller.dart';
import '../../engine/engine.dart';
import 'interactive_board_widget.dart';

class PlayAiTab extends StatelessWidget {
  const PlayAiTab({
    super.key,
    required this.controller,
  });

  final BoardController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final advice = controller.lastAdvice;
        final previewWall = controller.previewWall;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Match Mode & AI Tier Bar (Zero overflow)
              _buildStatusBar(context),

              const SizedBox(height: 10),

              // Players & Wall Reserves Scoreboard (Zero overflow)
              _buildScoreboard(context),

              const SizedBox(height: 12),

              // The Upgraded 9x9 Quoridor Board
              InteractiveBoardWidget(controller: controller),

              const SizedBox(height: 12),

              // Play Mode Selector (Move Pawn vs Place Wall)
              _buildPlayModeSelector(context),

              // Precision Wall Placement Controls (appears when wall is previewed)
              if (previewWall != null) ...[
                const SizedBox(height: 10),
                _buildWallPlacementPad(context, previewWall),
              ],

              // Engine Status / Error Message
              if (controller.statusMessage != null && previewWall == null) ...[
                const SizedBox(height: 8),
                _buildMessageBar(controller.statusMessage!),
              ],

              // AI Advice Card
              if (advice != null) ...[
                const SizedBox(height: 10),
                _buildAdviceCard(context, advice),
              ],

              const SizedBox(height: 12),

              // Match Action Controls (Hint, Path, Undo, Reset)
              _buildActionControls(context),

              // Game Over Banner
              if (state.isOver) ...[
                const SizedBox(height: 14),
                _buildGameOverBanner(context),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          // Game Variant Selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GameVariant>(
                value: controller.variant,
                isDense: true,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.amber, size: 20),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                items: const [
                  DropdownMenuItem(
                    value: GameVariant.classic,
                    child: Text('⚔️ Classic (10)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: GameVariant.crown,
                    child: Text('👑 Crown Rush (6)', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (variant) {
                  if (variant != null) {
                    controller.startNewGame(variant: variant);
                  }
                },
              ),
            ),
          ),

          Container(
            width: 1,
            height: 20,
            color: const Color(0xFF334155),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // AI Difficulty Selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Difficulty>(
                value: controller.difficulty,
                isDense: true,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 16),
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                items: const [
                  DropdownMenuItem(
                    value: Difficulty.easy,
                    child: Text('Easy Bot', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: Difficulty.medium,
                    child: Text('Medium (BFS)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: Difficulty.hard,
                    child: Text('Hard (Minimax)', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (diff) {
                  if (diff != null) {
                    controller.setDifficulty(diff);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard(BuildContext context) {
    final state = controller.state;
    final isRedTurn = state.currentPlayer == Player.red && !state.isOver;
    final isBlueTurn = state.currentPlayer == Player.blue && !state.isOver;

    return Row(
      children: [
        // Red Player (Human)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isRedTurn
                  ? const Color(0xFFEF4444).withOpacity(0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRedTurn ? const Color(0xFFEF4444) : const Color(0xFF334155),
                width: isRedTurn ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'You (Red)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRedTurn) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TURN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.redWallsLeft} walls left',
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Blue Player (Local AI)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isBlueTurn
                  ? const Color(0xFF06B6D4).withOpacity(0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBlueTurn ? const Color(0xFF06B6D4) : const Color(0xFF334155),
                width: isBlueTurn ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFF06B6D4),
                    shape: BoxShape.circle,
                  ),
                  child: controller.isAiThinking
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.smart_toy, color: Colors.white, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              controller.isAiThinking ? 'Thinking...' : 'AI (Blue)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isBlueTurn) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.blueWallsLeft} walls left',
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayModeSelector(BuildContext context) {
    final isPawnMode = controller.playMode == PlayMode.movePawn;
    final isWallMode = controller.playMode == PlayMode.placeWall;
    final isH = controller.wallOrientation == WallOrientation.horizontal;
    final wallsLeft = controller.state.wallsLeftOf(controller.state.currentPlayer);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          // Move Pawn Tab
          Expanded(
            child: InkWell(
              onTap: () => controller.setPlayMode(PlayMode.movePawn),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isPawnMode ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_run_rounded,
                      size: 16,
                      color: isPawnMode ? Colors.white : Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Move Pawn',
                      style: TextStyle(
                        color: isPawnMode ? Colors.white : Colors.white60,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal Wall Tab
          Expanded(
            child: InkWell(
              onTap: wallsLeft > 0
                  ? () => controller.selectWallMode(WallOrientation.horizontal)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isWallMode && isH ? Colors.amber : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.horizontal_rule_rounded,
                      size: 16,
                      color: isWallMode && isH ? Colors.black87 : Colors.white60,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Wall ━',
                      style: TextStyle(
                        color: isWallMode && isH ? Colors.black87 : Colors.white60,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Vertical Wall Tab
          Expanded(
            child: InkWell(
              onTap: wallsLeft > 0
                  ? () => controller.selectWallMode(WallOrientation.vertical)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isWallMode && !isH ? Colors.amber : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.more_vert_rounded,
                      size: 16,
                      color: isWallMode && !isH ? Colors.black87 : Colors.white60,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Wall ┃',
                      style: TextStyle(
                        color: isWallMode && !isH ? Colors.black87 : Colors.white60,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallPlacementPad(BuildContext context, Wall previewWall) {
    final isLegal = controller.isPreviewWallLegal;
    final error = controller.previewWallError;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLegal ? Colors.amber.withOpacity(0.5) : const Color(0xFFEF4444),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wall status & coordinates
          Row(
            children: [
              Icon(
                isLegal ? Icons.check_circle_outline : Icons.error_outline,
                color: isLegal ? Colors.amber : const Color(0xFFEF4444),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isLegal
                      ? 'Groove (${previewWall.row + 1}, ${String.fromCharCode(65 + previewWall.col)}) - ${previewWall.isHorizontal ? "Horizontal" : "Vertical"}'
                      : error ?? 'Illegal placement',
                  style: TextStyle(
                    color: isLegal ? Colors.amber : const Color(0xFFFCA5A5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Rotate button
              IconButton(
                onPressed: controller.rotatePreviewWall,
                icon: const Icon(Icons.rotate_right_rounded, size: 20),
                color: Colors.amber,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Rotate 90°',
              ),
              const SizedBox(width: 8),
              // Cancel button
              IconButton(
                onPressed: controller.clearPreviewWall,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: Colors.white54,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Cancel',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nudge D-Pad and Confirm Button in clean row
          Row(
            children: [
              // Directional Nudge Buttons
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildNudgeButton(Icons.arrow_left_rounded, () => controller.nudgePreviewWall(0, -1)),
                    _buildNudgeButton(Icons.arrow_upward_rounded, () => controller.nudgePreviewWall(-1, 0)),
                    _buildNudgeButton(Icons.arrow_downward_rounded, () => controller.nudgePreviewWall(1, 0)),
                    _buildNudgeButton(Icons.arrow_right_rounded, () => controller.nudgePreviewWall(0, 1)),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Confirm Placement Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLegal && controller.isHumanTurn
                      ? () => controller.confirmPreviewWall()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF334155),
                    disabledForegroundColor: Colors.white30,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text(
                    'Place Wall',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNudgeButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildMessageBar(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context, AiAdvice advice) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF818CF8), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI Coach: ${advice.title}',
                  style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 15, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: controller.clearHint,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            advice.reasoning,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Shortest Path: ${advice.myShortestPath} steps',
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'AI Path: ${advice.opponentShortestPath} steps',
                  style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls(BuildContext context) {
    return Row(
      children: [
        // AI Hint Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.isAiThinking ? null : controller.requestHint,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.lightbulb_outline, size: 16),
            label: const Text(
              'AI Hint',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Path Overlay Toggle
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.togglePathOverlay,
            style: OutlinedButton.styleFrom(
              foregroundColor: controller.showPathOverlay
                  ? const Color(0xFF38BDF8)
                  : Colors.white70,
              side: BorderSide(
                color: controller.showPathOverlay
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF475569),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.route_outlined, size: 16),
            label: Text(
              controller.showPathOverlay ? 'Hide Path' : 'Show Path',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Undo Button
        IconButton(
          onPressed: controller.canUndo ? controller.undo : null,
          icon: const Icon(Icons.undo_rounded, size: 18),
          color: Colors.white,
          tooltip: 'Undo',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 6),

        // Reset Button
        IconButton(
          onPressed: () => controller.startNewGame(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          color: Colors.white,
          tooltip: 'Reset',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverBanner(BuildContext context) {
    final state = controller.state;
    final isHumanWinner = state.winner == Player.red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHumanWinner ? const Color(0xFF065F46) : const Color(0xFF7F1D1D),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isHumanWinner ? const Color(0xFF10B981) : Colors.red).withOpacity(0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isHumanWinner ? '🏆 VICTORY! YOU WIN!' : '🤖 AI CLAIMS THE MATCH!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isHumanWinner
                ? 'Outsmarted the Local AI and reached the goal line!'
                : 'The Local AI found the winning detour route. Try a rematch!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => controller.startNewGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.replay_rounded, size: 16),
            label: const Text(
              'Play Rematch',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
