import 'package:flutter/material.dart';

import '../controllers/board_controller.dart';
import 'widgets/game_modes_tab.dart';
import 'widgets/how_to_play_tab.dart';
import 'widgets/play_ai_tab.dart';
import 'widgets/strategies_tab.dart';

class WallRushHubScreen extends StatefulWidget {
  const WallRushHubScreen({super.key});

  @override
  State<WallRushHubScreen> createState() => _WallRushHubScreenState();
}

class _WallRushHubScreenState extends State<WallRushHubScreen> {
  int _currentIndex = 0;
  late final BoardController _boardController;

  @override
  void initState() {
    super.initState();
    _boardController = BoardController();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Midnight Dark Slate
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.grid_4x4_rounded,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Wall Rush',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Game Guide & Local AI Arena',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PlayAiTab(controller: _boardController),
          const HowToPlayTab(),
          const GameModesTab(),
          const StrategiesTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(
            top: BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              activeIcon: Icon(Icons.smart_toy_rounded, color: Color(0xFF38BDF8)),
              label: 'Play AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              activeIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8)),
              label: 'Rules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_rounded),
              activeIcon: Icon(Icons.style_rounded, color: Color(0xFF38BDF8)),
              label: 'Modes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_rounded),
              activeIcon: Icon(Icons.psychology_rounded, color: Color(0xFF38BDF8)),
              label: 'Tactics',
            ),
          ],
        ),
      ),
    );
  }
}
