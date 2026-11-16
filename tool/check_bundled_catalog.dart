import '../lib/core/constants/bundled_catalog.dart';

// Standalone data check; does not require the Flutter test engine.
void main() {
  final ids = <String>{};
  final counts = <String, int>{};
  for (final row in bundledCatalog) {
    final id = row['id'] as String;
    if (!ids.add(id)) throw StateError('Duplicate ID: $id');
    if ((row['name_en'] as String).isEmpty ||
        (row['name_am'] as String).isEmpty) {
      throw StateError('Missing name: $id');
    }
    final price = row['listing_price'];
    if (price != null && (price is! num || price <= 0 ||
        !(row['listing_source'] as String).startsWith('https://'))) {
      throw StateError('Invalid sourced price: $id');
    }
    final category = row['category'] as String;
    counts.update(category, (value) => value + 1, ifAbsent: () => 1);
  }
  if (counts.length != 26 || bundledCatalog.length != 214) {
    throw StateError('Incomplete bundled catalog: $counts');
  }
  print('PASS: ${bundledCatalog.length} unique entries; all 26 shopping categories populated.');
}
