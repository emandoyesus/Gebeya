import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/categories.dart';
import '../data/item_model.dart';
import '../data/items_repository.dart';
import '../data/market_model.dart';
import '../data/price_aggregate_model.dart';

// Repository Provider
final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository();
});

// Markets Provider
final marketsProvider = FutureProvider<List<MarketModel>>((ref) async {
  final repo = ref.watch(itemsRepositoryProvider);
  return repo.getMarkets();
});

// Selected Market Provider (Default: first market, e.g. Merkato)
final selectedMarketProvider = StateProvider<MarketModel?>((ref) {
  final marketsAsync = ref.watch(marketsProvider);
  return marketsAsync.valueOrNull?.first;
});

// Selected Category Filter
final selectedCategoryProvider = StateProvider<ItemCategory>((ref) {
  return ItemCategory.all;
});

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// All Items Provider
final itemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final repo = ref.watch(itemsRepositoryProvider);
  return repo.getItems();
});

// Price Aggregates for Currently Selected Market
final marketAggregatesProvider = FutureProvider<Map<String, PriceAggregateModel>>((ref) async {
  final market = ref.watch(selectedMarketProvider);
  if (market == null) {
    // If null, get default first market
    final markets = await ref.watch(itemsRepositoryProvider).getMarkets();
    if (markets.isEmpty) return {};
    return ref.watch(itemsRepositoryProvider).getAggregatesForMarket(markets.first.id);
  }
  return ref.watch(itemsRepositoryProvider).getAggregatesForMarket(market.id);
});

// Filtered Items based on Category and Search Query
final filteredItemsProvider = Provider<List<ItemModel>>((ref) {
  final itemsAsync = ref.watch(itemsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return itemsAsync.maybeWhen(
    data: (items) {
      return items.where((item) {
        final matchesCategory = category == ItemCategory.all || item.category == category;
        final matchesQuery = query.isEmpty ||
            item.nameEn.toLowerCase().contains(query) ||
            item.nameAm.contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    },
    orElse: () => [],
  );
});
