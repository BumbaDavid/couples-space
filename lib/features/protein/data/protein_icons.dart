import 'package:flutter/material.dart';

/// Food icons available in the card editor's grid picker.
///
/// Keys are stored strings, so a card document never depends on Flutter's icon
/// codepoints. Mirrors `WorkoutIcons.forBodyPart`.
///
/// The design handoff names Material *Symbols* icons. Two of them —
/// `nutrition` and `grocery` — have no equivalent in Flutter's built-in
/// `Icons` class, so they are substituted below. We stay on built-in `Icons`
/// deliberately: the vault note says Material's built-in food icons suffice,
/// and adding `material_symbols_icons` would be a speculative dependency.
abstract class ProteinIcons {
  /// Grid order, as specified by the design handoff.
  static const List<String> names = [
    'egg',
    'egg_alt',
    'set_meal',
    'rice_bowl',
    'ramen_dining',
    'lunch_dining',
    'dinner_dining',
    'bakery_dining',
    'kebab_dining',
    'local_pizza',
    'local_drink',
    'local_cafe',
    'blender',
    'cookie',
    'icecream',
    'nutrition',
    'restaurant',
    'fastfood',
    'agriculture',
    'grocery',
  ];

  static const String fallback = 'restaurant';

  static IconData forName(String name) => switch (name) {
    'egg' => Icons.egg,
    'egg_alt' => Icons.egg_alt,
    'set_meal' => Icons.set_meal,
    'rice_bowl' => Icons.rice_bowl,
    'ramen_dining' => Icons.ramen_dining,
    'lunch_dining' => Icons.lunch_dining,
    'dinner_dining' => Icons.dinner_dining,
    'bakery_dining' => Icons.bakery_dining,
    'kebab_dining' => Icons.kebab_dining,
    'local_pizza' => Icons.local_pizza,
    'local_drink' => Icons.local_drink,
    'local_cafe' => Icons.local_cafe,
    'blender' => Icons.blender,
    'cookie' => Icons.cookie,
    'icecream' => Icons.icecream,
    // Design says Material Symbols `nutrition`; no Flutter equivalent.
    'nutrition' => Icons.restaurant_menu,
    'restaurant' => Icons.restaurant,
    'fastfood' => Icons.fastfood,
    'agriculture' => Icons.agriculture,
    // Design says Material Symbols `grocery`; no Flutter equivalent.
    'grocery' => Icons.local_grocery_store,
    _ => Icons.restaurant,
  };
}
