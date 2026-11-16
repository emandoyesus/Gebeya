import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/core/constants/bundled_catalog.dart';
import 'package:gebeya/core/constants/mock_data.dart';
import 'package:gebeya/features/items/data/item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stable category IDs round trip, including existing database IDs', () {
    expect(ItemCategory.values.length, 27);
    expect(ItemCategory.values.map((value) => value.id).toSet().length, 27);
    for (final category in ItemCategory.values) {
      expect(ItemCategoryExtension.fromString(category.id), category);
      expect(category.labelEn, isNotEmpty);
      expect(category.labelAm, isNotEmpty);
    }
    expect(ItemCategoryExtension.fromString('vegetables_produce'),
        ItemCategory.vegetablesProduce);
  });

  test('expanded catalog covers every category without invented prices', () async {
    final rows = jsonDecode(await rootBundle.loadString(
      'assets/data/marketplace_catalog.json',
    )) as List;
    expect(rows.length, 160);
    final offers = jsonDecode(await rootBundle.loadString(
      'assets/data/public_listings.json',
    )) as List;
    expect(bundledCatalog, [...rows, ...offers]);
    final imported = rows.map((row) =>
        ItemModel.fromJson(Map<String, dynamic>.from(row as Map))).toList();
    expect(imported.map((item) => item.id).toSet().length, imported.length);
    for (final item in imported) {
      expect(item.category, isNot(ItemCategory.all));
      expect(item.nameEn, isNotEmpty);
      expect(item.nameAm, isNotEmpty);
      expect(item.listingPrice, isNull);
      expect(item.standardUnit, isIn(['piece', 'kg', 'liter', 'pair', 'set']));
    }
    final catalog = [...MockData.items, ...imported];
    for (final category in ItemCategory.values.skip(1)) {
      expect(catalog.any((item) => item.category == category), isTrue,
          reason: 'Missing items for ${category.id}');
    }
  });
}
