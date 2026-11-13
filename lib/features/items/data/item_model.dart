import 'package:flutter/material.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/unit_converter.dart';

class ItemModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final ItemCategory category;
  final String standardUnit; // 'kg', 'liter', 'piece'
  final List<LocalUnitInfo> supportedLocalUnits;
  final String? iconName;

  const ItemModel({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.category,
    required this.standardUnit,
    this.supportedLocalUnits = const [],
    this.iconName,
  });

  String localizedName(bool isAmharic) => isAmharic ? nameAm : nameEn;

  String localizedStandardUnit(bool isAmharic) {
    if (isAmharic) {
      switch (standardUnit) {
        case 'kg':
          return 'ኪ.ግ';
        case 'liter':
          return 'ሊትር';
        case 'piece':
          return 'ፍሬ';
        default:
          return standardUnit;
      }
    }
    return standardUnit;
  }

  IconData get icon {
    switch (iconName) {
      case 'grain':
        return Icons.grain_rounded;
      case 'bakery_dining':
        return Icons.bakery_dining_rounded;
      case 'soup_kitchen':
        return Icons.soup_kitchen_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'nutrition':
        return Icons.egg_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'local_florist':
        return Icons.local_florist_rounded;
      case 'grass':
        return Icons.grass_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'breakfast_dining':
        return Icons.breakfast_dining_rounded;
      case 'egg':
        return Icons.egg_outlined;
      case 'opacity':
        return Icons.opacity_rounded;
      case 'cookie':
        return Icons.cookie_rounded;
      case 'whatshot':
        return Icons.whatshot_rounded;
      default:
        return category.icon;
    }
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final localUnits = <LocalUnitInfo>[];
    if (json['supported_local_units'] != null) {
      for (final u in json['supported_local_units'] as List) {
        localUnits.add(LocalUnitInfo.fromJson(Map<String, dynamic>.from(u)));
      }
    }

    return ItemModel(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAm: json['name_am'] ?? '',
      category: ItemCategoryExtension.fromString(json['category'] ?? ''),
      standardUnit: json['standard_unit'] ?? 'kg',
      supportedLocalUnits: localUnits,
      iconName: json['icon_name'],
    );
  }
}
