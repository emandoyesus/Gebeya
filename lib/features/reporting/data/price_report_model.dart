class PriceReportModel {
  final String? id;
  final String itemId;
  final String marketId;
  final String? userId;
  final String deviceId;
  final double price; // Total paid in ETB
  final double quantity; // In reported unit
  final String reportedUnit; // e.g. 'tassa', 'kg'
  final double pricePerStandardUnit; // normalized to ETB/kg or ETB/L
  final String source;
  final String status;
  final String? notes;
  final DateTime reportedAt;

  const PriceReportModel({
    this.id,
    required this.itemId,
    required this.marketId,
    this.userId,
    required this.deviceId,
    required this.price,
    required this.quantity,
    required this.reportedUnit,
    required this.pricePerStandardUnit,
    this.source = 'user',
    this.status = 'pending',
    this.notes,
    required this.reportedAt,
  });

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'market_id': marketId,
    'user_id': userId,
    'device_id': deviceId,
    'price': price,
    'quantity': quantity,
    'reported_unit': reportedUnit,
    'price_per_standard_unit': pricePerStandardUnit,
    'source': source,
    'status': status,
    'notes': notes,
    'reported_at': reportedAt.toIso8601String(),
  };
}
