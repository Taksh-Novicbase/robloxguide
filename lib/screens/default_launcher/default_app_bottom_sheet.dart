import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../services/default_app_service.dart';
import '../../utils/app_assets.dart';

/// Faithfully mirrors the bottom sheet from `bottomsheet_permission.xml` as shown in the screenshot:
/// Displays the "Set As Default App" header, the `default_app.webp` preview row, and the
/// interactive "Roblox Skins Tool" selection row with the click finger indicator, directly
/// opening Android's native "Default home app" settings screen with zero popups or dialogs.
class DefaultAppBottomSheet extends StatefulWidget {
  const DefaultAppBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DefaultAppBottomSheet(),
    );
  }

  @override
  State<DefaultAppBottomSheet> createState() => _DefaultAppBottomSheetState();
}

class _DefaultAppBottomSheetState extends State<DefaultAppBottomSheet> {
  Future<void> _navigateToDefaultSettings() async {
    await DefaultAppService.requestDefaultLauncher();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Back arrow + "Set As Default App" + Close (X) icon
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1E202B),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Set As Default App',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF1E202B),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: Color(0xFF1E202B),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 1: default_app.webp banner (Home icon + placeholder + radio outline)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AppAssets.image('default_app'),
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 10),

            // Row 2: Selected Card with App Icon + "Roblox Skins Tool" + click.json pointer
            InkWell(
              onTap: _navigateToDefaultSettings,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // App Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/default_app.webp',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apps,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // App Title
                    const Expanded(
                      child: Text(
                        'Roblox Skins Tool',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1E202B),
                        ),
                      ),
                    ),

                    // Finger click tap animation (click.json)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Lottie.asset(
                        AppAssets.animation('click'),
                        repeat: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
