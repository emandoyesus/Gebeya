import '../constants/categories.dart';
import '../utils/unit_converter.dart';
import '../../features/items/data/item_model.dart';
import '../../features/items/data/market_model.dart';
import '../../features/items/data/price_aggregate_model.dart';

class MockData {
  static final List<MarketModel> markets = [
    const MarketModel(
      id: 'm-merkato',
      nameEn: 'Merkato',
      nameAm: 'መርካቶ',
      city: 'Addis Ababa',
      subcity: 'Addis Ketema',
      latitude: 9.0305,
      longitude: 38.7402,
    ),
    const MarketModel(
      id: 'm-shola',
      nameEn: 'Shola',
      nameAm: 'ሾላ',
      city: 'Addis Ababa',
      subcity: 'Yeka',
      latitude: 9.0232,
      longitude: 38.7951,
    ),
    const MarketModel(
      id: 'm-saris',
      nameEn: 'Saris',
      nameAm: 'ሳሪስ',
      city: 'Addis Ababa',
      subcity: 'Akaky Kaliti',
      latitude: 8.9528,
      longitude: 38.7617,
    ),
    const MarketModel(
      id: 'm-kera',
      nameEn: 'Kera',
      nameAm: 'ቄራ',
      city: 'Addis Ababa',
      subcity: 'Kirkos',
      latitude: 9.0012,
      longitude: 38.7513,
    ),
    const MarketModel(
      id: 'm-megenagna',
      nameEn: 'Megenagna',
      nameAm: 'መገናኛ',
      city: 'Addis Ababa',
      subcity: 'Bole / Yeka',
      latitude: 9.0203,
      longitude: 38.8021,
    ),
  ];

