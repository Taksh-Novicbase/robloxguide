import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/default_app_service.dart';
import '../../theme/app_theme.dart';
import '../onboarding/question_screen.dart';
import '../home_screen.dart';
import '../quiz_screen.dart';
import '../rbx_calculator_screen.dart';
import '../scratch_screen.dart';
import '../spin_screen.dart';
import 'widgets/app_drawer_sheet.dart';
import 'widgets/google_search_bar_widget.dart';
import 'widgets/launcher_clock_widget.dart';
import 'widgets/launcher_dock_widget.dart';

/// The Android Launcher Home Screen matching the device screenshots:
/// - Transparent background so user device's default system wallpaper shows through
/// - Page 0 (Swiping left): In-app Roblox Skins Tool Hub with 3 tabs and ads flow
/// - Page 1: Main Clock Screen with left-aligned clock & date (Screenshot 1)
/// - Page 2: Desktop Apps Grid 1 (Calendar, Browser, Contacts, Games) (Screenshot 2)
/// - Page 3: Desktop Apps Grid 2 (YouTube, Play Store, Gmail, Maps, Games) (Screenshot 3)
/// - Bottom Pinned Section on Pages 1-3: 4 Dots Indicator, 3-Squircle Dock (Phone, Contacts, Messages), Google Search Bar
/// - Swiping UP: Full-screen App Drawer with Sticky Medium Native Ad & Real System Icons (Screenshot 4)
class LauncherHomeScreen extends StatefulWidget {
  final int initialPage;

  const LauncherHomeScreen({super.key, this.initialPage = 1});

  @override
  State<LauncherHomeScreen> createState() => _LauncherHomeScreenState();
}

