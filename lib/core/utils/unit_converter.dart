class LocalUnitInfo {
  final String unitKey;
  final String nameAm;
  final String nameEn;
  final double multiplier; // Multiplier to convert 1 local unit into standard unit

  const LocalUnitInfo({
    required this.unitKey,
    required this.nameAm,
    required this.nameEn,
    required this.multiplier,
  });

  factory LocalUnitInfo.fromJson(Map<String, dynamic> json) {
    return LocalUnitInfo(
      unitKey: json['unit'] ?? '',
      nameAm: json['name_am'] ?? json['unit'] ?? '',
      nameEn: json['name_en'] ?? json['unit'] ?? '',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'unit': unitKey,
    'name_am': nameAm,
    'name_en': nameEn,
    'multiplier': multiplier,
  };
}

class UnitConverter {
  /// Converts a price paid for a given quantity in a local unit into price per standard unit (e.g. ETB/kg)
  /// Example: Paid 150 ETB for 1 Tassa of Teff (where 1 Tassa = 1.25 kg)
  /// Result: 150 / (1 * 1.25) = 120 ETB/kg
  static double calculatePricePerStandardUnit({
    required double totalPrice,
    required double quantity,
    required double unitMultiplier,
  }) {
    if (quantity <= 0 || unitMultiplier <= 0) return 0.0;
    final totalStandardUnits = quantity * unitMultiplier;
    return totalPrice / totalStandardUnits;
  }
}