  static final List<ItemModel> items = [
    // Grains & Flours
    const ItemModel(
      id: 'i-teff-magna',
      nameEn: 'Teff (Magna)',
      nameAm: 'ማኛ ጤፍ',
      category: ItemCategory.grainsFlour,
      standardUnit: 'kg',
      iconName: 'grain',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'tassa', nameAm: 'ጣሳ', nameEn: 'Tassa', multiplier: 1.25),
        LocalUnitInfo(unitKey: 'quintal', nameAm: 'ኩንታል', nameEn: 'Quintal', multiplier: 100.0),
      ],
    ),
    const ItemModel(
      id: 'i-teff-sergegna',
      nameEn: 'Teff (Sergegna)',
      nameAm: 'ሰርገኛ ጤፍ',
      category: ItemCategory.grainsFlour,
      standardUnit: 'kg',
      iconName: 'grain',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'tassa', nameAm: 'ጣሳ', nameEn: 'Tassa', multiplier: 1.25),
        LocalUnitInfo(unitKey: 'quintal', nameAm: 'ኩንታል', nameEn: 'Quintal', multiplier: 100.0),
      ],
    ),
    const ItemModel(
      id: 'i-wheat-flour',
      nameEn: 'Wheat Flour',
      nameAm: 'የስንዴ ዱቄት',
      category: ItemCategory.grainsFlour,
      standardUnit: 'kg',
      iconName: 'bakery_dining',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'quintal', nameAm: 'ኩንታል', nameEn: 'Quintal', multiplier: 100.0),
      ],
    ),
    const ItemModel(
      id: 'i-shiro-flour',
      nameEn: 'Shiro Flour',
      nameAm: 'የሽሮ ዱቄት',
      category: ItemCategory.grainsFlour,
      standardUnit: 'kg',
      iconName: 'soup_kitchen',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'tassa', nameAm: 'ጣሳ', nameEn: 'Tassa', multiplier: 1.10),
      ],
    ),

    // Vegetables & Produce
    const ItemModel(
      id: 'i-red-onion',
      nameEn: 'Red Onion',
      nameAm: 'ቀይ ሽንኩርት',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'eco',
    ),
    const ItemModel(
      id: 'i-garlic',
      nameEn: 'Garlic',
      nameAm: 'ነጭ ሽንኩርት',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'spa',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'kubaya', nameAm: 'ኩባያ', nameEn: 'Cup/Kubaya', multiplier: 0.35),
      ],
    ),
    const ItemModel(
      id: 'i-tomato',
      nameEn: 'Tomato',
      nameAm: 'ቲማቲም',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'nutrition',
    ),
    const ItemModel(
      id: 'i-potato',
      nameEn: 'Potato',
      nameAm: 'ድንች',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'agriculture',
    ),
    const ItemModel(
      id: 'i-green-pepper',
      nameEn: 'Green Pepper (Karia)',
      nameAm: 'ቃሪያ',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'local_florist',
    ),

    // Pulses & Legumes
    const ItemModel(
      id: 'i-red-lentils',
      nameEn: 'Red Lentils (Misir Kik)',
      nameAm: 'የቀይ ምስር ክክ',
      category: ItemCategory.pulsesLegumes,
      standardUnit: 'kg',
      iconName: 'grass',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'tassa', nameAm: 'ጣሳ', nameEn: 'Tassa', multiplier: 1.20),
      ],
    ),
    const ItemModel(
      id: 'i-chickpeas',
      nameEn: 'Chickpeas (Shimbra)',
      nameAm: 'ሽምብራ',
      category: ItemCategory.pulsesLegumes,
      standardUnit: 'kg',
      iconName: 'grain',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'tassa', nameAm: 'ጣሳ', nameEn: 'Tassa', multiplier: 1.15),
      ],
    ),

    // Meat & Dairy
    const ItemModel(
      id: 'i-beef',
      nameEn: 'Beef (Siga)',
      nameAm: 'የበሬ ሥጋ',
      category: ItemCategory.meatDairy,
      standardUnit: 'kg',
      iconName: 'restaurant',
    ),
    const ItemModel(
      id: 'i-milk',
      nameEn: 'Fresh Milk',
      nameAm: 'ጥሬ ወተት',
      category: ItemCategory.meatDairy,
      standardUnit: 'liter',
      iconName: 'water_drop',
    ),
    const ItemModel(
      id: 'i-butter',
      nameEn: 'Spiced Butter (Qibe)',
      nameAm: 'የተነጠረ ቅቤ',
      category: ItemCategory.meatDairy,
      standardUnit: 'kg',
      iconName: 'breakfast_dining',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'kubaya', nameAm: 'ኩባያ', nameEn: 'Cup/Kubaya', multiplier: 0.40),
      ],
    ),
    const ItemModel(
      id: 'i-eggs',
      nameEn: 'Eggs',
      nameAm: 'እንቁላል',
      category: ItemCategory.meatDairy,
      standardUnit: 'piece',
      iconName: 'egg',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'crate (30)', nameAm: 'ካርቶን (30)', nameEn: 'Crate (30)', multiplier: 30.0),
      ],
    ),

    // Oil, Sugar & Pantry
    const ItemModel(
      id: 'i-cooking-oil',
      nameEn: 'Cooking Oil',
      nameAm: 'የምግብ ዘይት',
      category: ItemCategory.oilSugarPantry,
      standardUnit: 'liter',
      iconName: 'opacity',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'jog (3L)', nameAm: '3 ሊትር ጆግ', nameEn: '3L Jog', multiplier: 3.0),
        LocalUnitInfo(unitKey: 'jog (5L)', nameAm: '5 ሊትር ጆግ', nameEn: '5L Jog', multiplier: 5.0),
      ],
    ),
    const ItemModel(
      id: 'i-sugar',
      nameEn: 'Sugar',
      nameAm: 'ስኳር',
      category: ItemCategory.oilSugarPantry,
      standardUnit: 'kg',
      iconName: 'cookie',
    ),
    const ItemModel(
      id: 'i-berbere',
      nameEn: 'Berbere',
      nameAm: 'በርበሬ',
      category: ItemCategory.spices,
      standardUnit: 'kg',
      iconName: 'whatshot',
      supportedLocalUnits: [
        LocalUnitInfo(unitKey: 'kubaya', nameAm: 'ኩባያ', nameEn: 'Cup/Kubaya', multiplier: 0.35),
      ],
    ),
  ];

  static Map<String, PriceAggregateModel> generateInitialAggregates(String marketId) {
    final now = DateTime.now();
    // Realistic Addis Ababa market prices (ETB)
    final prices = <String, Map<String, dynamic>>{
      'i-teff-magna': {'median': 125.0, 'min': 115.0, 'max': 135.0, 'count': 18},
      'i-teff-sergegna': {'median': 105.0, 'min': 95.0, 'max': 115.0, 'count': 14},
      'i-wheat-flour': {'median': 85.0, 'min': 80.0, 'max': 92.0, 'count': 9},
      'i-shiro-flour': {'median': 190.0, 'min': 175.0, 'max': 210.0, 'count': 11},
      'i-red-onion': {'median': 85.0, 'min': 70.0, 'max': 100.0, 'count': 32},
      'i-garlic': {'median': 320.0, 'min': 290.0, 'max': 360.0, 'count': 15},
      'i-tomato': {'median': 60.0, 'min': 45.0, 'max': 75.0, 'count': 26},
      'i-potato': {'median': 40.0, 'min': 35.0, 'max': 50.0, 'count': 22},
      'i-green-pepper': {'median': 90.0, 'min': 75.0, 'max': 110.0, 'count': 12},
      'i-red-lentils': {'median': 175.0, 'min': 160.0, 'max': 190.0, 'count': 16},
      'i-chickpeas': {'median': 130.0, 'min': 115.0, 'max': 145.0, 'count': 8},
      'i-beef': {'median': 950.0, 'min': 900.0, 'max': 1050.0, 'count': 21},
      'i-milk': {'median': 90.0, 'min': 80.0, 'max': 100.0, 'count': 10},
      'i-butter': {'median': 1100.0, 'min': 980.0, 'max': 1250.0, 'count': 7},
      'i-eggs': {'median': 17.5, 'min': 16.0, 'max': 19.0, 'count': 45},
      'i-cooking-oil': {'median': 195.0, 'min': 180.0, 'max': 215.0, 'count': 28},
      'i-sugar': {'median': 110.0, 'min': 100.0, 'max': 125.0, 'count': 19},
      'i-berbere': {'median': 450.0, 'min': 400.0, 'max': 520.0, 'count': 14},
    };

    final result = <String, PriceAggregateModel>{};
    prices.forEach((itemId, data) {
      // Small randomized offset based on market for realism
      final offset = (marketId.hashCode % 5) - 2.0;
      final median = (data['median'] as double) + offset;
      final min = (data['min'] as double) + (offset * 0.5);
      final max = (data['max'] as double) + (offset * 0.5);

      result[itemId] = PriceAggregateModel(
        id: 'agg-$marketId-$itemId',
        itemId: itemId,
        marketId: marketId,
        medianPrice: median,
        minPrice: min,
        maxPrice: max,
        p10Price: min + (median - min) * 0.2,
        p90Price: median + (max - median) * 0.8,
        reportCount: (data['count'] as int),
        currency: 'ETB',
        lastReportedAt: now.subtract(Duration(hours: (itemId.hashCode % 48) + 1)),
      );
    });

    return result;
  }
}