class _LauncherHomeScreenState extends State<LauncherHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PageController _pageController;
  late final AnimationController _drawerAnimationController;
  late final Animation<Offset> _drawerSlideAnimation;

  bool _isDrawerOpen = false;
  int _currentPage = 1;
  List<Map<String, dynamic>> _installedApps = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);

    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _drawerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _drawerAnimationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _loadInstalledApps();
    DefaultAppService.setLauncherActive(true);
    _checkDefaultLauncherState();
  }

  Future<void> _loadInstalledApps() async {
    try {
      final list = await DefaultAppService.getInstalledApps();
      if (mounted) {
        setState(() => _installedApps = list);
      }
      AppDrawerSheet.preload();
    } catch (_) {}
  }

  Uint8List? _getAppIcon(String packageName) {
    try {
      final found = _installedApps.firstWhere(
        (a) =>
            (a['packageName'] ?? '').toString().toLowerCase() ==
            packageName.toLowerCase(),
      );
      return found['iconBytes'] as Uint8List?;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DefaultAppService.setLauncherActive(false);
    _pageController.dispose();
    _drawerAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDefaultLauncherState();
    }
  }

  Future<void> _checkDefaultLauncherState() async {
    if (!appState.onboardingDone) {
      debugPrint('[RBX_FLOW] LauncherHomeScreen: onboarding is not done! Redirecting to OnboardingFlow.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingFlow()),
          );
        }
      });
      return;
    }

    final isDefault = await DefaultAppService.isDefaultLauncher();
    debugPrint('[RBX_FLOW] LauncherHomeScreen _checkDefaultLauncherState: isDefault = $isDefault');
    if (!isDefault && mounted) {
      debugPrint('[RBX_FLOW] LauncherHomeScreen: App is NOT default launcher! Redirecting to HomeScreen.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  void _openDrawer() {
    DefaultAppService.openCustomTab();
    setState(() => _isDrawerOpen = true);
    _drawerAnimationController.forward();
  }

  void _closeDrawer() {
    _drawerAnimationController.reverse().then((_) {
      if (mounted) setState(() => _isDrawerOpen = false);
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        DefaultAppService.openCustomTab();
        if (_isDrawerOpen) {
          _closeDrawer();
          return;
        }
        if (_currentPage != 1) {
          _goToPage(1);
          return;
        }
      },
      child: Scaffold(
        // Transparent background so the user's default device wallpaper displays through!
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Horizontal PageView:
            // Page 0: Roblox Skins Tool in-app hub with 3 tabs and ads flow
            // Page 1: Main Clock Screen (Screenshot 1)
            // Page 2: Desktop Apps Grid 1 (Screenshot 2)
            // Page 3: Desktop Apps Grid 2 (Screenshot 3)
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                DefaultAppService.openCustomTab();
              },
              children: [
                // Page 0: In-App Roblox Skins Tool Hub (Swipe left from Home)
                HomeScreen(onReturnToLauncher: () => _goToPage(1)),

                // Page 1: Main Clock Screen (Screenshot 1)
                _buildClockPage(),

                // Page 2: Desktop Apps Page 1 (Screenshot 2)
                _buildDesktopPage1(),

                // Page 3: Desktop Apps Page 2 (Screenshot 3)
                _buildDesktopPage2(),
              ],
            ),

            // Pinned Bottom Section on Launcher Desktop Pages (Pages 1, 2, 3)
            if (_currentPage >= 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 4 Dots Page Indicator
                      _buildPageIndicator(),

                      const SizedBox(height: 6),

                      // 3-Squircle Bottom Dock (Phone, Contacts, Messages)
                      const LauncherDockWidget(),

                      const SizedBox(height: 4),

                      // Bottom Google Search Capsule Bar
                      const GoogleSearchBarWidget(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

            // Slide-up App Drawer with Sticky Native Ad and Real System Icons
            if (_isDrawerOpen)
              Positioned.fill(
                child: SlideTransition(
                  position: _drawerSlideAnimation,
                  child: AppDrawerSheet(
                    onClose: _closeDrawer,
                    onOpenApp: () {
                      _closeDrawer();
                      _goToPage(0);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Page 1: Top-Left Clock and Open Wallpaper area (Screenshot 1)
  Widget _buildClockPage() {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: (details) {
          // Swipe up to open App Drawer
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -200) {
            _openDrawer();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 8),
            LauncherClockWidget(),
            Spacer(),
          ],
        ),
      ),
    );
  }

  /// Page 2: Desktop Apps Page 1 (Screenshot 2)
  /// Row 1: Calendar ("31"), Browser (Chrome), Contacts
  /// Row 2: Juice Bar, Block Puzzle, Candy Match, Speed Racer
  Widget _buildDesktopPage1() {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -200) {
            _openDrawer();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'Calendar',
                    packageName: 'com.google.android.calendar',
                    customBadge: '31',
                    badgeColor: const Color(0xFF4285F4),
                    onTap: () => DefaultAppService.launchPackage(
                      'com.google.android.calendar',
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Browser',
                    packageName: 'com.android.chrome',
                    isChrome: true,
                    onTap: () => DefaultAppService.launchSystemApp('browser'),
                  ),
                  _buildDesktopAppTile(
                    title: 'Contacts',
                    packageName: 'com.google.android.contacts',
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    onTap: () => DefaultAppService.launchSystemApp('contacts'),
                  ),
                  // Empty 4th slot to balance Row 1 matching screenshot 2
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 20),
              // Row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'Juice Bar',
                    packageName: 'com.app.juicebar',
                    gameGradient: const [Color(0xFFFF8A65), Color(0xFFFF7043)],
                    gameEmoji: '🍹',
                    onTap: () => _goToPage(0),
                  ),
                  _buildDesktopAppTile(
                    title: 'Block Puzzle',
                    packageName: 'com.app.blockpuzzle',
                    gameGradient: const [Color(0xFF8D6E63), Color(0xFF5D4037)],
                    gameEmoji: '🧩',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScratchScreen()),
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Candy Match',
                    packageName: 'com.app.candymatch',
                    gameGradient: const [Color(0xFFE91E63), Color(0xFFC2185B)],
                    gameEmoji: '🍬',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SpinScreen()),
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Speed Racer',
                    packageName: 'com.app.speedracer',
                    gameGradient: const [Color(0xFF37474F), Color(0xFF212121)],
                    gameEmoji: '🏎️',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RbxCalculatorScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Page 3: Desktop Apps Page 2 (Screenshot 3)
  /// Row 1: YouTube, Play Store, Gmail, Maps
  /// Row 2: Photos, Google
  /// Row 3: Subway Runner, Fruit Slice, Action Hero, Temple Dash
  /// Row 4: Coin Jump
  Widget _buildDesktopPage2() {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -200) {
            _openDrawer();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'YouTube',
                    packageName: 'com.google.android.youtube',
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.red,
                    isWhiteBox: true,
                    onTap: () => DefaultAppService.launchPackage(
                      'com.google.android.youtube',
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Play Store',
                    packageName: 'com.android.vending',
                    icon: Icons.shopping_bag_rounded,
                    iconColor: const Color(0xFF00C9FF),
                    isWhiteBox: true,
                    onTap: () =>
                        DefaultAppService.launchPackage('com.android.vending'),
                  ),
                  _buildDesktopAppTile(
                    title: 'Gmail',
                    packageName: 'com.google.android.gm',
                    icon: Icons.mail_rounded,
                    iconColor: const Color(0xFFEA4335),
                    isWhiteBox: true,
                    onTap: () => DefaultAppService.launchPackage(
                      'com.google.android.gm',
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Maps',
                    packageName: 'com.google.android.apps.maps',
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF34A853),
                    isWhiteBox: true,
                    onTap: () => DefaultAppService.launchPackage(
                      'com.google.android.apps.maps',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'Photos',
                    packageName: 'com.google.android.apps.photos',
                    icon: Icons.photo_library_rounded,
                    iconColor: const Color(0xFFFBBC05),
                    isWhiteBox: true,
                    onTap: () => DefaultAppService.launchPackage(
                      'com.google.android.apps.photos',
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Google',
                    packageName: 'com.google.android.googlequicksearchbox',
                    icon: Icons.search_rounded,
                    iconColor: const Color(0xFF4285F4),
                    isWhiteBox: true,
                    onTap: () => DefaultAppService.launchSystemApp('search'),
                  ),
                  const SizedBox(width: 64),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 20),
              // Row 3: Games
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'Subway Runner',
                    gameGradient: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                    gameEmoji: '🏃',
                    onTap: () => _goToPage(0),
                  ),
                  _buildDesktopAppTile(
                    title: 'Fruit Slice',
                    gameGradient: const [Color(0xFF43A047), Color(0xFF2E7D32)],
                    gameEmoji: '🍉',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Action Hero',
                    gameGradient: const [Color(0xFFFFB300), Color(0xFFFF8F00)],
                    gameEmoji: '🦸',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SpinScreen()),
                    ),
                  ),
                  _buildDesktopAppTile(
                    title: 'Temple Dash',
                    gameGradient: const [Color(0xFFD4E157), Color(0xFFAFB42B)],
                    gameEmoji: '🗿',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScratchScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Row 4: Coin Jump
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDesktopAppTile(
                    title: 'Coin Jump',
                    gameGradient: const [Color(0xFF26C6DA), Color(0xFF00ACC1)],
                    gameEmoji: '🍄',
                    onTap: () => _goToPage(0),
                  ),
                  const SizedBox(width: 64),
                  const SizedBox(width: 64),
                  const SizedBox(width: 64),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// 4-Dots horizontal Page Indicator right above the dock
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white.withAlpha(90),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(70),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  /// Desktop App Tile with support for Real System App Icons
  Widget _buildDesktopAppTile({
    required String title,
    String? packageName,
    String? customBadge,
    Color? badgeColor,
    bool isChrome = false,
    bool isWhiteBox = false,
    IconData? icon,
    Color? iconColor,
    List<Color>? gameGradient,
    String? gameEmoji,
    required VoidCallback onTap,
  }) {
    final realIconBytes = packageName != null ? _getAppIcon(packageName) : null;

    Widget iconWidget;
    if (realIconBytes != null) {
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          realIconBytes,
          width: 58,
          height: 58,
          fit: BoxFit.contain,
        ),
      );
    } else if (customBadge != null) {
      // Calendar with "31" badge (matching Screenshot 2)
      iconWidget = Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: badgeColor ?? const Color(0xFF4285F4),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            customBadge,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (isChrome) {
      // Chrome Logo
      iconWidget = Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.travel_explore_rounded,
            color: Color(0xFF4285F4),
            size: 34,
          ),
        ),
      );
    } else if (isWhiteBox) {
      iconWidget = Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon ?? Icons.android_rounded,
            color: iconColor ?? AppTheme.accent,
            size: 32,
          ),
        ),
      );
    } else if (gameEmoji != null) {
      iconWidget = Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                gameGradient ??
                [const Color(0xFF673AB7), const Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(gameEmoji, style: const TextStyle(fontSize: 28)),
        ),
      );
    } else {
      iconWidget = Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon ?? Icons.apps_rounded,
            color: iconColor ?? const Color(0xFF1E88E5),
            size: 32,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        DefaultAppService.openCustomTab();
        onTap();
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 5),
            Text(
              title,
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
          ],
        ),
      ),
    );
  }
}
