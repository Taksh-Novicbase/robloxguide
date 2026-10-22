import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_assets.dart';

/// A tappable grid tile with an icon and a label — used for both the
/// category grid and the feature dashboard.
class FeatureTile extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final VoidCallback? onTap;

  const FeatureTile({
    super.key,
    required this.label,
    this.iconAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: iconAsset == null
                    ? Icon(Icons.image, color: AppTheme.textSecondary, size: 34)
                    : Image.asset(
                        AppAssets.image(iconAsset!),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.image,
                          color: AppTheme.textSecondary,
                          size: 34,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
