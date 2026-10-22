import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../constants/ad_ids.dart';
import '../../../main.dart';
import '../../../services/default_app_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_assets.dart';
import '../../../widgets/native_ad_card_widget.dart';
import '../../converter_screen.dart';
import '../../home_screen.dart';
import '../../quiz_screen.dart';
import '../../rbx_calculator_screen.dart';
import '../../scratch_screen.dart';
import '../../settings_screen.dart';
import '../../spin_screen.dart';
import '../models/launcher_app_item.dart';

/// Full-screen App Drawer opened via swipe up.
/// Features:
/// 1. Top Search Bar with back navigation (no drag notch - looks like a clean native screen)
/// 2. Sticky Medium Native Ad (pinned right below the search bar)
/// 3. In-memory caching for zero loading delay
/// 4. Real system app icons queried from PackageManager
class AppDrawerSheet extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onOpenApp;

  const AppDrawerSheet({
    super.key,
    required this.onClose,
    this.onOpenApp,
  });

  /// In-memory cache of built LauncherAppItem list so opening drawer is instant.
  static List<LauncherAppItem>? cachedApps;
  static bool _isPreloading = false;

  /// Pre-warms the cache by building the app list in advance.
  static Future<void> preload() async {
    if ((cachedApps != null && cachedApps!.isNotEmpty) || _isPreloading) return;
    _isPreloading = true;
    try {
      final baseApps = _buildBaseAppsList();
      final installed = await DefaultAppService.getInstalledApps();
      final installedItems = <LauncherAppItem>[];

      for (final map in installed) {
        final pkg = map['packageName'] ?? '';
        final name = map['appName'] ?? '';
        if (pkg.isEmpty || name.isEmpty) continue;

        // Skip if already in base list
        final exists = baseApps.any(
          (b) =>
              (b.packageName != null && b.packageName == pkg) ||
              b.name.toLowerCase() == name.toLowerCase(),
        );
        if (exists) continue;

        final Uint8List? iconBytes = map['iconBytes'] as Uint8List?;
        installedItems.add(
          LauncherAppItem(
            id: pkg,
            name: name,
            packageName: pkg,
            iconBytes: iconBytes,
            icon: Icons.apps_rounded,
          ),
        );
      }

      baseApps.addAll(installedItems);
      cachedApps = baseApps;
    } catch (_) {
    } finally {
      _isPreloading = false;
    }
  }

  /// Builds the default core system & utility apps.
  static List<LauncherAppItem> _buildBaseAppsList() {
    return [
      LauncherAppItem(
        id: 'rbx_skins_tool',
        name: 'Roblox Skins',
        assetImage: AppAssets.image('app_icon'),
        isFeatured: true,
      ),
      LauncherAppItem(
        id: 'phone',
        name: 'Phone',
        icon: Icons.phone_rounded,
        gradient: const [Color(0xFF25D366), Color(0xFF0F9D58)],
        systemAction: 'phone',
      ),
      LauncherAppItem(
        id: 'contacts',
        name: 'Contacts',
        icon: Icons.perm_contact_calendar_rounded,
        gradient: const [Color(0xFF4285F4), Color(0xFF1976D2)],
        systemAction: 'contacts',
      ),
      LauncherAppItem(
        id: 'messages',
        name: 'Messages',
        icon: Icons.chat_bubble_rounded,
        gradient: const [Color(0xFF00C6FF), Color(0xFF0072FF)],
        systemAction: 'messages',
      ),
      LauncherAppItem(
        id: 'camera',
        name: 'Camera',
        icon: Icons.camera_alt_rounded,
        gradient: const [Color(0xFFFF5252), Color(0xFFD50000)],
        systemAction: 'camera',
      ),
      LauncherAppItem(
        id: 'chrome',
        name: 'Chrome',
        icon: Icons.language_rounded,
        gradient: const [Color(0xFF4285F4), Color(0xFF0F9D58)],
        systemAction: 'browser',
      ),
      LauncherAppItem(
        id: 'play_store',
        name: 'Play Store',
        icon: Icons.shop_rounded,
        gradient: const [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        packageName: 'com.android.vending',
      ),
      LauncherAppItem(
        id: 'roblox',
        name: 'Roblox',
        assetImage: AppAssets.image('ic_robolox'),
        packageName: 'com.roblox.client',
      ),
      LauncherAppItem(
        id: 'rbx_calc',
        name: 'RBX Calculator',
        assetImage: AppAssets.image('comman_cal_img'),
      ),
      LauncherAppItem(
        id: 'rbx_quiz',
        name: 'Roblox Quiz',
        assetImage: AppAssets.image('ic_quiz'),
      ),
      LauncherAppItem(
        id: 'spin_win',
        name: 'Spin & Win',
        assetImage: AppAssets.image('ic_spin'),
      ),
      LauncherAppItem(
        id: 'scratch_win',
        name: 'Scratch Card',
        assetImage: AppAssets.image('ic_scratch'),
      ),
      LauncherAppItem(
        id: 'converter',
        name: 'Converter',
        assetImage: AppAssets.image('ic_converter'),
      ),
      LauncherAppItem(
        id: 'settings',
        name: 'Settings',
        icon: Icons.settings_rounded,
        gradient: const [Color(0xFF78909C), Color(0xFF455A64)],
      ),
      LauncherAppItem(
        id: 'youtube',
        name: 'YouTube',
        icon: Icons.play_arrow_rounded,
        gradient: const [Color(0xFFFF0000), Color(0xFFB71C1C)],
        packageName: 'com.google.android.youtube',
      ),
      LauncherAppItem(
        id: 'whatsapp',
        name: 'WhatsApp',
        icon: Icons.chat_rounded,
        gradient: const [Color(0xFF25D366), Color(0xFF1EBE5D)],
        packageName: 'com.whatsapp',
      ),
      LauncherAppItem(
        id: 'clock',
        name: 'Clock',
        icon: Icons.access_time_filled_rounded,
        gradient: const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
        systemAction: 'clock',
      ),
      LauncherAppItem(
        id: 'gallery',
        name: 'Gallery',
        icon: Icons.photo_library_rounded,
        gradient: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
        systemAction: 'gallery',
      ),
      LauncherAppItem(
        id: 'calendar',
        name: 'Calendar',
        icon: Icons.calendar_month_rounded,
        gradient: const [Color(0xFF26A69A), Color(0xFF00897B)],
        systemAction: 'calendar',
      ),
      LauncherAppItem(
        id: 'files',
        name: 'Files',
        icon: Icons.folder_rounded,
        gradient: const [Color(0xFFFFA726), Color(0xFFFB8C00)],
        systemAction: 'files',
      ),
      LauncherAppItem(
        id: 'maps',
        name: 'Maps',
        icon: Icons.map_rounded,
        gradient: const [Color(0xFF26C6DA), Color(0xFF00ACC1)],
        systemAction: 'maps',
      ),
      LauncherAppItem(
        id: 'music',
        name: 'Music',
        icon: Icons.music_note_rounded,
        gradient: const [Color(0xFFEC407A), Color(0xFFD81B60)],
        systemAction: 'music',
      ),
    ];
  }

  @override
  State<AppDrawerSheet> createState() => _AppDrawerSheetState();
}

