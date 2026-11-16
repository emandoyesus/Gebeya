import 'package:flutter/material.dart';

/// Stable IDs are shared by bundled catalogs and Supabase.
enum ItemCategory {
  all('all', 'All Items', 'ሁሉም', Icons.grid_view_rounded),
  electronics('electronics', 'Electronics', 'ኤሌክትሮኒክስ', Icons.devices_rounded),
  clothing('clothing', 'Clothes', 'ልብስ', Icons.checkroom_rounded),
  vegetablesProduce('vegetables_produce', 'Fruits & Vegetables', 'ፍራፍሬና አትክልት', Icons.eco_rounded),
  grainsFlour('grains_flour', 'Grains & Flour', 'እህልና ዱቄት', Icons.grain_rounded),
  pulsesLegumes('pulses_legumes', 'Pulses & Legumes', 'ጥራጥሬ', Icons.grass_rounded),
  meatDairy('meat_dairy', 'Meat, Fish & Dairy', 'ሥጋ፣ ዓሣና ወተት', Icons.restaurant_rounded),
  oilSugarPantry('oil_sugar_pantry', 'Oil & Pantry', 'ዘይትና የምግብ እቃዎች', Icons.kitchen_rounded),
  spices('spices', 'Spices & Seasonings', 'ቅመማ ቅመም', Icons.whatshot_rounded),
  beverages('beverages', 'Coffee, Tea & Drinks', 'ቡና፣ ሻይና መጠጦች', Icons.local_cafe_rounded),
  bakery('bakery', 'Bakery & Snacks', 'ዳቦና መክሰስ', Icons.bakery_dining_rounded),
  shoes('shoes', 'Shoes & Footwear', 'ጫማዎች', Icons.hiking_rounded),
  bags('bags', 'Bags & Accessories', 'ቦርሳና መለዋወጫዎች', Icons.work_outline_rounded),
  beauty('beauty', 'Beauty & Personal Care', 'ውበትና የግል እንክብካቤ', Icons.spa_rounded),
  health('health', 'Health & Wellness', 'ጤናና ደህንነት', Icons.health_and_safety_rounded),
  baby('baby', 'Baby & Maternity', 'የሕፃናትና የእናቶች እቃዎች', Icons.child_care_rounded),
  home('home', 'Furniture & Home', 'የቤት እቃዎች', Icons.chair_rounded),
  kitchen('kitchen', 'Kitchen & Dining', 'የወጥ ቤት እቃዎች', Icons.flatware_rounded),
  appliances('appliances', 'Home Appliances', 'የቤት ኤሌክትሪክ እቃዎች', Icons.local_laundry_service_rounded),
  cleaning('cleaning', 'Cleaning & Household', 'የጽዳት እቃዎች', Icons.cleaning_services_rounded),
  books('books', 'Books & Stationery', 'መጻሕፍትና የጽሕፈት መሣሪያዎች', Icons.menu_book_rounded),
  sports('sports', 'Sports & Outdoors', 'ስፖርትና የውጭ እንቅስቃሴ', Icons.sports_soccer_rounded),
  toys('toys', 'Toys & Games', 'መጫወቻዎችና ጨዋታዎች', Icons.toys_rounded),
  automotive('automotive', 'Automotive & Transport', 'የመኪናና የትራንስፖርት እቃዎች', Icons.directions_car_rounded),
  tools('tools', 'Tools & Building', 'መሣሪያዎችና የግንባታ እቃዎች', Icons.handyman_rounded),
  garden('garden', 'Garden & Agriculture', 'አትክልት ስፍራና ግብርና', Icons.agriculture_rounded),
  pets('pets', 'Pet Supplies', 'የቤት እንስሳት እቃዎች', Icons.pets_rounded);

  const ItemCategory(this.id, this.labelEn, this.labelAm, this.icon);
  final String id;
  final String labelEn;
  final String labelAm;
  final IconData icon;
}

extension ItemCategoryExtension on ItemCategory {
  String nameEn(BuildContext context) => labelEn;
  String nameAm(BuildContext context) => labelAm;

  static ItemCategory fromString(String str) {
    final id = str.trim().toLowerCase();
    return ItemCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => ItemCategory.all,
    );
  }
}
