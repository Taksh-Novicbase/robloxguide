import '../utils/app_assets.dart';

/// A single clothing/skin item. Mirrors the original `sj.b`/`z4.a`
/// data classes (`img`, `name`, `shortDesc`, `desc`).
class OutfitItem {
  final String asset;
  final String name;
  final String shortDesc;
  final String desc;

  const OutfitItem({
    required this.asset,
    required this.name,
    required this.shortDesc,
    required this.desc,
  });

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      asset: json['asset'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortDesc: json['shortDesc'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
    );
  }

  String get imagePath => AppAssets.image(asset);
}

/// A category (e.g. "Shirts") containing its items.
class ItemCategory {
  final String title;
  final List<OutfitItem> items;

  const ItemCategory({required this.title, required this.items});

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => OutfitItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return ItemCategory(
      title: json['title'] as String? ?? '',
      items: items,
    );
  }

  String get previewPath => AppAssets.categoryPreview(title);
}

/// A meme entry (title + body).
class Meme {
  final String title;
  final String body;

  const Meme({required this.title, required this.body});
}

/// A currency conversion preset (e.g. "BC To RBX", rate 15).
class ConversionType {
  final String title;
  final String icon;
  final double rate;

  /// If true, result = input * rate (X -> Rbx).
  /// If false, result = input / rate (Rbx -> Dollar).
  final bool toRbx;
  final String inputLabel;
  final String outputLabel;

  const ConversionType({
    required this.title,
    required this.icon,
    required this.rate,
    required this.toRbx,
    required this.inputLabel,
    required this.outputLabel,
  });

  String get iconPath => AppAssets.image(icon);
}
