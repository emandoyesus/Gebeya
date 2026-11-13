import 'package:flutter/material.dart';

enum ItemCategory {
  all,
  grainsFlour,
  vegetablesProduce,
  pulsesLegumes,
  meatDairy,
  oilSugarPantry,
  spices,
}

extension ItemCategoryExtension on ItemCategory {
  String get id {
    switch (this) {
      case ItemCategory.all:
        return 'all';
      case ItemCategory.grainsFlour:
        return 'grains_flour';
      case ItemCategory.vegetablesProduce:
        return 'vegetables_produce';
      case ItemCategory.pulsesLegumes:
        return 'pulses_legumes';
      case ItemCategory.meatDairy:
        return 'meat_dairy';
      case ItemCategory.oilSugarPantry:
        return 'oil_sugar_pantry';
      case ItemCategory.spices:
        return 'spices';
    }
  }

  String nameEn(BuildContext context) {
    switch (this) {
      case ItemCategory.all:
        return 'All Items';
      case ItemCategory.grainsFlour:
        return 'Grains & Flour';
      case ItemCategory.vegetablesProduce:
        return 'Produce';
      case ItemCategory.pulsesLegumes:
        return 'Pulses';
      case ItemCategory.meatDairy:
        return 'Meat & Dairy';
      case ItemCategory.oilSugarPantry:
        return 'Oil & Pantry';
      case ItemCategory.spices:
        return 'Spices';
    }
  }

  String nameAm(BuildContext context) {
    switch (this) {
      case ItemCategory.all:
        return 'ሁሉም';
      case ItemCategory.grainsFlour:
        return 'እህልና ዱቄት';
      case ItemCategory.vegetablesProduce:
        return 'አትክልትና ፍራፍሬ';
      case ItemCategory.pulsesLegumes:
        return 'የጥራጥሬ ሰብሎች';
      case ItemCategory.meatDairy:
        return 'ሥጋና ወተት';
      case ItemCategory.oilSugarPantry:
        return 'ዘይትና ስኳር';
      case ItemCategory.spices:
        return 'ቅመማ ቅመም';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.all:
        return Icons.grid_view_rounded;
      case ItemCategory.grainsFlour:
        return Icons.grain_rounded;
      case ItemCategory.vegetablesProduce:
        return Icons.eco_rounded;
      case ItemCategory.pulsesLegumes:
        return Icons.grass_rounded;
      case ItemCategory.meatDairy:
        return Icons.restaurant_rounded;
      case ItemCategory.oilSugarPantry:
        return Icons.opacity_rounded;
      case ItemCategory.spices:
        return Icons.whatshot_rounded;
    }
  }

  static ItemCategory fromString(String str) {
    switch (str.toLowerCase()) {
      case 'grains_flour':
        return ItemCategory.grainsFlour;
      case 'vegetables_produce':
        return ItemCategory.vegetablesProduce;
      case 'pulses_legumes':
        return ItemCategory.pulsesLegumes;
      case 'meat_dairy':
        return ItemCategory.meatDairy;
      case 'oil_sugar_pantry':
        return ItemCategory.oilSugarPantry;
      case 'spices':
        return ItemCategory.spices;
      default:
        return ItemCategory.all;
    }
  }
}
