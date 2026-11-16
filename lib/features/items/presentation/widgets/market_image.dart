import 'package:flutter/material.dart';
import 'package:gebeya/core/constants/categories.dart';

/// Category and product photography.
/// Uses specific [imageUrl] if provided, or high-quality category photography.
class MarketImage extends StatelessWidget {
  final ItemCategory category;
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const MarketImage({
    super.key,
    this.category = ItemCategory.all,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final photo = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? imageUrl!.trim()
        : switch (category) {
            ItemCategory.grainsFlour => 'photo-1509440159596-0249088772ff',
            ItemCategory.vegetablesProduce => 'photo-1540420773420-3366772f4999',
            ItemCategory.pulsesLegumes => 'photo-1515543904379-3d757afe72e4',
            ItemCategory.meatDairy => 'photo-1563636619-e9143da7973b',
            ItemCategory.oilSugarPantry => 'photo-1474979266404-7eaacbcd87c5',
            ItemCategory.spices => 'photo-1596040033229-a9821ebd058d',
            ItemCategory.electronics => 'photo-1498049794561-7780e7231661',
            ItemCategory.clothing => 'photo-1489987707025-afc232f7ea0f',
            ItemCategory.all => 'photo-1542838132-92c53300491e',
            ItemCategory.bakery => 'photo-1509440159596-0249088772ff',
            ItemCategory.shoes => 'https://images.pexels.com/photos/6847398/pexels-photo-6847398.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.bags => 'https://images.pexels.com/photos/9630186/pexels-photo-9630186.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.beauty => 'https://images.pexels.com/photos/14438270/pexels-photo-14438270.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.health => 'https://images.pexels.com/photos/31837694/pexels-photo-31837694.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.baby => 'https://images.pexels.com/photos/3875080/pexels-photo-3875080.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.home => 'https://images.pexels.com/photos/19980199/pexels-photo-19980199.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.kitchen => 'https://images.pexels.com/photos/12181751/pexels-photo-12181751.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.appliances => 'https://images.pexels.com/photos/34772395/pexels-photo-34772395.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.cleaning => 'https://images.pexels.com/photos/7108400/pexels-photo-7108400.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.books => 'https://images.pexels.com/photos/5905439/pexels-photo-5905439.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.sports => 'https://images.pexels.com/photos/5184714/pexels-photo-5184714.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.toys => 'https://images.pexels.com/photos/32432135/pexels-photo-32432135.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.automotive => 'https://images.pexels.com/photos/20303832/pexels-photo-20303832.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.tools => 'https://images.pexels.com/photos/14534738/pexels-photo-14534738.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.garden => 'https://images.pexels.com/photos/6913411/pexels-photo-6913411.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.pets => 'https://images.pexels.com/photos/18764141/pexels-photo-18764141.jpeg?auto=compress&cs=tinysrgb&w=480',
            ItemCategory.beverages => 'https://images.pexels.com/photos/35982640/pexels-photo-35982640.jpeg?auto=compress&cs=tinysrgb&w=480',
          };
    final fallback = ColoredBox(
      color: const Color(0xFFE8EFE3),
      child: Center(
        child: Icon(
          category.icon,
          size: width < 60 ? 24 : 36,
          color: const Color(0xFF136A36),
        ),
      ),
    );

    final resolvedUrl = photo.startsWith('https://') || photo.startsWith('http://')
        ? photo
        : 'https://images.unsplash.com/$photo?auto=format&fit=crop&w=480&q=80';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          resolvedUrl,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          fit: fit,
          excludeFromSemantics: true,
          errorBuilder: (_, error, stack) => fallback,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : fallback,
        ),
      ),
    );
  }
}
