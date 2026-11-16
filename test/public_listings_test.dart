import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gebeya/features/items/data/item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('imported offers have unique IDs, positive prices and public provenance', () async {
    final rows = jsonDecode(await rootBundle.loadString(
      'assets/data/public_listings.json',
    )) as List;
    expect(rows.length, 54);
    final ids = <String>{};
    var telegramCount = 0;
    for (final row in rows) {
      final item = ItemModel.fromJson(Map<String, dynamic>.from(row as Map));
      expect(ids.add(item.id), isTrue);
      expect(item.id, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      )));
      expect(item.listingPrice, greaterThan(0));
      expect(item.standardUnit, isIn(['piece', 'kg', 'liter', 'pair', 'set', 'bottle']));
      expect(item.listingNote, contains('2026-11-16'));
      final uri = Uri.parse(item.listingSource!);
      expect(uri.scheme, 'https');
      expect(uri.host, isIn(['t.me', 'www.davitechnology.com', 'jiji.com.et']));
      if (uri.host == 't.me') {
        telegramCount++;
        expect(uri.pathSegments.length, 2);
        expect(int.tryParse(uri.pathSegments.last), isNotNull);
      }
    }
    expect(telegramCount, 7);
  });

  test('bundled-only flag is explicit and absent for backend records', () {
    expect(ItemModel.fromJson({'catalog_only': true}).catalogOnly, isTrue);
    expect(ItemModel.fromJson({}).catalogOnly, isFalse);
  });
}
