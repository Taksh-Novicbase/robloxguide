/// Application configuration and feature flags.
class AppConfig {
  /// PRIMARY LOCAL FLAG:
  /// Set this flag in code to switch application flow:
  /// - true: Wall Rush Game Guide (How to Play, Rules, Modes, Strategy & Local AI Arena).
  /// - false: Roblox Skins & Launcher flow.
  static const bool showWallRushGuide = false;

  static Future<void> init() async {
    // Code-side configuration flag.
  }
}
