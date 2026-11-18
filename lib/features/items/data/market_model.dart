class MarketModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final String city;
  final String? subcity;
  final String? region;
  final double? latitude;
  final double? longitude;

  const MarketModel({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.city,
    this.subcity,
    this.region,
    this.latitude,
    this.longitude,
  });

  String localizedName(bool isAmharic) => isAmharic ? nameAm : nameEn;

  String localizedLocation(bool isAmharic) {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (subcity != null && subcity!.isNotEmpty) parts.add(subcity!);
    if (region != null && region!.isNotEmpty && region != city) parts.add(region!);
    return parts.join(' • ');
  }

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAm: json['name_am'] ?? '',
      city: json['city'] ?? '',
      subcity: json['subcity'],
      region: json['region'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
