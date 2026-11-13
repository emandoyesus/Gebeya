class PriceAggregateModel {
  final String id;
  final String itemId;
  final String marketId;
  final double medianPrice;
  final double minPrice;
  final double maxPrice;
  final double? p10Price;
  final double? p90Price;
  final int reportCount;
  final String currency;
  final DateTime lastReportedAt;

  const PriceAggregateModel({
    required this.id,
    required this.itemId,
    required this.marketId,
    required this.medianPrice,
    required this.minPrice,
    required this.maxPrice,
    this.p10Price,
    this.p90Price,
    required this.reportCount,
    this.currency = 'ETB',
    required this.lastReportedAt,
  });

  factory PriceAggregateModel.fromJson(Map<String, dynamic> json) {
    return PriceAggregateModel(
      id: json['id'] ?? '',
      itemId: json['item_id'] ?? '',
      marketId: json['market_id'] ?? '',
      medianPrice: (json['median_price'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0.0,
      p10Price: (json['p10_price'] as num?)?.toDouble(),
      p90Price: (json['p90_price'] as num?)?.toDouble(),
      reportCount: json['report_count'] ?? 0,
      currency: json['currency'] ?? 'ETB',
      lastReportedAt: json['last_reported_at'] != null
          ? DateTime.parse(json['last_reported_at'])
          : DateTime.now(),
    );
  }
}
