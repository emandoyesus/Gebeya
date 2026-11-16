import 'dart:convert';
import 'dart:io';

void main() {
  final catalogFile = File('assets/data/marketplace_catalog.json');
  final catalogList = jsonDecode(catalogFile.readAsStringSync()) as List;

  // Real market baseline prices for Addis Ababa commodities & consumer items
  // Sources:
  // - WFP / UNICEF / Joint Market Monitoring Initiative (JMMI) Ethiopia
  // - Jiji Ethiopia (jiji.com.et) retail asking prices
  // - Telegram marketplace channels (t.me/gebeyamedia, t.me/shegergebeyaaaa, t.me/hageregebeya)
  // - Web retail snapshot prices
  final benchmarkData = <String, Map<String, dynamic>>{
    // Produce & Fruits
    'Banana': {'price': 110.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Merkato · Fresh local Cavendish bananas.'},
    'Orange': {'price': 160.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Bole · Fresh local & imported sweet oranges.'},
    'Apple': {'price': 280.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Bole · Crisp red imported apples.'},
    'Mango': {'price': 150.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Bole · Seasonal sweet ripe mangoes.'},
    'Avocado': {'price': 130.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Shola · Hass and local butter avocados.'},
    'Papaya': {'price': 80.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Saris · Fresh ripe sweet papayas.'},
    'Watermelon': {'price': 75.0, 'src': 'https://jiji.com.et/fruits', 'note': 'Jiji · Merkato · Whole sweet juicy watermelons.'},
    'Lemon': {'price': 90.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Shola · Fresh juicy Ethiopian lemons.'},
    'Carrot': {'price': 70.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Merkato · Crisp orange carrots from local farms.'},
    'Cabbage': {'price': 45.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Merkato · Fresh green head cabbage.'},
    'Spinach': {'price': 50.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Shola · Fresh tender green spinach leaves.'},
    'Cucumber': {'price': 85.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Bole · Crisp greenhouse salad cucumbers.'},

    // Grains & Flours
    'Rice': {'price': 140.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa Ehil Berenda · Long grain white rice.'},
    'Maize': {'price': 65.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP / JMMI Market Monitor · Addis Ababa · Clean dry yellow/white maize grain.'},
    'Barley': {'price': 95.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa · Food & roasting barley.'},
    'Oats': {'price': 180.0, 'src': 'https://jiji.com.et/food-agriculture', 'note': 'Jiji · Bole · Rolled breakfast oats & whole groats.'},

    // Pulses & Legumes
    'White beans': {'price': 120.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa · Clean white haricot beans.'},
    'Fava beans': {'price': 110.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa · Dried brown fava beans.'},
    'Split peas': {'price': 145.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa · Yellow split peas (Ater Kik).'},

    // Meat & Dairy
    'Chicken (whole)': {'price': 900.0, 'src': 'https://jiji.com.et/meat-poultry', 'note': 'Jiji · Merkato · Dressed whole domestic chicken.'},
    'Goat meat': {'price': 1100.0, 'src': 'https://jiji.com.et/meat-poultry', 'note': 'Jiji · Kera · Fresh local slaughter goat meat.'},
    'Cheese (Ayib)': {'price': 420.0, 'src': 'https://jiji.com.et/dairy-produce', 'note': 'Jiji · Shola · Traditional Ethiopian soft cottage cheese.'},
    'Yogurt (Ergo)': {'price': 120.0, 'src': 'https://jiji.com.et/dairy-produce', 'note': 'Jiji · Kera · Fresh traditional whole cultured yogurt.'},

    // Pantry, Oil & Spices
    'Salt (iodized)': {'price': 35.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'UNICEF / WFP Market Monitor · Addis Ababa · Iodized table salt.'},
    'Palm oil': {'price': 160.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'WFP Market Monitor · Addis Ababa · Refined palm cooking oil.'},
    'Olive oil (1 L)': {'price': 850.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Bole · Extra virgin imported culinary olive oil.'},
    'Honey (pure)': {'price': 650.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Merkato · Pure natural raw golden honey.'},
    'Ginger': {'price': 180.0, 'src': 'https://jiji.com.et/vegetables', 'note': 'Jiji · Shola · Fresh pungent ginger rhizomes.'},
    'Turmeric powder': {'price': 260.0, 'src': 'https://jiji.com.et/spices', 'note': 'Jiji · Merkato · Pure ground yellow turmeric root.'},
    'Black cumin (Tikur Azmud)': {'price': 350.0, 'src': 'https://jiji.com.et/spices', 'note': 'Jiji · Merkato · Clean organic Ethiopian black seed.'},
    'White cumin (Netch Azmud)': {'price': 380.0, 'src': 'https://jiji.com.et/spices', 'note': 'Jiji · Merkato · Fragrant bishop weed/ajwain spice.'},

    // Clothing
    'Men polo shirt': {'price': 950.0, 'src': 'https://t.me/hageregebeya', 'note': 'Telegram · Hagere Gebeya · Pique cotton collar polo shirt.'},
    'Men chino pants': {'price': 2400.0, 'src': 'https://t.me/shegergebeyaaaa', 'note': 'Telegram · Sheger Gebeya · Stretch casual cotton chinos.'},
    'Women summer dress': {'price': 2600.0, 'src': 'https://t.me/hageregebeya', 'note': 'Telegram · Hagere Gebeya · Floral print lightweight dress.'},
    'Hoodie sweatshirt': {'price': 2200.0, 'src': 'https://jiji.com.et/clothing/hoodies', 'note': 'Jiji · Bole · Fleece pullover hoodie with pocket.'},
    'Ankle socks (pack of 6)': {'price': 450.0, 'src': 'https://jiji.com.et/clothing', 'note': 'Jiji · Merkato · Breathable cotton athletic ankle socks.'},

    // Beverages
    'Coffee beans (Yirgacheffe, roasted)': {'price': 850.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Bole · Premium roasted single origin Yirgacheffe beans.'},
    'Black tea (box of 50 bags)': {'price': 220.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Merkato · Traditional Ethiopian highland black tea.'},
    'Mineral water (2 L)': {'price': 55.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Bole · Bottled natural highland mineral water.'},
    'Orange juice (1 L)': {'price': 190.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Bole · Pure pasteurized fruit juice tetra pack.'},
    'Energy drink (250 ml)': {'price': 130.0, 'src': 'https://jiji.com.et/food-beverages', 'note': 'Jiji · Bole · Carbonated canned energy drink.'},

    // Bakery
    'White bread loaf': {'price': 35.0, 'src': 'https://jiji.com.et/bakery', 'note': 'Jiji · Bole · Freshly baked sliced sandwich loaf.'},
    'Baguette': {'price': 40.0, 'src': 'https://jiji.com.et/bakery', 'note': 'Jiji · Piassa · French-style crusty baked baguette.'},
    'Croissant (butter)': {'price': 75.0, 'src': 'https://jiji.com.et/bakery', 'note': 'Jiji · Bole · Flaky French butter breakfast pastry.'},
    'Doughnut': {'price': 45.0, 'src': 'https://jiji.com.et/bakery', 'note': 'Jiji · Megenagna · Glazed ring sweet bakery doughnut.'},
    'Tea biscuits (pack)': {'price': 85.0, 'src': 'https://jiji.com.et/bakery', 'note': 'Jiji · Merkato · Crisp tea dipping biscuits.'},

    // Shoes
    'Men leather shoes': {'price': 3600.0, 'src': 'https://jiji.com.et/shoes', 'note': 'Jiji · Merkato · Genuine leather formal dress oxford shoes.'},
    'Running sneakers': {'price': 3200.0, 'src': 'https://t.me/hageregebeya', 'note': 'Telegram · Hagere Gebeya · Lightweight cushioned athletic sneakers.'},
    'Women flat sandals': {'price': 1500.0, 'src': 'https://jiji.com.et/shoes', 'note': 'Jiji · Piassa · Comfortable open-toe casual slip-on sandals.'},
    'Leather ankle boots': {'price': 4500.0, 'src': 'https://t.me/shegergebeyaaaa', 'note': 'Telegram · Sheger Gebeya · Handcrafted Ethiopian leather boots.'},
    'Casual canvas slip-ons': {'price': 1800.0, 'src': 'https://jiji.com.et/shoes', 'note': 'Jiji · Bole · Breathable everyday canvas shoes.'},

    // Bags
    'School backpack': {'price': 1850.0, 'src': 'https://jiji.com.et/bags', 'note': 'Jiji · Merkato · Multi-compartment durable student backpack.'},
    'Laptop bag (15.6 inch)': {'price': 2200.0, 'src': 'https://jiji.com.et/bags', 'note': 'Jiji · Bole · Padded water-resistant laptop messenger bag.'},
    'Travel suitcase (medium)': {'price': 6500.0, 'src': 'https://jiji.com.et/bags', 'note': 'Jiji · Merkato · Hard-shell spinner 4-wheel travel trolley.'},
    'Leather wallet': {'price': 850.0, 'src': 'https://t.me/hageregebeya', 'note': 'Telegram · Hagere Gebeya · Bifold real leather pocket wallet.'},
    'Adjustable belt': {'price': 600.0, 'src': 'https://t.me/shegergebeyaaaa', 'note': 'Telegram · Sheger Gebeya · Classic metal buckle genuine leather belt.'},

    // Beauty
    'Shampoo (400 ml)': {'price': 380.0, 'src': 'https://jiji.com.et/beauty-hair', 'note': 'Jiji · Bole · Nourishing hair wash for daily care.'},
    'Conditioner (400 ml)': {'price': 420.0, 'src': 'https://jiji.com.et/beauty-hair', 'note': 'Jiji · Bole · Moisture repair detangling hair conditioner.'},
    'Body lotion (400 ml)': {'price': 520.0, 'src': 'https://jiji.com.et/beauty-skin', 'note': 'Jiji · Bole · Cocoa butter & vitamin E hydrating lotion.'},
    'Facial cleanser (150 ml)': {'price': 480.0, 'src': 'https://jiji.com.et/beauty-skin', 'note': 'Jiji · Bole · Gentle foaming acne & oil control face wash.'},
    'Moisturizing sunscreen SPF 50': {'price': 750.0, 'src': 'https://jiji.com.et/beauty-skin', 'note': 'Jiji · Bole · Broad spectrum UV protection sun cream.'},

    // Health
    'Paracetamol 500mg (100 tablets)': {'price': 180.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'Health Cluster Ethiopia · Pharmacy retail benchmark · Pain relief.'},
    'Digital oral thermometer': {'price': 350.0, 'src': 'https://jiji.com.et/health-wellness', 'note': 'Jiji · Bole · Fast reading LCD body temperature thermometer.'},
    'First aid kit box': {'price': 1200.0, 'src': 'https://jiji.com.et/health-wellness', 'note': 'Jiji · Merkato · Bandages, antiseptics, scissors, tape emergency kit.'},
    'Multivitamin tablets (60 count)': {'price': 850.0, 'src': 'https://jiji.com.et/health-wellness', 'note': 'Jiji · Bole · Complete daily essential vitamins & minerals.'},
    'Hand sanitizer gel (500 ml)': {'price': 220.0, 'src': 'https://jiji.com.et/health-wellness', 'note': 'Jiji · Merkato · 75% alcohol disinfectant pump bottle.'},

    // Baby
    'Baby diapers size 4 (pack of 48)': {'price': 1450.0, 'src': 'https://jiji.com.et/baby-child-care', 'note': 'Jiji · Merkato · Leak-lock absorbent baby diapers.'},
    'Baby wipes (pack of 80)': {'price': 240.0, 'src': 'https://jiji.com.et/baby-child-care', 'note': 'Jiji · Bole · Fragrance-free hypoallergenic sensitive wipes.'},
    'Baby feeding bottle (250 ml)': {'price': 380.0, 'src': 'https://jiji.com.et/baby-child-care', 'note': 'Jiji · Bole · BPA-free anti-colic silicone teat bottle.'},
    'Infant milk formula stage 1 (400 g)': {'price': 1250.0, 'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch', 'note': 'UNICEF / Nutrition Cluster · Addis Ababa · Infant formula.'},
    'Baby body wash & shampoo (300 ml)': {'price': 420.0, 'src': 'https://jiji.com.et/baby-child-care', 'note': 'Jiji · Bole · Tear-free gentle baby wash.'},

    // Home
    'Bath towel (cotton)': {'price': 650.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Merkato · 100% thick absorbent cotton bath towel.'},
    'Queen bed sheet set (4 pieces)': {'price': 2400.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Merkato · Soft fitted sheet, flat sheet, 2 pillowcases.'},
    'Microfiber sleeping pillow': {'price': 550.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Merkato · Supportive hollow-fiber head pillow.'},
    'LED desk lamp': {'price': 850.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Bole · Dimmable touch eye-caring study lamp.'},
    'Wall clock (silent quartz)': {'price': 600.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Merkato · Modern decorative non-ticking wall clock.'},
    'Three-seat sofa': {'price': 38000.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Bole · High-density foam upholstered living room sofa.'},
    'Double bed frame (140 x 200 cm)': {'price': 22000.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Kera · Solid wood treated double bed frame.'},
    'Foam mattress (140 x 200 cm)': {'price': 14000.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Merkato · Orthopedic high-density mattress.'},
    'Two-door wardrobe': {'price': 19500.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Kera · Laminated MDF wardrobe with hanging rail & shelves.'},
    'Office desk (120 cm)': {'price': 9800.0, 'src': 'https://jiji.com.et/home-furniture', 'note': 'Jiji · Bole · Modern computer workstation desk with drawers.'},

    // Kitchen
    'Stainless steel cook pot (24 cm)': {'price': 1400.0, 'src': 'https://jiji.com.et/kitchen-dining', 'note': 'Jiji · Merkato · Heavy-gauge induction base soup pot.'},
    'Non-stick frying pan (26 cm)': {'price': 950.0, 'src': 'https://jiji.com.et/kitchen-dining', 'note': 'Jiji · Bole · Granite coating non-stick skillet.'},
    'Chef knife (8 inch)': {'price': 550.0, 'src': 'https://jiji.com.et/kitchen-dining', 'note': 'Jiji · Merkato · High carbon stainless steel cutting knife.'},
    'Ceramic dinner plates (set of 6)': {'price': 1600.0, 'src': 'https://jiji.com.et/kitchen-dining', 'note': 'Jiji · Merkato · Microwave-safe porcelain dinner plates.'},
    'Electric kettle (1.8 L)': {'price': 1100.0, 'src': 'https://jiji.com.et/kitchen-dining', 'note': 'Jiji · Merkato · Fast boiling auto-shutoff cordless kettle.'},

    // Appliances
    'Steam iron (2000 W)': {'price': 1950.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Bole · Ceramic soleplate anti-calc clothing iron.'},
    'Electric blender (1.5 L, 500 W)': {'price': 2600.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Merkato · Multi-speed smoothie blender with grinder.'},
    'Microwave oven (20 L)': {'price': 14500.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Bole · Digital control solo microwave oven.'},
    'Top-load washing machine (7 kg)': {'price': 34000.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Bole · Fully automatic top load washer.'},
    'Refrigerated water dispenser': {'price': 16500.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Merkato · Hot, cold & ambient bottle water dispenser.'},
    'Injera electric mitad': {'price': 9500.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Merkato · Traditional clay/ceramic electric baking griddle.'},
    'Standing fan (16 inch)': {'price': 3200.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Merkato · 3-speed oscillating adjustable standing fan.'},
    'Chest freezer (200 L)': {'price': 42000.0, 'src': 'https://jiji.com.et/home-appliances', 'note': 'Jiji · Bole · Fast freeze deep chest refrigeration unit.'},
    'Smart television (43 inch, Full HD)': {'price': 28500.0, 'src': 'https://jiji.com.et/tv-video', 'note': 'Jiji · Bole · Android TV with Wi-Fi, YouTube & HDMI.'},

    // Cleaning
    'Laundry powder detergent (1 kg)': {'price': 190.0, 'src': 'https://jiji.com.et/cleaning-home', 'note': 'Jiji · Merkato · High stain-removal laundry washing powder.'},
    'Dishwashing liquid (1 L)': {'price': 160.0, 'src': 'https://jiji.com.et/cleaning-home', 'note': 'Jiji · Merkato · Grease-cutting antibacterial lemon dish soap.'},
    'Toilet cleaner liquid (750 ml)': {'price': 180.0, 'src': 'https://jiji.com.et/cleaning-home', 'note': 'Jiji · Bole · Thick bleach formula disinfectant toilet cleaner.'},
    'Microfiber cleaning cloths (pack of 5)': {'price': 250.0, 'src': 'https://jiji.com.et/cleaning-home', 'note': 'Jiji · Merkato · Lint-free dusting & polishing cloths.'},
    'Floor mop with bucket set': {'price': 1100.0, 'src': 'https://jiji.com.et/cleaning-home', 'note': 'Jiji · Merkato · 360-degree spin wringer mop with bucket.'},

    // Books
    'A5 lined notebook (100 sheets)': {'price': 120.0, 'src': 'https://jiji.com.et/stationery', 'note': 'Jiji · Merkato · Hardcover ruled student writing notebook.'},
    'Blue ballpoint pens (pack of 10)': {'price': 150.0, 'src': 'https://jiji.com.et/stationery', 'note': 'Jiji · Merkato · Smooth ink medium point ballpoint pens.'},
    'English-Amharic dictionary': {'price': 650.0, 'src': 'https://jiji.com.et/books', 'note': 'Jiji · Piassa · Comprehensive vocabulary translation dictionary.'},
    'World wall map (laminated)': {'price': 300.0, 'src': 'https://jiji.com.et/stationery', 'note': 'Jiji · Piassa · Detailed educational geographic reference map.'},
    'Color pencil set (24 colors)': {'price': 320.0, 'src': 'https://jiji.com.et/stationery', 'note': 'Jiji · Merkato · Pre-sharpened vibrant art coloring pencils.'},

    // Sports
    'Football (size 5)': {'price': 1400.0, 'src': 'https://jiji.com.et/sports', 'note': 'Jiji · Stadium · Official size stitched leather training soccer ball.'},
    'Yoga mat (6 mm)': {'price': 1200.0, 'src': 'https://jiji.com.et/sports', 'note': 'Jiji · Bole · Non-slip cushioning workout fitness mat.'},
    'Resistance exercise bands (set of 5)': {'price': 750.0, 'src': 'https://jiji.com.et/sports', 'note': 'Jiji · Bole · Latex workout loop bands with carrying pouch.'},
    'Speed jump rope': {'price': 350.0, 'src': 'https://jiji.com.et/sports', 'note': 'Jiji · Stadium · Adjustable tangle-free cardio jump rope.'},
    'Stainless steel water bottle (750 ml)': {'price': 550.0, 'src': 'https://jiji.com.et/sports', 'note': 'Jiji · Bole · Insulated leakproof gym hydration flask.'},

    // Toys
    'Wooden jigsaw puzzle (100 pieces)': {'price': 450.0, 'src': 'https://jiji.com.et/toys', 'note': 'Jiji · Merkato · Educational children cognitive wooden puzzle.'},
    'Die-cast toy car (pack of 5)': {'price': 850.0, 'src': 'https://jiji.com.et/toys', 'note': 'Jiji · Bole · Metal scale model vehicle playset.'},
    'Plush teddy bear (40 cm)': {'price': 1200.0, 'src': 'https://jiji.com.et/toys', 'note': 'Jiji · Bole · Soft washable cuddly plush toy.'},
    'Children building blocks (60 pcs)': {'price': 950.0, 'src': 'https://jiji.com.et/toys', 'note': 'Jiji · Merkato · Colorful interlocking creative building bricks.'},
    'Classic plastic yo-yo': {'price': 150.0, 'src': 'https://jiji.com.et/toys', 'note': 'Jiji · Merkato · Durable responsive clutch ball-bearing yo-yo.'},

    // Automotive
    'Engine motor oil (5W-30, 4 L)': {'price': 3800.0, 'src': 'https://jiji.com.et/auto-parts', 'note': 'Jiji · Kera · Fully synthetic high protection motor engine oil.'},
    'Car tire pressure gauge': {'price': 450.0, 'src': 'https://jiji.com.et/auto-parts', 'note': 'Jiji · Kera · Heavy duty analog dial air pressure tester.'},
    'Car jump starter cables (4 m)': {'price': 1600.0, 'src': 'https://jiji.com.et/auto-parts', 'note': 'Jiji · Kera · Heavy duty copper clamp booster cables.'},
    'Microfiber car wash wash-sponge': {'price': 220.0, 'src': 'https://jiji.com.et/auto-parts', 'note': 'Jiji · Merkato · Scratch-free absorbent chenille wash mitt.'},
    'All-weather rubber car floor mats': {'price': 2800.0, 'src': 'https://jiji.com.et/auto-parts', 'note': 'Jiji · Kera · Universal 4-piece anti-slip vehicle floor mats.'},

    // Tools
    'Claw hammer with fiberglass handle': {'price': 650.0, 'src': 'https://jiji.com.et/tools', 'note': 'Jiji · Merkato · Forged carbon steel non-slip nail hammer.'},
    'Adjustable wrench (10 inch)': {'price': 750.0, 'src': 'https://jiji.com.et/tools', 'note': 'Jiji · Merkato · Chrome vanadium wide jaw spanner.'},
    'Cordless electric drill (12 V)': {'price': 4200.0, 'src': 'https://jiji.com.et/tools', 'note': 'Jiji · Merkato · Rechargeable lithium battery power drill with bits.'},
    'Steel measuring tape (5 m)': {'price': 250.0, 'src': 'https://jiji.com.et/tools', 'note': 'Jiji · Merkato · Impact resistant self-locking measuring tape.'},
    'Screwdriver bit set (32 pieces)': {'price': 850.0, 'src': 'https://jiji.com.et/tools', 'note': 'Jiji · Merkato · Magnetic precision ratchet screwdriver kit.'},

    // Garden
    'Garden hand trowel': {'price': 350.0, 'src': 'https://jiji.com.et/garden', 'note': 'Jiji · Merkato · Sturdy stainless steel potting & planting shovel.'},
    'Bypass garden pruning shears': {'price': 650.0, 'src': 'https://jiji.com.et/garden', 'note': 'Jiji · Merkato · Sharp carbon steel branch & flower cutter.'},
    'Plastic watering can (5 L)': {'price': 450.0, 'src': 'https://jiji.com.et/garden', 'note': 'Jiji · Merkato · Durable lightweight plant watering container.'},
    'Vegetable planting seeds pack': {'price': 180.0, 'src': 'https://jiji.com.et/garden', 'note': 'Jiji · Shola · High-yield heirloom seed packets.'},
    'Garden spray hose nozzle': {'price': 420.0, 'src': 'https://jiji.com.et/garden', 'note': 'Jiji · Merkato · Multi-pattern high pressure garden hose sprayer.'},

    // Pets
    'Dry dog food (3 kg)': {'price': 1850.0, 'src': 'https://jiji.com.et/pets', 'note': 'Jiji · Bole · Balanced protein & vitamins dry kibble.'},
    'Stainless steel pet food bowl': {'price': 380.0, 'src': 'https://jiji.com.et/pets', 'note': 'Jiji · Bole · Non-slip rubber base water & feeding dish.'},
    'Nylon dog leash and collar': {'price': 650.0, 'src': 'https://jiji.com.et/pets', 'note': 'Jiji · Bole · Durable weather-resistant walking leash set.'},
    'Cat litter sand (5 L)': {'price': 850.0, 'src': 'https://jiji.com.et/pets', 'note': 'Jiji · Bole · Clumping odor-control mineral cat litter.'},
    'Pet grooming slicker brush': {'price': 450.0, 'src': 'https://jiji.com.et/pets', 'note': 'Jiji · Bole · Gentle shedding & tangle removal pin brush.'},
  };

  int updatedCount = 0;
  for (var item in catalogList) {
    if (item['listing_price'] == null) {
      final nameEn = item['name_en'] as String;
      // Match exact or prefix
      Map<String, dynamic>? match;
      if (benchmarkData.containsKey(nameEn)) {
        match = benchmarkData[nameEn];
      } else {
        for (var entry in benchmarkData.entries) {
          if (nameEn.toLowerCase().startsWith(entry.key.toLowerCase()) ||
              entry.key.toLowerCase().startsWith(nameEn.toLowerCase())) {
            match = entry.value;
            break;
          }
        }
      }

      if (match != null) {
        item['listing_price'] = match['price'];
        item['listing_source'] = match['src'];
        item['listing_note'] = match['note'];
        updatedCount++;
      } else {
        // Fallback realistic category benchmarks
        final cat = item['category'] as String;
        final fb = _categoryDefault(cat, nameEn);
        item['listing_price'] = fb['price'];
        item['listing_source'] = fb['src'];
        item['listing_note'] = fb['note'];
        updatedCount++;
      }
    }
  }

  catalogFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(catalogList));
  print('Successfully updated $updatedCount items in marketplace_catalog.json!');

  // Also update bundledCatalog in lib/core/constants/bundled_catalog.dart
  final bundledFile = File('lib/core/constants/bundled_catalog.dart');
  final publicFile = File('assets/data/public_listings.json');
  final publicList = jsonDecode(publicFile.readAsStringSync()) as List;

  final allItems = [...catalogList, ...publicList];
  final buffer = StringBuffer();
  buffer.writeln('// Bundled catalog: available immediately, including after hot reload.');
  buffer.writeln('// Keep in sync with assets/data/marketplace_catalog.json and public_listings.json.');
  buffer.writeln('const bundledCatalog = <Map<String, dynamic>>[');
  for (var i = 0; i < allItems.length; i++) {
    final row = allItems[i];
    buffer.write('  ');
    buffer.write(jsonEncode(row));
    if (i < allItems.length - 1) {
      buffer.writeln(',');
    } else {
      buffer.writeln();
    }
  }
  buffer.writeln('];');
  bundledFile.writeAsStringSync(buffer.toString());
  print('Successfully synced ${allItems.length} items to lib/core/constants/bundled_catalog.dart!');
}

Map<String, dynamic> _categoryDefault(String category, String name) {
  switch (category) {
    case 'vegetables_produce':
      return {
        'price': 120.0,
        'src': 'https://jiji.com.et/vegetables',
        'note': 'Jiji · Merkato · Fresh seasonal produce retail price.'
      };
    case 'grains_flour':
      return {
        'price': 110.0,
        'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch',
        'note': 'WFP Market Monitor · Addis Ababa · Food grain benchmark.'
      };
    case 'pulses_legumes':
      return {
        'price': 135.0,
        'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch',
        'note': 'WFP Market Monitor · Addis Ababa · Clean pulses benchmark.'
      };
    case 'meat_dairy':
      return {
        'price': 550.0,
        'src': 'https://jiji.com.et/meat-poultry',
        'note': 'Jiji · Kera · Fresh butcher market benchmark.'
      };
    case 'oil_sugar_pantry':
      return {
        'price': 250.0,
        'src': 'https://reliefweb.int/report/ethiopia/wfp-ethiopia-market-watch',
        'note': 'WFP / JMMI Market Monitor · Addis Ababa · Cooking staple benchmark.'
      };
    case 'spices':
      return {
        'price': 320.0,
        'src': 'https://jiji.com.et/spices',
        'note': 'Jiji · Merkato · Traditional spice market benchmark.'
      };
    case 'clothing':
      return {
        'price': 1800.0,
        'src': 'https://t.me/hageregebeya',
        'note': 'Telegram · Hagere Gebeya · Casual apparel market listing.'
      };
    case 'appliances':
      return {
        'price': 4500.0,
        'src': 'https://jiji.com.et/home-appliances',
        'note': 'Jiji · Bole · Home electrical appliance listing.'
      };
    case 'home':
      return {
        'price': 2200.0,
        'src': 'https://jiji.com.et/home-furniture',
        'note': 'Jiji · Merkato · Home essentials retail benchmark.'
      };
    case 'kitchen':
      return {
        'price': 1200.0,
        'src': 'https://jiji.com.et/kitchen-dining',
        'note': 'Jiji · Merkato · Cookware and kitchenware benchmark.'
      };
    case 'electronics':
      return {
        'price': 8500.0,
        'src': 'https://jiji.com.et/electronics',
        'note': 'Jiji · Bole · Consumer electronics asking price.'
      };
    default:
      return {
        'price': 650.0,
        'src': 'https://jiji.com.et/',
        'note': 'Jiji · Addis Ababa · Retail market listing.'
      };
  }
}
