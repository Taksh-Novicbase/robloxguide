import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/item.dart';
import '../utils/app_assets.dart';

/// Loads the item catalog (extracted from the original APK) and exposes
/// the hardcoded app content (memes, spin values, conversion presets).
class AppRepository {
  AppRepository._();

  static List<ItemCategory>? _categories;

  static Future<List<ItemCategory>> loadCategories() async {
    if (_categories != null) return _categories!;
    final raw = await rootBundle.loadString(AppAssets.data('app_data.json'));
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['categories'] as List<dynamic>? ?? [])
        .map((e) => ItemCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    _categories = list;
    return list;
  }

  /// Memes (title, body) — extracted verbatim from `MemeActivity`.
  static const List<Meme> memes = [
    Meme(
      title: 'Robux Budgeting',
      body:
          "Me: I'll save my Robux for something special.\nAlso me: buys a hat for 5 Robux 😂",
    ),
    Meme(
      title: 'Pro Gamer Life',
      body: 'Played whole night grinding… still broke in Robux 😭',
    ),
    Meme(
      title: 'Daily Login Reward',
      body: 'Login everyday for rewards… forget why I opened game 🤣',
    ),
    Meme(
      title: 'Spin Wheel Luck',
      body: 'Expectation: 100 Robux\nReality: Better luck next time 😐',
    ),
    Meme(
      title: 'Limited Item Panic',
      body: 'See limited item… brain stops working… Robux gone instantly 😵',
    ),
    Meme(
      title: 'New Avatar Mood',
      body: 'Spent all Robux on avatar… now surviving on free items 😭',
    ),
    Meme(
      title: 'Game Pass Trap',
      body: 'Game: Buy VIP for small boost 😏\nMe: Take my Robux 💸',
    ),
    Meme(
      title: 'Free Robux Video',
      body: "Watching ads for free Robux like it's a full time job 😂",
    ),
    Meme(
      title: 'Friend Flex',
      body: 'Friend: I got 1000 Robux 😎\nMe: I got emotional damage 🥲',
    ),
    Meme(
      title: 'Avatar Update',
      body: 'Change avatar every 10 minutes… still not satisfied 🤯',
    ),
  ];

  /// Spin-wheel segment values (Robux), extracted from `SpinActivity`.
  static const List<String> spinValues = [
    '45', '32', '25', '20', '0', '8', '12', '5', '50', '92', '75', '100',
  ];

  /// Conversion presets, extracted from `CommanRBXCalculatorActivity`.
  static const List<ConversionType> conversions = [
    ConversionType(
      title: 'BC To RBX',
      icon: 'ic_bc_torbx',
      rate: 15,
      toRbx: true,
      inputLabel: 'BC',
      outputLabel: 'RBX',
    ),
    ConversionType(
      title: 'TBC To RBX',
      icon: 'ic_tbc_to_rbx',
      rate: 35,
      toRbx: true,
      inputLabel: 'TBC',
      outputLabel: 'RBX',
    ),
    ConversionType(
      title: 'OBC To RBX',
      icon: 'ic_onc_torbx',
      rate: 60,
      toRbx: true,
      inputLabel: 'OBC',
      outputLabel: 'RBX',
    ),
    ConversionType(
      title: 'Dollar To RBX',
      icon: 'ic_dollar_torbx',
      rate: 80,
      toRbx: true,
      inputLabel: 'USD',
      outputLabel: 'RBX',
    ),
    ConversionType(
      title: 'RBX To Dollar',
      icon: 'ic_rbx_to_dollar',
      rate: 80,
      toRbx: false,
      inputLabel: 'RBX',
      outputLabel: 'USD',
    ),
  ];
}
