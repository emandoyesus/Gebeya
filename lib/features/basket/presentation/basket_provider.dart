import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../items/data/item_model.dart';
import '../../items/presentation/items_provider.dart';
import '../data/basket_item_model.dart';

class BasketNotifier extends StateNotifier<Map<String, BasketItem>> {
  static const _storageKey = 'gebeya_market_basket_v1';
  final Ref _ref;

  BasketNotifier(this._ref) : super({}) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final allItems = await _ref.read(itemsRepositoryProvider).getItems();
      final itemMap = {for (final it in allItems) it.id: it};

      final loaded = <String, BasketItem>{};
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          final id = entry['itemId'] as String?;
          final item = id != null ? itemMap[id] : null;
          if (item != null) {
            final quantity = (entry['quantity'] as num?)?.toInt() ?? 1;
            final unit = (entry['unit'] as String?) ?? item.standardUnit;
            final unitPrice = (entry['unitPrice'] as num?)?.toDouble() ??
                (item.listingPrice ?? 0.0);

            loaded[item.id] = BasketItem(
              item: item,
              quantity: quantity > 0 ? quantity : 1,
              unit: unit,
              unitPrice: unitPrice,
            );
          }
        }
      }

      if (mounted) {
        state = loaded;
      }
    } catch (_) {
      // Graceful fallback if parsing fails
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = state.values.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(serialized));
    } catch (_) {}
  }

  void addItem(
    ItemModel item, {
    int quantity = 1,
    String? unit,
    double? unitPrice,
  }) {
    final existing = state[item.id];
    final resolvedUnit = unit ?? existing?.unit ?? item.standardUnit;
    final resolvedPrice = unitPrice ??
        existing?.unitPrice ??
        item.listingPrice ??
        0.0;

    final newQuantity = (existing?.quantity ?? 0) + quantity;
    if (newQuantity <= 0) {
      removeItem(item.id);
      return;
    }

    state = {
      ...state,
      item.id: BasketItem(
        item: item,
        quantity: newQuantity,
        unit: resolvedUnit,
        unitPrice: resolvedPrice,
      ),
    };
    _saveToStorage();
  }

  void decrementItem(String itemId) {
    final existing = state[itemId];
    if (existing == null) return;

    if (existing.quantity <= 1) {
      removeItem(itemId);
    } else {
      state = {
        ...state,
        itemId: existing.copyWith(quantity: existing.quantity - 1),
      };
      _saveToStorage();
    }
  }

  void removeItem(String itemId) {
    if (!state.containsKey(itemId)) return;
    final updated = Map<String, BasketItem>.from(state)..remove(itemId);
    state = updated;
    _saveToStorage();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    final existing = state[itemId];
    if (existing == null) return;

    state = {
      ...state,
      itemId: existing.copyWith(quantity: quantity),
    };
    _saveToStorage();
  }

  void clear() {
    state = {};
    _saveToStorage();
  }
}

final basketProvider =
    StateNotifierProvider<BasketNotifier, Map<String, BasketItem>>((ref) {
  return BasketNotifier(ref);
});

final basketItemsListProvider = Provider<List<BasketItem>>((ref) {
  final map = ref.watch(basketProvider);
  return map.values.toList();
});

final basketTotalCountProvider = Provider<int>((ref) {
  final map = ref.watch(basketProvider);
  return map.values.fold(0, (sum, item) => sum + item.quantity);
});

final basketTotalPriceProvider = Provider<double>((ref) {
  final map = ref.watch(basketProvider);
  return map.values.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final basketItemQuantityProvider =
    Provider.family<int, String>((ref, itemId) {
  final map = ref.watch(basketProvider);
  return map[itemId]?.quantity ?? 0;
});
