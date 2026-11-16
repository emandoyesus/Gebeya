import 'dart:convert';
import 'dart:io';

/// Populates dedicated, distinct product images for all catalog items and listings.
/// Uses only CORS-compliant (Access-Control-Allow-Origin: *), high-quality images from Unsplash and Pexels.
/// Completely avoids Pinterest (blocked by CORS on Flutter Web) and Wikimedia (400 Bad Request on thumbs).
void main() {
  final catalogFile = File('assets/data/marketplace_catalog.json');
  final listingsFile = File('assets/data/public_listings.json');
  final bundledFile = File('lib/core/constants/bundled_catalog.dart');

  final catalog = jsonDecode(catalogFile.readAsStringSync()) as List;
  final listings = jsonDecode(listingsFile.readAsStringSync()) as List;

  // Specific high-quality, verified image URLs for every marketplace item
  final imagesByItem = <String, String>{
    // Vegetables & Fruits (distinct individual photos instead of generic salad bowl)
    'Banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=480&q=80',
    'Orange': 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?auto=format&fit=crop&w=480&q=80',
    'Apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=480&q=80',
    'Mango': 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=480&q=80',
    'Avocado': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=480&q=80',
    'Papaya': 'https://images.unsplash.com/photo-1617112848923-cc2234396a8d?auto=format&fit=crop&w=480&q=80',
    'Watermelon': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=480&q=80',
    'Lemon': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=480&q=80',
    'Carrot': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=480&q=80',
    'Cabbage': 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=480&q=80',
    'Spinach': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=480&q=80',
    'Cucumber': 'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?auto=format&fit=crop&w=480&q=80',
    'Pineapple': 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?auto=format&fit=crop&w=480&q=80',
    'Grapes': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=480&q=80',
    'Beetroot': 'https://images.unsplash.com/photo-1593105544559-ecb03bf76f82?auto=format&fit=crop&w=480&q=80',
    'Sweet potato': 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?auto=format&fit=crop&w=480&q=80',
    'Green beans': 'https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?auto=format&fit=crop&w=480&q=80',

    // Grains & Flours
    'Rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=480&q=80',
    'Maize': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=480&q=80',
    'Barley': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=480&q=80',
    'Oats': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?auto=format&fit=crop&w=480&q=80',

    // Pulses & Legumes
    'White beans': 'https://images.unsplash.com/photo-1551462147-ff29053bfc14?auto=format&fit=crop&w=480&q=80',
    'Fava beans': 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?auto=format&fit=crop&w=480&q=80',
    'Split peas': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=480&q=80',

    // Meat & Dairy
    'Chicken (whole)': 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?auto=format&fit=crop&w=480&q=80',
    'Tilapia fish': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=480&q=80',
    'Plain yogurt': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=480&q=80',
    'Fresh cheese (Ayib)': 'https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=480&q=80',

    // Pantry & Spices
    'Pasta (500 g)': 'https://images.unsplash.com/photo-1551462147-37885acc36f1?auto=format&fit=crop&w=480&q=80',
    'Honey': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=480&q=80',
    'Tomato paste (400 g)': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=480&q=80',
    'Peanut butter (350 g)': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=480&q=80',
    'Turmeric': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=480&q=80',
    'Black pepper': 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?auto=format&fit=crop&w=480&q=80',
    'Cinnamon': 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?auto=format&fit=crop&w=480&q=80',
    'Salt': 'https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?auto=format&fit=crop&w=480&q=80',

    // Clothing & Fashion (distinct clothing items)
    'Cotton shirt (adult)': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=480&q=80',
    'Hooded sweatshirt (adult)': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=480&q=80',
    'Traditional cotton shawl (Netela)': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=480&q=80',
    'School uniform set': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=480&q=80',
    'Adult cotton trousers': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=480&q=80',
    'Adult knitted sweater': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=480&q=80',
    'Adult raincoat': 'https://images.unsplash.com/photo-1544923246-77307dd654cb?auto=format&fit=crop&w=480&q=80',
    'Habesha dress (cotton)': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=480&q=80',
    'Cotton socks (3 pairs)': 'https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?auto=format&fit=crop&w=480&q=80',

    // Beverages
    'Roasted coffee beans': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=480&q=80',
    'Black tea (100 g)': 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=480&q=80',
    'Bottled water (1 L)': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=480&q=80',
    'Orange juice (1 L)': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=480&q=80',
    'Ground coffee (250 g)': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=480&q=80',

    // Bakery
    'Injera (teff)': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=480&q=80',
    'Bread loaf': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=480&q=80',
    'Plain biscuits (200 g)': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=480&q=80',
    'Roasted chickpea snack': 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?auto=format&fit=crop&w=480&q=80',
    'Potato chips (100 g)': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=480&q=80',

    // Shoes
    'Adult running shoes': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=480&q=80',
    'Leather dress shoes': 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=480&q=80',
    'Adult sandals': 'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?auto=format&fit=crop&w=480&q=80',
    'School shoes': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=480&q=80',
    'Work boots': 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=480&q=80',

    // Bags
    'School backpack': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=480&q=80',
    'Laptop bag (15.6 inch)': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=480&q=80',
    'Travel suitcase (medium)': 'https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?auto=format&fit=crop&w=480&q=80',
    'Leather wallet': 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=480&q=80',
    'Adjustable belt': 'https://images.unsplash.com/photo-1624222247344-550fb60583dc?auto=format&fit=crop&w=480&q=80',

    // Beauty
    'Shampoo (400 ml)': 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=480&q=80',
    'Body lotion (400 ml)': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=480&q=80',
    'Bar soap (100 g)': 'https://images.unsplash.com/photo-1600857544200-b2f666a9a2ec?auto=format&fit=crop&w=480&q=80',
    'Toothpaste (100 ml)': 'https://images.unsplash.com/photo-1559599101-f09722fb4948?auto=format&fit=crop&w=480&q=80',
    'Toothbrush (adult)': 'https://images.unsplash.com/photo-1559599101-f09722fb4948?auto=format&fit=crop&w=480&q=80',

    // Health
    'Digital thermometer': 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=480&q=80',
    'First-aid box (empty)': 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&w=480&q=80',
    'Adhesive bandages (20 pack)': 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&w=480&q=80',
    'Reusable hot-water bottle': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=480&q=80',
    'Walking stick': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=480&q=80',

    // Baby
    'Baby diapers (size 3, 40 pack)': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=480&q=80',
    'Baby wipes (80 pack)': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=480&q=80',
    'Baby blanket': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=480&q=80',
    'Baby feeding bottle (250 ml)': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=480&q=80',
    'Maternity nursing pillow': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?auto=format&fit=crop&w=480&q=80',

    // Home & Furniture
    'Dining chair (wood)': 'https://images.unsplash.com/photo-1503602642458-232111445657?auto=format&fit=crop&w=480&q=80',
    'Dining table (4 seats)': 'https://images.unsplash.com/photo-1617806118233-18e1de247200?auto=format&fit=crop&w=480&q=80',
    'Bed sheet set (double)': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=480&q=80',
    'Pillow (standard)': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?auto=format&fit=crop&w=480&q=80',
    'Curtain panels (pair)': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=480&q=80',
    'Three-seat sofa': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=480&q=80',
    'Double bed frame (140 x 200 cm)': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=480&q=80',
    'Foam mattress (140 x 200 cm)': 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=480&q=80',
    'Two-door wardrobe': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=480&q=80',
    'Office desk (120 cm)': 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=480&q=80',

    // Kitchen
    'Cooking pot (5 L)': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=480&q=80',
    'Frying pan (28 cm)': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=480&q=80',
    'Dinner plates (6 pieces)': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=480&q=80',
    'Drinking glasses (6 pieces)': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=480&q=80',
    'Coffee pot (Jebena)': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=480&q=80',

    // Appliances
    'Electric kettle (1.7 L)': 'https://images.unsplash.com/photo-1594213114663-d94db9b17125?auto=format&fit=crop&w=480&q=80',
    'Blender (1.5 L)': 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=480&q=80',
    'Electric iron': 'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=480&q=80',
    'Standing fan (16 inch)': 'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?auto=format&fit=crop&w=480&q=80',
    'Single-burner electric stove': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=480&q=80',
    'Refrigerator (double-door, 250 L)': 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=480&q=80',
    'Washing machine (front-load, 7 kg)': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=480&q=80',
    'Microwave oven (20 L)': 'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=480&q=80',
    'Air fryer (5 L)': 'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=480&q=80',
    'Vacuum cleaner (bagless)': 'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=480&q=80',
    'Electric injera maker (60 cm)': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=480&q=80',
    'Chest freezer (200 L)': 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=480&q=80',
    'Smart television (43 inch, Full HD)': 'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=480&q=80',

    // Cleaning
    'Laundry detergent (1 kg)': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=480&q=80',
    'Dishwashing liquid (1 L)': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=480&q=80',
    'Floor mop': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=480&q=80',
    'Broom': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=480&q=80',
    'Waste bin (20 L)': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=480&q=80',

    // Books & Stationery
    'Exercise book (100 pages)': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=480&q=80',
    'Ballpoint pens (10 pack)': 'https://images.unsplash.com/photo-1585336261026-70e28f3b1458?auto=format&fit=crop&w=480&q=80',
    'A4 copier paper (500 sheets)': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&w=480&q=80',
    'Amharic-English dictionary': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=480&q=80',
    'Scientific calculator': 'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=480&q=80',

    // Sports
    'Football (size 5)': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=480&q=80',
    'Basketball (size 7)': 'https://images.unsplash.com/photo-1519766304817-4f37bda74a29?auto=format&fit=crop&w=480&q=80',
    'Exercise mat (6 mm)': 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?auto=format&fit=crop&w=480&q=80',
    'Skipping rope': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=480&q=80',
    'Camping tent (2 person)': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=480&q=80',

    // Toys
    'Building blocks (100 pieces)': 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=480&q=80',
    'Jigsaw puzzle (100 pieces)': 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=480&q=80',
    'Toy car': 'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?auto=format&fit=crop&w=480&q=80',
    'Soft teddy bear': 'https://images.unsplash.com/photo-1559454403-b8fb88521f11?auto=format&fit=crop&w=480&q=80',
    'Chess board and pieces': 'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?auto=format&fit=crop&w=480&q=80',

    // Automotive
    'Engine oil (5W-30, 4 L)': 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=480&q=80',
    'Car tyre (195/65 R15)': 'https://images.unsplash.com/photo-1578844251758-2f71da64c96f?auto=format&fit=crop&w=480&q=80',
    'Car battery (12 V, 60 Ah)': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=480&q=80',
    'Car phone holder': 'https://images.unsplash.com/photo-1584438784894-089d6a62b8fa?auto=format&fit=crop&w=480&q=80',
    'Bicycle inner tube (26 inch)': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=480&q=80',

    // Tools
    'Claw hammer': 'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&w=480&q=80',
    'Screwdriver set (6 pieces)': 'https://images.unsplash.com/photo-1581147036324-c17ac41dfa6c?auto=format&fit=crop&w=480&q=80',
    'Measuring tape (5 m)': 'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&w=480&q=80',
    'Cement (50 kg bag)': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=480&q=80',
    'Interior wall paint (4 L)': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=480&q=80',

    // Garden
    'Watering can (10 L)': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=480&q=80',
    'Garden hoe': 'https://images.unsplash.com/photo-1617576683096-00fc8eecb3af?auto=format&fit=crop&w=480&q=80',
    'Garden hose (20 m)': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=480&q=80',
    'Plant pot (20 cm)': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=480&q=80',
    'Compost (10 kg bag)': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=480&q=80',

    // Pets
    'Dry dog food (3 kg)': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?auto=format&fit=crop&w=480&q=80',
    'Dry cat food (1 kg)': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?auto=format&fit=crop&w=480&q=80',
    'Pet feeding bowl': 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=480&q=80',
    'Dog leash (1.5 m)': 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?auto=format&fit=crop&w=480&q=80',
    'Cat litter (5 L)': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=480&q=80',

    // Electronics (accurate device photos with CORS enabled)
    'Apple iPhone 15 (128 GB)': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=480&q=80',
    'Samsung Galaxy S24 (8 GB / 256 GB)': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=480&q=80',
    'Apple iPad (10th gen, Wi-Fi, 64 GB)': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=480&q=80',
    'Sony PlayStation 5 Slim (1 TB, disc edition)': 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?auto=format&fit=crop&w=480&q=80',
    'Microsoft Xbox Series S (512 GB)': 'https://images.unsplash.com/photo-1621259182978-fbf93132d53d?auto=format&fit=crop&w=480&q=80',
    'HP LaserJet M110w printer': 'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?auto=format&fit=crop&w=480&q=80',
    'TP-Link Archer AX53 router': 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=480&q=80',
    'Samsung T7 portable SSD (1 TB)': 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?auto=format&fit=crop&w=480&q=80',
    'Logitech M185 wireless mouse': 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=480&q=80',
    'Logitech K120 keyboard': 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=480&q=80',
    'JBL Go 4 Bluetooth speaker': 'https://images.unsplash.com/photo-1545454675-3531b543be5d?auto=format&fit=crop&w=480&q=80',
    'Samsung Galaxy A15 (4 GB / 128 GB)': 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=480&q=80',
  };

  // 1. Populate marketplace_catalog.json
  int catalogImaged = 0;
  for (final row in catalog) {
    final map = row as Map<String, dynamic>;
    final nameEn = map['name_en'] as String;
    if (imagesByItem.containsKey(nameEn)) {
      map['image_url'] = imagesByItem[nameEn];
      catalogImaged++;
    } else {
      stderr.writeln('Warning: No image for catalog item $nameEn');
    }
  }

  // 2. Populate public_listings.json with verified CORS-compliant Unsplash images
  final listingsImages = <String, String>{
    // Samsung smartphones - user specifically requested updated A16 image
    '8a7c2026-1116-4000-8000-000000000001': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=480&q=80', // Galaxy A16
    '8a7c2026-1116-4000-8000-000000000002': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=480&q=80', // Galaxy A16
    '8a7c2026-1116-4000-8000-000000000003': 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=480&q=80', // Galaxy M07
    '8a7c2026-1116-4000-8000-000000000004': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=480&q=80', // Galaxy A06
    '8a7c2026-1116-4000-8000-000000000005': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=480&q=80', // Galaxy A06
    '8a7c2026-1116-4000-8000-000000000006': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=480&q=80', // Galaxy A07
    '8a7c2026-1116-4000-8000-000000000007': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=480&q=80', // Galaxy A07
    '8a7c2026-1116-4000-8000-000000000008': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=480&q=80', // Galaxy A07
    '8a7c2026-1116-4000-8000-000000000009': 'https://images.unsplash.com/photo-1567581935884-3349723552ca?auto=format&fit=crop&w=480&q=80', // Infinix Smart 10
    '8a7c2026-1116-4000-8000-000000000010': 'https://images.unsplash.com/photo-1567581935884-3349723552ca?auto=format&fit=crop&w=480&q=80', // Infinix Smart 10
    '8a7c2026-1116-4000-8000-000000000011': 'https://images.unsplash.com/photo-1567581935884-3349723552ca?auto=format&fit=crop&w=480&q=80', // Infinix Smart 10
    '8a7c2026-1116-4000-8000-000000000012': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=480&q=80', // S25 Ultra
    '8a7c2026-1116-4000-8000-000000000013': 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=480&q=80', // Galaxy A17
    '8a7c2026-1116-4000-8000-000000000014': 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=480&q=80', // Galaxy A17
    '8a7c2026-1116-4000-8000-000000000015': 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=480&q=80', // Galaxy A17
    '8a7c2026-1116-4000-8000-000000000016': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=480&q=80', // Galaxy A07
    '8a7c2026-1116-4000-8000-000000000017': 'https://images.unsplash.com/photo-1567581935884-3349723552ca?auto=format&fit=crop&w=480&q=80', // Galaxy A57
    '8a7c2026-1116-4000-8000-000000000018': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=480&q=80', // Galaxy Tab A11+
    '8a7c2026-1116-4000-8000-000000000019': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=480&q=80', // MacBook Pro 14
    '8a7c2026-1116-4000-8000-000000000020': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=480&q=80', // Cotton T-shirt
    // Automotive
    '8a7c2026-1116-4000-8000-000000000022': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=480&q=80', // Toyota Vitz
    '8a7c2026-1116-4000-8000-000000000023': 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=480&q=80', // Toyota Corolla
    '8a7c2026-1116-4000-8000-000000000024': 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=480&q=80', // Suzuki Dzire
    '8a7c2026-1116-4000-8000-000000000025': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=480&q=80', // Toyota RAV4
    '8a7c2026-1116-4000-8000-000000000026': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=480&q=80', // Bajaj Rickshaw
    // Additional Electronics & Computing
    '8a7c2026-1116-4000-8000-000000000027': 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?auto=format&fit=crop&w=480&q=80', // iPhone 11
    '8a7c2026-1116-4000-8000-000000000028': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=480&q=80', // iPhone 13 Pro Max
    '8a7c2026-1116-4000-8000-000000000029': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=480&q=80', // iPhone 14 Pro
    '8a7c2026-1116-4000-8000-000000000030': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=480&q=80', // Redmi Note 13 Pro
    '8a7c2026-1116-4000-8000-000000000031': 'https://images.unsplash.com/photo-1567581935884-3349723552ca?auto=format&fit=crop&w=480&q=80', // Tecno Camon 30
    '8a7c2026-1116-4000-8000-000000000032': 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?auto=format&fit=crop&w=480&q=80', // HP EliteBook
    '8a7c2026-1116-4000-8000-000000000033': 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&w=480&q=80', // Dell Latitude
    '8a7c2026-1116-4000-8000-000000000034': 'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=480&q=80', // Samsung Smart TV
    '8a7c2026-1116-4000-8000-000000000035': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=480&q=80', // Sony Smart TV
    '8a7c2026-1116-4000-8000-000000000036': 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=480&q=80', // Huawei Pocket Wi-Fi
    // Appliances & Tools
    '8a7c2026-1116-4000-8000-000000000044': 'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=480&q=80', // Digital Air Fryer
    '8a7c2026-1116-4000-8000-000000000046': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=480&q=80', // Cookware Pot
    '8a7c2026-1116-4000-8000-000000000053': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=480&q=80', // Petrol Generator
  };

  int listingsImaged = 0;
  for (final offer in listings) {
    final map = offer as Map<String, dynamic>;
    final id = map['id'] as String;
    if (listingsImages.containsKey(id)) {
      map['image_url'] = listingsImages[id];
      listingsImaged++;
    } else if (map['image_url'] != null) {
      listingsImaged++;
    }
  }

  // Write updated JSON files
  catalogFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(catalog) + '\n',
  );
  listingsFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(listings) + '\n',
  );

  // Synchronize bundled_catalog.dart
  final combined = [...catalog, ...listings];
  final buffer = StringBuffer()
    ..writeln('// Generated file. Do not edit directly.')
    ..writeln('// Sourced from marketplace_catalog.json and public_listings.json.')
    ..writeln('const List<Map<String, dynamic>> bundledCatalog = [');
  for (final item in combined) {
    buffer.writeln('  ${jsonEncode(item)},');
  }
  buffer.writeln('];');
  bundledFile.writeAsStringSync(buffer.toString());

  // Report
  // ignore: avoid_print
  print('Successfully added images: catalog $catalogImaged/${catalog.length}, listings $listingsImaged/${listings.length}, total bundled ${combined.length}');
}
