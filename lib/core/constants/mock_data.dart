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
    const ItemModel(
      id: 'i-smartphone',
      nameEn: 'Samsung Galaxy A16 (4 GB / 128 GB)',
      nameAm: 'Samsung Galaxy A16 (4 GB / 128 GB)',
      imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=480&q=80',
      listingPrice: 29500,
      listingSource: 'https://jiji.com.et/bole/mobile-phones/new-samsung-galaxy-a16-128-gb-black-a9xkPRtqncl3l9yrCf051oD.html',
      listingNote: 'Jiji · Bole · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.',
      category: ItemCategory.electronics,
      standardUnit: 'piece',
    ),
    const ItemModel(
      id: 'i-laptop',
      nameEn: 'Lenovo ThinkPad T480 (Core i5 8th Gen / 8 GB / 256 GB SSD)',
      nameAm: 'Lenovo ThinkPad T480 (Core i5 8th Gen / 8 GB / 256 GB SSD)',
      imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?auto=format&fit=crop&w=480&q=80',
      listingPrice: 56000,
      listingSource: 'https://jiji.com.et/am/yeka/computers-and-laptops/new-laptop-lenovo-thinkpad-t480-8gb-intel-core-i5-ssd-256gb-bo6h8dqI6HTutnsNxZK3OeZT.html',
      listingNote: 'Jiji · Yeka · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.',
      category: ItemCategory.electronics,
      standardUnit: 'piece',
    ),
    const ItemModel(
      id: 'i-headphones',
      nameEn: 'Anker Soundcore R50i True Wireless Earbuds',
      nameAm: 'Anker Soundcore R50i True Wireless Earbuds',
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=480&q=80',
      listingPrice: 4600,
      listingSource: 'https://jiji.com.et/bole/headphones/soundcore-by-anker-r50i-true-wireless-earbuds-brand-new-itmsu4YmhVxLQnuEaCdY8QLl.html',
      listingNote: 'Jiji · Bole · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.',
      category: ItemCategory.electronics,
      standardUnit: 'piece',
    ),
    const ItemModel(
      id: 'i-charger',
      nameEn: 'Samsung EP-T2510 USB-C Charger (25 W)',
      nameAm: 'Samsung EP-T2510 USB-C Charger (25 W)',
      imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?auto=format&fit=crop&w=480&q=80',
      listingPrice: 1700,
      listingSource: 'https://jiji.com.et/kirkos/cell-phones-tablets-accessories/samsung-25w-super-fast-usb-c-charger-mt5nWziKNuSqGXjoGX9KhPFG.html',
      listingNote: 'Jiji · Kirkos · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.',
      category: ItemCategory.electronics,
      standardUnit: 'piece',
    ),
    const ItemModel(
      id: 'i-t-shirt',
      nameEn: 'Cotton T-shirt',
      nameAm: 'የጥጥ ቲሸርት',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.clothing,
      standardUnit: 'piece',
      listingPrice: 850,
      listingSource: 'https://jiji.com.et/clothing/t-shirts',
      listingNote: 'Jiji · Merkato · 100% combed cotton, breathable, all sizes available.',
    ),
    const ItemModel(
      id: 'i-jeans',
      nameEn: 'Denim Jeans',
      nameAm: 'ጂንስ ሱሪ',
      imageUrl: 'https://images.unsplash.com/photo-1542272604-780c96856592?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.clothing,
      standardUnit: 'piece',
      listingPrice: 2200,
      listingSource: 'https://jiji.com.et/clothing/jeans',
      listingNote: 'Jiji · Bole · Stretch denim, durable stitch, slim and regular fit.',
    ),
    const ItemModel(
      id: 'i-jacket',
      nameEn: 'Lightweight Jacket',
      nameAm: 'ቀላል ጃኬት',
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.clothing,
      standardUnit: 'piece',
      listingPrice: 3500,
      listingSource: 'https://jiji.com.et/clothing/jackets',
      listingNote: 'Jiji · Piassa · Windproof lightweight jacket with hood, multiple colours.',
    ),
    const ItemModel(
      id: 'i-dress',
      nameEn: 'Cotton Dress',
      nameAm: 'የጥጥ ቀሚስ',
      imageUrl: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.clothing,
      standardUnit: 'piece',
      listingPrice: 2800,
      listingSource: 'https://jiji.com.et/clothing/dresses',
      listingNote: 'Jiji · Bole · Floral cotton casual dress, comfortable summer wear.',
    ),
    // Grains & Flours
    const ItemModel(
      id: 'i-teff-magna',
      nameEn: 'Teff (Magna)',
      nameAm: 'ማኛ ጤፍ',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1467019972079-a273e1bc9173?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'eco',
    ),
    const ItemModel(
      id: 'i-garlic',
      nameEn: 'Garlic',
      nameAm: 'ነጭ ሽንኩርት',
      imageUrl: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1568492905819-d24bf71cefe8?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'nutrition',
    ),
    const ItemModel(
      id: 'i-potato',
      nameEn: 'Potato',
      nameAm: 'ድንች',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'agriculture',
    ),
    const ItemModel(
      id: 'i-green-pepper',
      nameEn: 'Green Pepper (Karia)',
      nameAm: 'ቃሪያ',
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.vegetablesProduce,
      standardUnit: 'kg',
      iconName: 'local_florist',
    ),

    // Pulses & Legumes
    const ItemModel(
      id: 'i-red-lentils',
      nameEn: 'Red Lentils (Misir Kik)',
      nameAm: 'የቀይ ምስር ክክ',
      imageUrl: 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1551462147-ff29053bfc14?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1551028150-64b9f398f678?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.meatDairy,
      standardUnit: 'kg',
      iconName: 'restaurant',
    ),
    const ItemModel(
      id: 'i-milk',
      nameEn: 'Fresh Milk',
      nameAm: 'ጥሬ ወተት',
      imageUrl: 'https://images.unsplash.com/photo-1523473827533-2a64d0d36748?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.meatDairy,
      standardUnit: 'liter',
      iconName: 'water_drop',
    ),
    const ItemModel(
      id: 'i-butter',
      nameEn: 'Spiced Butter (Qibe)',
      nameAm: 'የተነጠረ ቅቤ',
      imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=480&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=480&q=80',
      category: ItemCategory.oilSugarPantry,
      standardUnit: 'kg',
      iconName: 'cookie',
    ),
    const ItemModel(
      id: 'i-berbere',
      nameEn: 'Berbere',
      nameAm: 'በርበሬ',
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=480&q=80',
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

      // Electronics & Tech
      'i-smartphone': {'median': 29500.0, 'min': 27000.0, 'max': 32000.0, 'count': 16}, // Samsung Galaxy A16
      'i-laptop': {'median': 56000.0, 'min': 51000.0, 'max': 62000.0, 'count': 12}, // ThinkPad T480
      'i-headphones': {'median': 4600.0, 'min': 4100.0, 'max': 5200.0, 'count': 20}, // Soundcore Earbuds
      'i-charger': {'median': 1700.0, 'min': 1400.0, 'max': 2100.0, 'count': 25}, // Samsung 25W Charger
      'ba5e2026-1116-4000-8000-000000000126': {'median': 118000.0, 'min': 110000.0, 'max': 128000.0, 'count': 18}, // iPhone 15
      'ba5e2026-1116-4000-8000-000000000127': {'median': 105000.0, 'min': 98000.0, 'max': 115000.0, 'count': 14}, // Galaxy S24
      'ba5e2026-1116-4000-8000-000000000128': {'median': 58000.0, 'min': 53000.0, 'max': 64000.0, 'count': 10}, // iPad 10th gen
      'ba5e2026-1116-4000-8000-000000000129': {'median': 88000.0, 'min': 82000.0, 'max': 96000.0, 'count': 9}, // PS5 Slim
      'ba5e2026-1116-4000-8000-000000000130': {'median': 52000.0, 'min': 47000.0, 'max': 57000.0, 'count': 7}, // Xbox Series S
      'ba5e2026-1116-4000-8000-000000000131': {'median': 28000.0, 'min': 25000.0, 'max': 32000.0, 'count': 11}, // HP M110w printer
      'ba5e2026-1116-4000-8000-000000000132': {'median': 8500.0, 'min': 7500.0, 'max': 9600.0, 'count': 15}, // TP-Link AX53 router
      'ba5e2026-1116-4000-8000-000000000133': {'median': 18500.0, 'min': 16500.0, 'max': 21000.0, 'count': 13}, // Samsung T7 SSD
      'ba5e2026-1116-4000-8000-000000000134': {'median': 1400.0, 'min': 1100.0, 'max': 1750.0, 'count': 28}, // Logitech M185
      'ba5e2026-1116-4000-8000-000000000135': {'median': 1200.0, 'min': 950.0, 'max': 1500.0, 'count': 22}, // Logitech K120
      'ba5e2026-1116-4000-8000-000000000136': {'median': 5800.0, 'min': 5000.0, 'max': 6700.0, 'count': 16}, // JBL Go 4
      'ba5e2026-1116-4000-8000-000000000137': {'median': 26500.0, 'min': 24000.0, 'max': 29500.0, 'count': 19}, // Galaxy A15

      // Clothing & Fashion
      'i-t-shirt': {'median': 850.0, 'min': 650.0, 'max': 1100.0, 'count': 20}, // Cotton T-shirt
      'i-jeans': {'median': 2200.0, 'min': 1800.0, 'max': 2700.0, 'count': 18}, // Denim Jeans
      'i-jacket': {'median': 3500.0, 'min': 2900.0, 'max': 4200.0, 'count': 11}, // Lightweight Jacket
      'i-dress': {'median': 2800.0, 'min': 2200.0, 'max': 3500.0, 'count': 14}, // Cotton Dress
      'ba5e2026-1116-4000-8000-000000000032': {'median': 1200.0, 'min': 900.0, 'max': 1600.0, 'count': 15}, // Cotton shirt
      'ba5e2026-1116-4000-8000-000000000033': {'median': 1800.0, 'min': 1400.0, 'max': 2300.0, 'count': 12}, // Hoodie
      'ba5e2026-1116-4000-8000-000000000034': {'median': 1500.0, 'min': 1100.0, 'max': 2100.0, 'count': 10}, // Netela
      'ba5e2026-1116-4000-8000-000000000035': {'median': 2600.0, 'min': 2100.0, 'max': 3200.0, 'count': 7}, // Uniform
      'ba5e2026-1116-4000-8000-000000000151': {'median': 1400.0, 'min': 1100.0, 'max': 1800.0, 'count': 9}, // Trousers
      'ba5e2026-1116-4000-8000-000000000152': {'median': 1600.0, 'min': 1250.0, 'max': 2000.0, 'count': 11}, // Sweater
      'ba5e2026-1116-4000-8000-000000000153': {'median': 1200.0, 'min': 950.0, 'max': 1500.0, 'count': 8}, // Raincoat
      'ba5e2026-1116-4000-8000-000000000154': {'median': 4500.0, 'min': 3500.0, 'max': 6500.0, 'count': 6}, // Habesha dress
      'ba5e2026-1116-4000-8000-000000000155': {'median': 350.0, 'min': 280.0, 'max': 450.0, 'count': 14}, // Socks
      '8a7c2026-1116-4000-8000-000000000020': {'median': 650.0, 'min': 500.0, 'max': 850.0, 'count': 25}, // Plain cotton T-shirt
      '8a7c2026-1116-4000-8000-000000000021': {'median': 2000.0, 'min': 1600.0, 'max': 2400.0, 'count': 16}, // White cotton T-shirt
      '8a7c2026-1116-4000-8000-000000000048': {'median': 16500.0, 'min': 13500.0, 'max': 21000.0, 'count': 10}, // Habesha Kemis
      '8a7c2026-1116-4000-8000-000000000049': {'median': 9500.0, 'min': 8200.0, 'max': 12000.0, 'count': 8}, // 2-Piece Suit

      // Electronics listings (Davi, AddisMobile, Jiji)
      '8a7c2026-1116-4000-8000-000000000001': {'median': 31000.0, 'min': 28500.0, 'max': 34000.0, 'count': 15}, // Galaxy A16 6GB
      '8a7c2026-1116-4000-8000-000000000002': {'median': 25000.0, 'min': 23000.0, 'max': 27500.0, 'count': 18}, // Galaxy A16 4GB
      '8a7c2026-1116-4000-8000-000000000003': {'median': 17800.0, 'min': 16000.0, 'max': 19800.0, 'count': 12}, // Galaxy M07
      '8a7c2026-1116-4000-8000-000000000004': {'median': 20000.0, 'min': 18000.0, 'max': 22500.0, 'count': 14}, // Galaxy A06 128GB
      '8a7c2026-1116-4000-8000-000000000005': {'median': 20500.0, 'min': 18500.0, 'max': 23000.0, 'count': 11}, // Galaxy A06 64GB
      '8a7c2026-1116-4000-8000-000000000006': {'median': 23000.0, 'min': 21000.0, 'max': 25500.0, 'count': 13}, // Galaxy A07 6GB
      '8a7c2026-1116-4000-8000-000000000007': {'median': 20000.0, 'min': 18000.0, 'max': 22500.0, 'count': 12}, // Galaxy A07 4GB
      '8a7c2026-1116-4000-8000-000000000008': {'median': 19500.0, 'min': 17500.0, 'max': 21800.0, 'count': 10}, // Galaxy A07 64GB
      '8a7c2026-1116-4000-8000-000000000009': {'median': 16500.0, 'min': 15000.0, 'max': 18500.0, 'count': 17}, // Infinix Smart 10 128GB
      '8a7c2026-1116-4000-8000-000000000010': {'median': 14500.0, 'min': 13000.0, 'max': 16200.0, 'count': 14}, // Infinix Smart 10 64GB
      '8a7c2026-1116-4000-8000-000000000011': {'median': 14200.0, 'min': 12800.0, 'max': 15800.0, 'count': 15}, // Infinix Smart 10 2GB
      '8a7c2026-1116-4000-8000-000000000012': {'median': 190000.0, 'min': 178000.0, 'max': 205000.0, 'count': 8}, // Galaxy S25 Ultra
      '8a7c2026-1116-4000-8000-000000000013': {'median': 49900.0, 'min': 46000.0, 'max': 54000.0, 'count': 16}, // Galaxy A17 5G
      '8a7c2026-1116-4000-8000-000000000014': {'median': 34500.0, 'min': 31500.0, 'max': 37800.0, 'count': 14}, // Galaxy A17 4GB
      '8a7c2026-1116-4000-8000-000000000015': {'median': 36900.0, 'min': 33800.0, 'max': 40200.0, 'count': 15}, // Galaxy A17 6GB
      '8a7c2026-1116-4000-8000-000000000016': {'median': 28500.0, 'min': 26000.0, 'max': 31500.0, 'count': 12}, // Galaxy A07 128GB
      '8a7c2026-1116-4000-8000-000000000017': {'median': 84500.0, 'min': 79000.0, 'max': 91000.0, 'count': 9}, // Galaxy A57
      '8a7c2026-1116-4000-8000-000000000018': {'median': 52000.0, 'min': 47500.0, 'max': 57000.0, 'count': 11}, // Galaxy Tab A11+
      '8a7c2026-1116-4000-8000-000000000019': {'median': 520000.0, 'min': 490000.0, 'max': 555000.0, 'count': 6}, // MacBook Pro M5
      '8a7c2026-1116-4000-8000-000000000027': {'median': 38000.0, 'min': 35000.0, 'max': 42000.0, 'count': 24}, // iPhone 11
      '8a7c2026-1116-4000-8000-000000000028': {'median': 68000.0, 'min': 64000.0, 'max': 74000.0, 'count': 19}, // iPhone 13 Pro Max
      '8a7c2026-1116-4000-8000-000000000029': {'median': 86000.0, 'min': 82000.0, 'max': 92000.0, 'count': 14}, // iPhone 14 Pro
      '8a7c2026-1116-4000-8000-000000000030': {'median': 39500.0, 'min': 37000.0, 'max': 43000.0, 'count': 16}, // Redmi Note 13 Pro
      '8a7c2026-1116-4000-8000-000000000031': {'median': 31000.0, 'min': 28500.0, 'max': 34000.0, 'count': 15}, // Tecno Camon 30
      '8a7c2026-1116-4000-8000-000000000032': {'median': 54000.0, 'min': 49000.0, 'max': 60000.0, 'count': 11}, // HP EliteBook 840 G6
      '8a7c2026-1116-4000-8000-000000000033': {'median': 48000.0, 'min': 44000.0, 'max': 54000.0, 'count': 10}, // Dell Latitude 7490
      '8a7c2026-1116-4000-8000-000000000036': {'median': 5200.0, 'min': 4800.0, 'max': 5900.0, 'count': 17}, // Huawei MiFi

      // Jiji Ethiopia Automotive & Vehicles
      '8a7c2026-1116-4000-8000-000000000022': {'median': 1950000.0, 'min': 1750000.0, 'max': 2200000.0, 'count': 12}, // Toyota Vitz
      '8a7c2026-1116-4000-8000-000000000023': {'median': 2850000.0, 'min': 2600000.0, 'max': 3200000.0, 'count': 15}, // Toyota Corolla
      '8a7c2026-1116-4000-8000-000000000024': {'median': 3450000.0, 'min': 3200000.0, 'max': 3750000.0, 'count': 14}, // Suzuki Dzire
      '8a7c2026-1116-4000-8000-000000000025': {'median': 5800000.0, 'min': 5400000.0, 'max': 6400000.0, 'count': 9}, // Toyota RAV4
      '8a7c2026-1116-4000-8000-000000000026': {'median': 520000.0, 'min': 480000.0, 'max': 580000.0, 'count': 18}, // Bajaj RE 4S

      // Jiji Ethiopia Furniture, Home & Appliances
      '8a7c2026-1116-4000-8000-000000000034': {'median': 46000.0, 'min': 42000.0, 'max': 51000.0, 'count': 13}, // Samsung 43" 4K Smart TV
      '8a7c2026-1116-4000-8000-000000000035': {'median': 98000.0, 'min': 92000.0, 'max': 110000.0, 'count': 8}, // Sony 55" Bravia TV
      '8a7c2026-1116-4000-8000-000000000037': {'median': 62000.0, 'min': 55000.0, 'max': 72000.0, 'count': 10}, // L-Shape Sofa
      '8a7c2026-1116-4000-8000-000000000038': {'median': 38000.0, 'min': 33000.0, 'max': 44000.0, 'count': 8}, // Queen Wood Bed
      '8a7c2026-1116-4000-8000-000000000039': {'median': 24000.0, 'min': 21000.0, 'max': 28000.0, 'count': 14}, // Orthopedic Mattress
      '8a7c2026-1116-4000-8000-000000000040': {'median': 36000.0, 'min': 31000.0, 'max': 42000.0, 'count': 9}, // 4-Door Wardrobe
      '8a7c2026-1116-4000-8000-000000000041': {'median': 42000.0, 'min': 37000.0, 'max': 48000.0, 'count': 7}, // 6-Seater Dining Table
      '8a7c2026-1116-4000-8000-000000000042': {'median': 22000.0, 'min': 19000.0, 'max': 26000.0, 'count': 11}, // TV Stand
      '8a7c2026-1116-4000-8000-000000000043': {'median': 82000.0, 'min': 76000.0, 'max': 91000.0, 'count': 9}, // LG 8kg Washing Machine
      '8a7c2026-1116-4000-8000-000000000044': {'median': 9500.0, 'min': 8400.0, 'max': 11000.0, 'count': 16}, // Digital Air Fryer
      '8a7c2026-1116-4000-8000-000000000045': {'median': 14500.0, 'min': 13000.0, 'max': 16500.0, 'count': 21}, // Electric Mitad
      '8a7c2026-1116-4000-8000-000000000046': {'median': 16500.0, 'min': 14800.0, 'max': 18900.0, 'count': 12}, // Granite Cookware
      '8a7c2026-1116-4000-8000-000000000047': {'median': 8500.0, 'min': 7200.0, 'max': 9800.0, 'count': 15}, // Rekebot & Sini Set

      // Shoes, Beauty & Tools
      '8a7c2026-1116-4000-8000-000000000050': {'median': 5200.0, 'min': 4500.0, 'max': 6200.0, 'count': 19}, // Nike Air Force 1
      '8a7c2026-1116-4000-8000-000000000051': {'median': 4200.0, 'min': 3600.0, 'max': 4900.0, 'count': 13}, // Men's Oxford Shoes
      '8a7c2026-1116-4000-8000-000000000052': {'median': 1950.0, 'min': 1750.0, 'max': 2300.0, 'count': 22}, // Kirkland Minoxidil
      '8a7c2026-1116-4000-8000-000000000053': {'median': 52000.0, 'min': 47000.0, 'max': 59000.0, 'count': 7}, // Petrol Generator 3.5 kVA
      '8a7c2026-1116-4000-8000-000000000054': {'median': 16500.0, 'min': 14000.0, 'max': 21000.0, 'count': 18}, // Holiday Sheep/Ram
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
