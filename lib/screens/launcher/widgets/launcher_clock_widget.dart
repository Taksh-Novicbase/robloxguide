import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/default_app_service.dart';

/// Real-time Digital Clock and Date widget for the Launcher Home Screen,
/// mirroring `fragment_launcher_home.xml` (`TextClock @+id/clock` and `TextView @+id/date`).
class LauncherClockWidget extends StatefulWidget {
  const LauncherClockWidget({super.key});

  @override
  State<LauncherClockWidget> createState() => _LauncherClockWidgetState();
}

class _LauncherClockWidgetState extends State<LauncherClockWidget> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final now = DateTime.now();
        if (now.minute != _currentTime.minute ||
            now.hour != _currentTime.hour) {
          setState(() => _currentTime = now);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(_currentTime);
    final dateStr = _formatDate(_currentTime);

    return InkWell(
      onTap: () {
        DefaultAppService.openCustomTab();
        DefaultAppService.launchSystemApp('clock');
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white.withAlpha(20),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 60,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1.0,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 14,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateStr,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
