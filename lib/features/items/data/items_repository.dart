import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/mock_data.dart';
import 'item_model.dart';
import 'market_model.dart';
import 'price_aggregate_model.dart';

class ItemsRepository {
  final SupabaseClient? _supabase;

  ItemsRepository({SupabaseClient? supabase})
      : _supabase = SupabaseConfig.isConfigured ? (supabase ?? Supabase.instance.client) : null;

  Future<List<MarketModel>> getMarkets() async {
    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('markets')
            .select()
            .eq('is_active', true)
            .order('name_en');
        return (res as List).map((m) => MarketModel.fromJson(m)).toList();
      } catch (_) {
        // Fallback to local
      }
    }
    return MockData.markets;
  }

  Future<List<ItemModel>> getItems() async {
    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('items')
            .select()
            .eq('is_active', true)
            .order('name_en');
        return (res as List).map((i) => ItemModel.fromJson(i)).toList();
      } catch (_) {
        // Fallback to local
      }
    }
    return MockData.items;
  }

  Future<Map<String, PriceAggregateModel>> getAggregatesForMarket(String marketId) async {
    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('price_aggregates')
            .select()
            .eq('market_id', marketId);
        final map = <String, PriceAggregateModel>{};
        for (final row in (res as List)) {
          final agg = PriceAggregateModel.fromJson(row);
          map[agg.itemId] = agg;
        }
        if (map.isNotEmpty) return map;
      } catch (_) {
        // Fallback to local
      }
    }
    return MockData.generateInitialAggregates(marketId);
  }

  Future<List<Map<String, dynamic>>> getItemHistory(String itemId, String marketId, {int days = 30}) async {
    // Generate realistic historical daily price curve for charts
    final now = DateTime.now();
    final points = <Map<String, dynamic>>[];
    final basePrice = MockData.generateInitialAggregates(marketId)[itemId]?.medianPrice ?? 100.0;

    for (int i = days; i >= 0; i -= 3) {
      final date = now.subtract(Duration(days: i));
      // Trend: realistic slight fluctuation (inflation/seasonality)
      final variation = (i % 5 - 2) * 2.5;
      points.add({
        'date': date,
        'price': (basePrice + variation).clamp(10.0, 5000.0),
      });
    }
    return points;
  }
}
