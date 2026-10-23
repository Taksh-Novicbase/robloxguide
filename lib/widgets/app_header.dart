import 'package:flutter/material.dart';

import '../services/default_app_service.dart';
import '../theme/app_theme.dart';

/// Shared header/toolbar used across screens. Mirrors the original `lyToolbar`
/// (back arrow + centered title).
class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ??
                () {
                  DefaultAppService.openCustomTab();
                  Navigator.of(context).maybePop();
                },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
