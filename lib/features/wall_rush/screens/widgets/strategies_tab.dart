import 'package:flutter/material.dart';

class StrategiesTab extends StatelessWidget {
  const StrategiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroHeader(),

          const SizedBox(height: 16),

          // Strategy 1: Wall Economy
          _buildTacticCard(
            title: '1. Wall Economy (Resource Conservation)',
            badge: 'FUNDAMENTAL',
            badgeColor: const Color(0xFF10B981),
            icon: Icons.account_balance_wallet_rounded,
            summary:
                'Never spend a wall early in the game for a meager 1-step detour. Each wall in your reserve is a future game-ending threat. The AI engine only drops a wall when the net detour gain is ≥ 2 steps or when an opponent is threatening to sprint past.',
            proTip:
                'Pro Tip: Keep at least 2 to 3 walls in reserve for the end-game race to counter your opponent\'s closing moves.',
          ),

          const SizedBox(height: 14),

          // Strategy 2: The Serpentine Corridor
          _buildTacticCard(
            title: '2. The Serpentine Maze (Snake Trap)',
            badge: 'LETHAL TACTIC',
            badgeColor: const Color(0xFFEF4444),
            icon: Icons.alt_route_rounded,
            summary:
                'By staggering alternating horizontal walls anchored near the outer board edges, you force the opponent into a long winding "S-curve". This can inflate their shortest path from 6 steps to 20+ steps without ever violating the Golden No-Trap rule!',
            proTip:
                'Pro Tip: Always make sure the exit of your serpentine maze redirects the opponent toward their own starting row!',
          ),

          const SizedBox(height: 14),

          // Strategy 3: Jump Baits & Tempo
          _buildTacticCard(
            title: '3. Jump Baits & Face-Off Tempo',
            badge: 'TEMPO GAIN',
            badgeColor: const Color(0xFFF59E0B),
            icon: Icons.double_arrow_rounded,
            summary:
                'In the opening turns, pawns inevitably meet near the board center. If you time your advance so that your opponent enters your adjacent tile first, you can jump over them, effectively taking two steps and gaining colossal tempo.',
            proTip:
                'Pro Tip: If your opponent threatens to jump over you, place a wall directly behind yourself to deny their straight jump!',
          ),

          const SizedBox(height: 14),

          // Strategy 4: Counter-Walling & Emergency Valves
          _buildTacticCard(
            title: '4. Counter-Walling & Escape Routes',
            badge: 'DEFENSE',
            badgeColor: const Color(0xFF8B5CF6),
            icon: Icons.shield_rounded,
            summary:
                'When your opponent begins boxing you in with walls, never blindly push forward. Check lateral columns for escape avenues. Often, dropping a wall that blocks the opponent\'s counter-path relieves pressure and equalizes path lengths.',
            proTip:
                'Pro Tip: Use the "Show Path" button in the Play AI tab to observe how a single wall shifts the optimal BFS line.',
          ),

          const SizedBox(height: 14),

          // Strategy 5: How the Local AI Thinks
          _buildAiExplanationCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF311042), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded, color: Color(0xFFC084FC), size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wall Rush Master Strategies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pro principles, corridor traps, jump mechanics, and engine insights.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required String summary,
    required String proTip,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              proTip,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'How the Local AI Engine Operates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Easy AI: Uses a fast forward-bias algorithm, randomly stepping towards the goal with a 15% chance to drop casual walls.\n\n'
            '• Medium AI (Greedy Tactician): Runs BFS path calculations across the 9x9 board. It evaluates all candidate wall grooves touching path lines, dropping a barrier whenever it increases the opponent\'s path length by ≥ 2 steps.\n\n'
            '• Hard AI (Minimax with Alpha-Beta): Looks 2 to 3 turns ahead in the game tree. It evaluates path step deltas, wall inventory weights, and opponent counter-moves, pruning billions of illegal states with extreme speed.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
