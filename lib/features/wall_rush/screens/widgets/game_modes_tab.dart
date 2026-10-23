import 'package:flutter/material.dart';

class GameModesTab extends StatelessWidget {
  const GameModesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderBanner(),

          const SizedBox(height: 16),

          // Classic Mode
          _buildModeCard(
            title: 'Classic Mode',
            subtitle: 'Traditional 9×9 Quoridor Match',
            badge: '10 WALLS EACH',
            badgeColor: const Color(0xFF3B82F6),
            icon: Icons.shield_rounded,
            description:
                'The timeless tournament standard. Red starts at (8, 4) and races to Row 0. Blue starts at (0, 4) and races to Row 8. With 10 walls each, games revolve around deep maze construction, counter-wall traps, and late-game sprint calculations.',
            stats: const [
              ('Players', '2 Players'),
              ('Wall Count', '10 Walls'),
              ('Objective', 'Opposite Baseline'),
              ('Pace', 'Tactical & Deep'),
            ],
          ),

          const SizedBox(height: 14),

          // Crown Rush
          _buildModeCard(
            title: 'Crown Rush',
            subtitle: 'Sprint for the Golden Crown',
            badge: '6 WALLS EACH',
            badgeColor: const Color(0xFFF59E0B),
            icon: Icons.workspace_premium_rounded,
            description:
                'Fast-action mode designed for quick, intense showdowns. Both players start at equal distance and race to claim the single Golden Crown situated at Row 4, Col 4. With only 6 walls, each barrier must be placed with pinpoint precision.',
            stats: const [
              ('Players', '2 Players'),
              ('Wall Count', '6 Walls'),
              ('Objective', 'Capture Center Crown'),
              ('Pace', 'High-Speed Sprint'),
            ],
          ),

          const SizedBox(height: 14),

          // Race Mode
          _buildModeCard(
            title: 'Race Mode',
            subtitle: 'Side-by-Side Sprint',
            badge: '8 WALLS EACH',
            badgeColor: const Color(0xFF10B981),
            icon: Icons.speed_rounded,
            description:
                'Both Red (8, 3) and Blue (8, 5) begin on the same side at the bottom baseline, racing in parallel towards Row 0. Close proximity creates immediate shoulder-to-shoulder friction, jump opportunities, and cutthroat walling.',
            stats: const [
              ('Players', '2 Players'),
              ('Wall Count', '8 Walls'),
              ('Objective', 'Top Row 0'),
              ('Pace', 'Aggressive Racing'),
            ],
          ),

          const SizedBox(height: 14),

          // Rush Mode (4 Players)
          _buildModeCard(
            title: 'Rush Mode (4-Players)',
            subtitle: 'Free-for-All Center Convergence',
            badge: '5 WALLS EACH',
            badgeColor: const Color(0xFFEC4899),
            icon: Icons.groups_rounded,
            description:
                'Four players (Red, Green, Blue, Yellow) begin at the four outer edges and battle towards the exact center cell. 20 total walls on the board turn the battlefield into an ever-changing labyrinth where players can block multiple rivals simultaneously.',
            stats: const [
              ('Players', '4 Players'),
              ('Wall Count', '5 Walls'),
              ('Objective', 'Center (4, 4)'),
              ('Pace', 'Mayhem & Strategy'),
            ],
          ),

          const SizedBox(height: 14),

          // Play Formats
          _buildPlayFormatsCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.sports_esports_rounded, color: Color(0xFFA5B4FC), size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wall Rush Game Modes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Explore Classic, Crown Rush, Race, and 4-Player Rush formats.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required String description,
    required List<(String, String)> stats,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          // Stats Row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: stats.map((stat) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        stat.$1,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.$2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayFormatsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Ways to Play Wall Rush',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Local AI Bot: Play offline against three distinct engine tiers (Easy, Medium BFS, and Alpha-Beta Hard).\n'
            '• Pass & Play: Play with a friend on a single smartphone device with turn handoffs.\n'
            '• AI Advisor: Train your intuition by asking the local engine for moves, path lengths, and tactical evaluations.',
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
