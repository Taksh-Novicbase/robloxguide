import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../services/default_app_service.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';
import 'default_launcher/set_default_launcher_screen.dart';

/// Mirrors `SettingActivity`: app settings (balance, onboarding reset, about).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionCard(
                    children: [
                      _SettingRow(
                        icon: Icons.monetization_on,
                        label: 'Robux Balance',
                        trailing: ListenableBuilder(
                          listenable: appState,
                          builder: (_, _) => Text(
                              '${appState.robux}',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        onTap: () => _editBalance(context),
                      ),
                      _SettingRow(
                        icon: Icons.home_outlined,
                        label: 'Default Home App',
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.accent,
                        ),
                        onTap: () async {
                          final isDefault =
                              await DefaultAppService.isDefaultLauncher();
                          if (!isDefault) {
                            await DefaultAppService.requestDefaultLauncher();
                          } else {
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SetDefaultLauncherScreen(
                                    isFromSettings: true,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      _SettingRow(
                        icon: Icons.refresh,
                        label: 'Reset Onboarding',
                        onTap: () {
                          appState.resetOnboarding();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Onboarding & default prompt will show on next launch',
                              ),
                            ),
                          );
                        },
                      ),
                      _SettingRow(
                        icon: Icons.info_outline,
                        label: 'About',
                        trailing: const Text(
                          'Roblox Skins Tool v1.2.0',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Medium Native Ad Placement with MediaView (mirrors activity_setting.xml native_container)
                  MediumNativeAdWidget(adUnitId: AdIds.toolsNativeId),

                ],
              ),
            ),
            // Bottom Banner Ad (mirrors activity_setting.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }


  void _editBalance(BuildContext context) {
    final controller = TextEditingController(text: '${appState.robux}');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Set Balance',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.setRobux(int.tryParse(controller.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
