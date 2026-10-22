import 'package:flutter/material.dart';

import '../../../services/default_app_service.dart';

/// Bottom Dock Widget featuring the 3 essential phone apps:
/// Phone, Contacts, Messages (matching the device screenshot dock).
class LauncherDockWidget extends StatelessWidget {
  const LauncherDockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 4, 28, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSquircleDockIcon(
            icon: Icons.phone_rounded,
            iconColor: const Color(0xFF1E88E5),
            onTap: () => DefaultAppService.launchSystemApp('phone'),
          ),
          _buildSquircleDockIcon(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF1E88E5),
            onTap: () => DefaultAppService.launchSystemApp('contacts'),
          ),
          _buildSquircleDockIcon(
            icon: Icons.chat_bubble_rounded,
            iconColor: const Color(0xFF1E88E5),
            onTap: () => DefaultAppService.launchSystemApp('messages'),
          ),
        ],
      ),
    );
  }

  Widget _buildSquircleDockIcon({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        DefaultAppService.openCustomTab();
        onTap();
      },
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: 36,
          ),
        ),
      ),
    );
  }
}
