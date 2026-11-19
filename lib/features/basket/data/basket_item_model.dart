import '../../items/data/item_model.dart';

class BasketItem {
  final ItemModel item;
  final int quantity;
  final String unit;
  final double unitPrice;

  const BasketItem({
    required this.item,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  BasketItem copyWith({
    int? quantity,
    String? unit,
    double? unitPrice,
  }) {
    return BasketItem(
      item: item,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': item.id,
    'quantity': quantity,
    'unit': unit,
    'unitPrice': unitPrice,
  };
}
