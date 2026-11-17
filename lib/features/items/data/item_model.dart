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
  final String? imageUrl;
  final double? listingPrice;
  final String? listingSource;
  final String? listingNote;
  final String? listingLocation;
  // Bundled listing has not yet been imported into the configured backend.
  final bool catalogOnly;

  const ItemModel({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.category,
    required this.standardUnit,
    this.supportedLocalUnits = const [],
    this.iconName,
    this.imageUrl,
    this.listingPrice,
    this.listingSource,
    this.listingNote,
    this.listingLocation,
    this.catalogOnly = false,
  });

  ItemModel withCatalogOnly(bool value) => ItemModel(
    id: id, nameEn: nameEn, nameAm: nameAm, category: category,
    standardUnit: standardUnit, supportedLocalUnits: supportedLocalUnits,
    iconName: iconName, imageUrl: imageUrl, listingPrice: listingPrice,
    listingSource: listingSource, listingNote: listingNote, listingLocation: listingLocation, catalogOnly: value,
  );

  /// Prefer explicit location metadata. Legacy Jiji notes use
  /// "Jiji · location · description"; channel names are not locations.
  String? get sourceLocation {
    final location = listingLocation?.trim();
    if (location != null && location.isNotEmpty) return location;
    final parts = listingNote?.split(' · ');
    if (parts != null && parts.length >= 3 && parts.first.trim() == 'Jiji') {
      final place = parts[1].trim();
      if (place.isNotEmpty) return place;
    }
    return null;
  }

  String? get sourceLabel {
    final source = listingSource?.trim();
    if (source == null || source.isEmpty) return null;
    final uri = Uri.tryParse(source);
    if (uri == null || uri.host.isEmpty) return source;
    if (uri.host == 't.me' && uri.pathSegments.isNotEmpty) {
      return 'Telegram · @${uri.pathSegments.first}';
    }
    return uri.host;
  }

  /// Representative product photos; source credits are in IMAGE_CREDITS.md.
  /// Resolve by product name so backend records and bundled items stay consistent.
  String? get correctedImageUrl {
    final name = nameEn.toLowerCase();
    if (name.startsWith('teff (magna)')) {
      return 'https://www.jaivikanaturals.com/cdn/shop/products/Jaivika_Teff_Ivory_1072x.jpg?v=1606888038';
    }
    if (name.startsWith('teff (sergegna)')) {
      return 'https://www.jaivikanaturals.com/cdn/shop/products/Jaivika_Teff_Brown_800x.jpg?v=1606888071';
    }
    if (name == 'shiro flour') {
      return 'https://cdn.shopify.com/s/files/1/0098/9564/1139/products/1_3e8fd758-b633-4336-9786-9295bca4cf89.jpg?v=1565191566';
    }
    if (name == 'denim jeans') {
      return 'https://photos6.shoes.fr/photos/301/30100621/Le-Temps-des-Cerises-700-11-BASIC-30100621_1200_A.jpg';
    }
    if (name.contains('cotton t-shirt')) {
      return 'https://laurenblue.co.za/cdn/shop/files/WhiteTShirts.png?v=1731538307';
    }
    if (name.contains('galaxy a16') || name.contains('galaxy a-16')) {
      return 'https://telstra.com.au/content/dam/tcom/prepaid/mobile-devices/SamsungGalaxyA16-4G/samsung-galaxy-a16-4g-black-front-and-back-900x1200.jpg';
    }
    return null;
  }

  String? get displayImageUrl => correctedImageUrl ?? imageUrl;

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
        case 'pair':
          return 'ጥንድ';
        case 'set':
          return 'ስብስብ';
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
      imageUrl: json['image_url'],
      listingPrice: (json['listing_price'] as num?)?.toDouble(),
      listingSource: json['listing_source'],
      listingNote: json['listing_note'],
      listingLocation: json['listing_location'],
      catalogOnly: json['catalog_only'] == true,
    );
  }
}
