import 'package:flutter_test/flutter_test.dart';

import 'package:rbx_skins_tool/models/item.dart';

void main() {
  test('OutfitItem parses from JSON', () {
    final item = OutfitItem.fromJson(const {
      'asset': 'shirt_img_1',
      'name': 'Test Shirt',
      'shortDesc': 'A shirt',
      'desc': 'A longer description',
    });
    expect(item.name, 'Test Shirt');
    expect(item.asset, 'shirt_img_1');
    expect(item.imagePath, 'assets/images/shirt_img_1.webp');
  });

  test('ConversionType toRbx flag', () {
    const c = ConversionType(
      title: 'BC To RBX',
      icon: 'ic_bc_torbx',
      rate: 15,
      toRbx: true,
      inputLabel: 'BC',
      outputLabel: 'RBX',
    );
    expect(c.rate, 15);
    expect(c.toRbx, isTrue);
  });
}

