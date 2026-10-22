/// Central asset-path helper. The original app stored every image as a
/// drawable resource; here we keep the same file names under `assets/images`.
class AppAssets {
  AppAssets._();

  /// Assets that are PNG instead of WebP.
  static const Set<String> _pngAssets = {'main_emotes1'};

  static String image(String name) {
    final ext = _pngAssets.contains(name) ? 'png' : 'webp';
    return 'assets/images/$name.$ext';
  }

  static String animation(String name) => 'assets/animations/$name.json';

  static String data(String name) => 'assets/data/$name';

  static const String splashLoader = 'assets/animations/loader.json';
  static const String swipeBottom = 'assets/animations/swipe_bottom.json';
  static const String swipeRight = 'assets/animations/swipe_right.json';

  /// Category title -> its grid thumbnail (the `main_*` assets in the APK).
  static const Map<String, String> _categoryPreview = {
    'Shirts': 'main_shirt_img',
    'T-Shirts': 'main_tshirt_img',
    'Pants': 'main_pants_img',
    'Shorts': 'main_shorts_img',
    'Sweaters': 'main_sweater_img',
    'Jackets': 'main_jackets_img',
    'Dress and Skin': 'ic_drees',
    'Skirts': 'main_skirts_img',
    'Waist': 'main_waist_img',
    'Neck': 'main_neck_img',
    'Shoulder': 'main_shoulder_img',
    'Back': 'main_back_img',
    'Front': 'main_front_img',
    'Shoes': 'main_shoes_img',
    'Gear': 'main_gear_img',
    'Heads': 'main_head_img',
    'Hair': 'main_hair_img',
    'Face': 'main_face_img',
    'Classic Shirts': 'main_classic_shirt',
    'Classic T-Shirts': 'main_classic_tshirt',
    'Classic Pants': 'main_classic_pant',
    'Classic Heads': 'main_classic_head',
    'Classic Faces': 'main_classic_face',
    'Emotes': 'main_emotes',
    'Bundles': 'main_bundles',
  };

  static String categoryPreview(String title) =>
      image(_categoryPreview[title] ?? 'main_bg');
}
