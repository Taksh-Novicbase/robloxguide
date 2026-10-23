import 'package:flutter/material.dart';

class HowToPlayTab extends StatelessWidget {
  const HowToPlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          _buildHeroBanner(),

          const SizedBox(height: 16),

          // Rule 1: Objective
          _buildRuleCard(
            badgeNumber: '01',
            badgeColor: const Color(0xFF3B82F6),
            title: 'Game Objective',
            icon: Icons.flag_rounded,
            content:
                'Wall Rush is an intense turn-based tactical board game played on a 9×9 grid.\n\n'
                '• Classic Mode: First pawn to reach ANY tile on the opposite baseline wins (Red races to Row 0; Blue races to Row 8).\n'
                '• Crown Rush: Both pawns start at equal distance and sprint to capture the single Golden Crown at the center (Row 4, Col 4).',
          ),

          const SizedBox(height: 14),

          // Rule 2: Turn Action
          _buildRuleCard(
            badgeNumber: '02',
            badgeColor: const Color(0xFF10B981),
            title: 'Two Turn Choices',
            icon: Icons.swap_horiz_rounded,
            content:
                'On every turn, a player must choose exactly ONE of two actions:\n\n'
                '1. Move Pawn: Advance your pawn 1 square orthogonally (Up, Down, Left, or Right).\n'
                '2. Place Wall: Deploy one of your limited barricades into the grooves to obstruct the opponent\'s route.',
          ),

          const SizedBox(height: 14),

          // Rule 3: Jumps (Straight & Diagonal)
          _buildRuleCard(
            badgeNumber: '03',
            badgeColor: const Color(0xFFF59E0B),
            title: 'Straight & Diagonal Jumps',
            icon: Icons.sports_gymnastics_rounded,
            content:
                'When you and your opponent are directly adjacent:\n\n'
                '• Straight Jump: If there is no wall behind the opponent, you can jump straight over them, gaining 2 steps in 1 turn!\n'
                '• Diagonal Jump: If a straight jump is blocked by a wall or the board edge, you may jump diagonally to either adjacent side tile.',
          ),

          const SizedBox(height: 14),

          // Rule 4: Wall Placement & Dimensions
          _buildRuleCard(
            badgeNumber: '04',
            badgeColor: const Color(0xFF8B5CF6),
            title: 'Wall Placement & Dimensions',
            icon: Icons.view_quilt_rounded,
            content:
                '• Each wall is 2 grid cells long, placed in grooves between tiles.\n'
                '• Walls can be placed Horizontally (━) or Vertically (┃).\n'
                '• Walls cannot overlap or intersect other placed walls.\n'
                '• Walls are a finite resource: 10 walls in Classic, 6 walls in Crown Rush.',
          ),

          const SizedBox(height: 14),

          // Rule 5: The Golden No-Trap Rule
          _buildRuleCard(
            badgeNumber: '05',
            badgeColor: const Color(0xFFEF4444),
            title: 'The Golden "No-Trap" Rule',
            icon: Icons.gavel_rounded,
            content:
                'You may create long, winding, serpentine mazes to force your opponent into huge detours.\n\n'
                'HOWEVER: You can NEVER completely seal or trap any player! A valid open path to the goal line must ALWAYS remain for both pawns at all times. Our Local AI and engine validate this using real-time BFS pathfinding.',
            isCritical: true,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded, color: Color(0xFF60A5FA), size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wall Rush Master Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Learn the fundamental rules, pawn jumping, and barrier tactics.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard({
    required String badgeNumber,
    required Color badgeColor,
    required String title,
    required IconData icon,
    required String content,
    bool isCritical = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFEF4444).withOpacity(0.6)
              : const Color(0xFF334155),
          width: isCritical ? 1.5 : 1,
        ),
        boxShadow: isCritical
            ? [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  badgeNumber,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