class _AppDrawerSheetState extends State<AppDrawerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<LauncherAppItem> _allApps = [];
  List<LauncherAppItem> _filteredApps = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _filterApps();
      });
    });

    if (AppDrawerSheet.cachedApps != null && AppDrawerSheet.cachedApps!.isNotEmpty) {
      _allApps = List.from(AppDrawerSheet.cachedApps!);
      _isLoadingApps = false;
      _filterApps();
      // Silently refresh in background to detect any changes
      _loadApps(silent: true);
    } else {
      _isLoadingApps = true;
      _loadApps(silent: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterApps() {
    if (_searchQuery.isEmpty) {
      _filteredApps = List.from(_allApps);
    } else {
      _filteredApps = _allApps.where((app) {
        return app.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadApps({bool silent = false}) async {
    try {
      await AppDrawerSheet.preload();
      if (AppDrawerSheet.cachedApps != null && mounted) {
        setState(() {
          _allApps = List.from(AppDrawerSheet.cachedApps!);
          _filterApps();
          _isLoadingApps = false;
        });
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() => _isLoadingApps = false);
      }
    }
  }

  void _handleAppTap(LauncherAppItem app) {
    DefaultAppService.openCustomTab();
    if (app.onCustomTap != null) {
      app.onCustomTap!();
      return;
    }

    switch (app.id) {
      case 'rbx_skins_tool':
        widget.onClose();
        if (widget.onOpenApp != null) {
          widget.onOpenApp!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        return;
      case 'rbx_calc':
        widget.onClose();
        if (!appState.onboardingDone && widget.onOpenApp != null) {
          widget.onOpenApp!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RbxCalculatorScreen()),
        );
        return;
      case 'rbx_quiz':
        widget.onClose();
        if (!appState.onboardingDone && widget.onOpenApp != null) {
          widget.onOpenApp!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );
        return;
      case 'spin_win':
        widget.onClose();
        if (!appState.onboardingDone && widget.onOpenApp != null) {
          widget.onOpenApp!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SpinScreen()),
        );
        return;
      case 'scratch_win':
        widget.onClose();
        if (!appState.onboardingDone && widget.onOpenApp != null) {
          widget.onOpenApp!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScratchScreen()),
        );
        return;
      case 'converter':
        widget.onClose();
        if (!appState.onboardingDone && widget.onOpenApp != null) {
          widget.onOpenApp!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ConverterScreen()),
        );
        return;
      case 'settings':
        widget.onClose();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        return;
    }

    if (app.systemAction != null) {
      DefaultAppService.launchSystemApp(app.systemAction!);
      return;
    }
    if (app.packageName != null) {
      DefaultAppService.launchPackage(app.packageName!);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        // Swiping down on empty areas closes drawer
        if (details.primaryVelocity != null && details.primaryVelocity! > 220) {
          DefaultAppService.openCustomTab();
          widget.onClose();
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // Full-screen translucent frosted overlay over user's system wallpaper (no notch, no modal border)
          color: const Color(0xD90D111A),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Search Bar matching screenshot 4 (clean full screen with back button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
                  child: Row(
                    children: [
                      // Back button to close drawer
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.onClose,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Pill Search Capsule
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(28),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withAlpha(45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  cursorColor: AppTheme.accent,
                                  decoration: const InputDecoration(
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 15,
                                      color: Colors.white60,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _searchController.clear(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Medium Native Ad (pinned right below the search bar)
                if (_searchQuery.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                    child: MediumNativeAdWidget(
                      margin: EdgeInsets.zero,
                      adUnitId: AdIds.launcherNativeId,
                    ),
                  ),

                // Scrollable content with Apps Grid
                Expanded(
                  child: _isLoadingApps
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                          ),
                        )
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // Apps count header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'ALL APPS (${_filteredApps.length})'
                                          : 'RESULTS (${_filteredApps.length})',
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: widget.onClose,
                                      child: const Text(
                                        'Back',
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Filtered Apps Grid
                            _filteredApps.isEmpty
                                ? const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Center(
                                        child: Text(
                                          'No apps found',
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            color: AppTheme.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.78,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final app = _filteredApps[index];
                                          return _buildDrawerAppTile(app);
                                        },
                                        childCount: _filteredApps.length,
                                      ),
                                    ),
                                  ),

                            const SliverToBoxAdapter(
                              child: SizedBox(height: 36),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerAppTile(LauncherAppItem app) {
    return GestureDetector(
      onTap: () => _handleAppTap(app),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Icon with real bitmap or asset
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (app.iconBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    app.iconBytes!,
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _buildFallbackIconContainer(app),
                  ),
                )
              else if (app.assetImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    app.assetImage!,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildFallbackIconContainer(app),
                  ),
                )
              else
                _buildFallbackIconContainer(app),
              if (app.isFeatured)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // App Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              app.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIconContainer(LauncherAppItem app) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: app.gradient != null
            ? LinearGradient(
                colors: app.gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: app.gradient == null ? AppTheme.surface : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: app.isFeatured ? AppTheme.accent : Colors.white.withAlpha(40),
          width: app.isFeatured ? 2 : 1,
        ),
      ),
      child: Center(
        child: Icon(
          app.icon ?? Icons.apps_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
