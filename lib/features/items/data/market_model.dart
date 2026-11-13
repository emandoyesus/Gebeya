class MarketModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final String city;
  final String? subcity;
  final double? latitude;
  final double? longitude;

  const MarketModel({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.city,
    this.subcity,
    this.latitude,
    this.longitude,
  });

  String localizedName(bool isAmharic) => isAmharic ? nameAm : nameEn;

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAm: json['name_am'] ?? '',
      city: json['city'] ?? 'Addis Ababa',
      subcity: json['subcity'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
