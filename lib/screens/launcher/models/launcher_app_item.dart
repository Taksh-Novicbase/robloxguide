import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Represents an application item in the Launcher Home Screen and App Drawer.
class LauncherAppItem {
  final String id;
  final String name;
  final String? packageName;
  final String? systemAction;
  final IconData? icon;
  final List<Color>? gradient;
  final String? assetImage;
  final Uint8List? iconBytes;
  final VoidCallback? onCustomTap;
  final bool isFeatured;

  const LauncherAppItem({
    required this.id,
    required this.name,
    this.packageName,
    this.systemAction,
    this.icon,
    this.gradient,
    this.assetImage,
    this.iconBytes,
    this.onCustomTap,
    this.isFeatured = false,
  });
}
