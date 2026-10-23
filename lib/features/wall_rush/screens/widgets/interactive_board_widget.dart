import 'dart:math';
import 'package:flutter/material.dart';

import '../../controllers/board_controller.dart';
import '../../engine/engine.dart';

class InteractiveBoardWidget extends StatelessWidget {
  const InteractiveBoardWidget({
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
        final legalMoves = controller.legalMoves;
        final myPath = controller.showPathOverlay ? controller.myShortestPath : null;
        final previewWall = controller.previewWall;
        final isWallMode = controller.playMode == PlayMode.placeWall;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Ensure the board dynamically scales to fit width and avoid any overflow
            final availableWidth = constraints.maxWidth;
            final boardSize = min(availableWidth, 360.0);
            const gridSize = 9;
            const grooves = 8;

            // Coordinate margin for A-I / 1-9 labels
            const coordMargin = 18.0;
            final playableSize = boardSize - (coordMargin * 2);

            // Proportional layout for 9 cells and 8 grooves
            // playableSize = 9 * cellSize + 8 * grooveSize
            // cellSize : grooveSize ~= 4.5 : 1
            final grooveSize = playableSize / (gridSize * 4.5 + grooves);
            final cellSize = grooveSize * 4.5;

            return Center(
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Dark slate frame
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.08),
                      blurRadius: 24,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(coordMargin),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Column labels (A-I) on top and bottom border
                    for (int c = 0; c < gridSize; c++) ...[
                      Positioned(
                        left: c * (cellSize + grooveSize) + (cellSize / 2) - 6,
                        top: -15,
                        child: Text(
                          String.fromCharCode(65 + c),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        left: c * (cellSize + grooveSize) + (cellSize / 2) - 6,
                        bottom: -15,
                        child: Text(
                          String.fromCharCode(65 + c),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // Row labels (1-9) on left and right border
                    for (int r = 0; r < gridSize; r++) ...[
                      Positioned(
                        left: -14,
                        top: r * (cellSize + grooveSize) + (cellSize / 2) - 6,
                        child: Text(
                          '${9 - r}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // 9x9 Grid of playable cells
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(gridSize, (row) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(gridSize, (col) {
                            final pos = Position(row, col);
                            final isRedPawn = state.redPosition == pos;
                            final isBluePawn = state.bluePosition == pos;
                            final isLegal = legalMoves.contains(pos);
                            final isCrownGoal = state.variant == GameVariant.crown &&
                                state.isGoal(Player.red, pos);
                            final isRedGoalLine = state.variant == GameVariant.classic && row == 0;
                            final isBlueGoalLine = state.variant == GameVariant.classic && row == 8;
                            final isInShortestPath = myPath != null && myPath.contains(pos);

                            return GestureDetector(
                              onTap: isLegal ? () => controller.playPawnMove(pos) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: isCrownGoal
                                      ? const Color(0xFF451A03)
                                      : isInShortestPath
                                          ? const Color(0xFF1E3A8A)
                                          : (row + col) % 2 == 0
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFF172033),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isLegal
                                        ? const Color(0xFF10B981)
                                        : isCrownGoal
                                            ? const Color(0xFFF59E0B)
                                            : isRedGoalLine
                                                ? const Color(0xFFEF4444).withOpacity(0.3)
                                                : isBlueGoalLine
                                                    ? const Color(0xFF38BDF8).withOpacity(0.3)
                                                    : const Color(0xFF334155).withOpacity(0.4),
                                    width: isLegal ? 2 : (isCrownGoal ? 1.5 : 0.8),
                                  ),
                                  boxShadow: isLegal
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: isRedPawn
                                      ? _buildPawn(
                                          color: const Color(0xFFEF4444),
                                          glowColor: Colors.redAccent,
                                          isCurrent: state.currentPlayer == Player.red,
                                          icon: Icons.person_rounded,
                                          diameter: cellSize * 0.76,
                                        )
                                      : isBluePawn
                                          ? _buildPawn(
                                              color: const Color(0xFF06B6D4),
                                              glowColor: Colors.cyanAccent,
                                              isCurrent: state.currentPlayer == Player.blue,
                                              icon: Icons.smart_toy_rounded,
                                              diameter: cellSize * 0.76,
                                            )
                                          : isCrownGoal
                                              ? const Icon(
                                                  Icons.workspace_premium_rounded,
                                                  color: Color(0xFFF59E0B),
                                                  size: 18,
                                                )
                                              : isLegal
                                                  ? Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF10B981),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xFF10B981).withOpacity(0.9),
                                                            blurRadius: 6,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : null,
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),

                    // Render existing locked walls
                    ...state.walls.map((wall) {
                      return _buildWallWidget(
                        wall: wall,
                        cellSize: cellSize,
                        grooveSize: grooveSize,
                        isPreview: false,
                        isLegal: true,
                      );
                    }),

                    // Render Ghost / Preview Wall (with pulsating glow & validation color)
                    if (previewWall != null)
                      _buildWallWidget(
                        wall: previewWall,
                        cellSize: cellSize,
                        grooveSize: grooveSize,
                        isPreview: true,
                        isLegal: controller.isPreviewWallLegal,
                      ),

                    // Tappable Groove Nodes for easy wall targeting
                    ...List.generate(grooves * grooves, (index) {
                      final r = index ~/ grooves;
                      final c = index % grooves;
                      final wall = Wall(r, c, controller.wallOrientation);
                      final isCurrentPreview =
                          previewWall != null && previewWall.row == r && previewWall.col == c;

                      final left = (c + 1) * cellSize + c * grooveSize - (grooveSize * 1.5);
                      final top = (r + 1) * cellSize + r * grooveSize - (grooveSize * 1.5);
                      final touchSize = grooveSize * 4;

                      return Positioned(
                        left: left,
                        top: top,
                        width: touchSize,
                        height: touchSize,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (isCurrentPreview) {
                              // Tapping the active preview confirms placement!
                              controller.confirmPreviewWall();
                            } else {
                              // Tapping selects/moves preview to this groove
                              controller.setPreviewWall(wall);
                            }
                          },
                          child: Center(
                            child: Container(
                              width: grooveSize * (isWallMode ? 2.8 : 1.8),
                              height: grooveSize * (isWallMode ? 2.8 : 1.8),
                              decoration: BoxDecoration(
                                color: isCurrentPreview
                                    ? Colors.amber.withOpacity(0.6)
                                    : isWallMode
                                        ? const Color(0xFF38BDF8).withOpacity(0.3)
                                        : Colors.white.withOpacity(0.06),
                                shape: BoxShape.circle,
                                border: isWallMode
                                    ? Border.all(
                                        color: isCurrentPreview ? Colors.amber : const Color(0xFF38BDF8),
                                        width: 1,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPawn({
    required Color color,
    required Color glowColor,
    required bool isCurrent,
    required IconData icon,
    required double diameter,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isCurrent ? 1.08 : 0.95,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.9),
              color,
              HSLColor.fromColor(color).withLightness(0.3).toColor(),
            ],
            center: const Alignment(-0.25, -0.25),
          ),
          border: Border.all(
            color: isCurrent ? Colors.white : Colors.white70,
            width: isCurrent ? 2.2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(isCurrent ? 0.75 : 0.3),
              blurRadius: isCurrent ? 14 : 6,
              spreadRadius: isCurrent ? 2 : 0,
            ),
            const BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: diameter * 0.54,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWallWidget({
    required Wall wall,
    required double cellSize,
    required double grooveSize,
    required bool isPreview,
    required bool isLegal,
  }) {
    // Spans 2 cells + 1 groove
    final double length = 2 * cellSize + grooveSize;
    final double thickness = grooveSize * 1.6;

    final double left;
    final double top;
    final double width;
    final double height;

    if (wall.isHorizontal) {
      left = wall.col * (cellSize + grooveSize);
      top = (wall.row + 1) * cellSize + wall.row * grooveSize - (thickness - grooveSize) / 2;
      width = length;
      height = thickness;
    } else {
      left = (wall.col + 1) * cellSize + wall.col * grooveSize - (thickness - grooveSize) / 2;
      top = wall.row * (cellSize + grooveSize);
      width = thickness;
      height = length;
    }

    final wallColor = isPreview
        ? (isLegal ? const Color(0xFFF59E0B) : const Color(0xFFEF4444))
        : const Color(0xFFF59E0B);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isPreview ? wallColor.withOpacity(0.85) : wallColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPreview
                ? (isLegal ? Colors.white : const Color(0xFFFCA5A5))
                : const Color(0xFFFEF3C7),
            width: isPreview ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: wallColor.withOpacity(isPreview ? 0.8 : 0.5),
              blurRadius: isPreview ? 10 : 5,
              spreadRadius: isPreview ? 2 : 0,
            ),
            const BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isPreview
            ? Center(
                child: Icon(
                  isLegal ? Icons.check_circle_rounded : Icons.block_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            : null,
      ),
    );
  }
}
