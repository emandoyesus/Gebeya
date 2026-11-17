import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'market_image.dart';

class PriceCard extends ConsumerWidget {
  final ItemModel item;
  final PriceAggregateModel? aggregate;

  const PriceCard({
    super.key,
    required this.item,
    required this.aggregate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final isDataSaver = ref.watch(dataSaverProvider);

    if (viewMode == ViewMode.grid && !isDataSaver && MediaQuery.textScalerOf(context).scale(14) <= 18) {
      return _KaloGridCard(item: item, aggregate: aggregate);
    }
    return _KaloListCard(item: item, aggregate: aggregate);
  }
}

/// Kalo Ultra-Sleek Dark 2-column Card
class _KaloGridCard extends ConsumerWidget {
  final ItemModel item;
  final PriceAggregateModel? aggregate;

  const _KaloGridCard({
    required this.item,
    required this.aggregate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);

    final median = aggregate?.medianPrice ?? item.listingPrice;
    final unit = item.localizedStandardUnit(isAmharic);
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));


    return InkWell(
      onTap: () => context.push('/item/${item.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16191E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF262C36), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Container with Badges
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: MarketImage(
                    category: item.category,
                    imageUrl: item.displayImageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: item.correctedImageUrl != null ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
                // Subtle gradient overlay for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          const Color(0xFF16191E).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Badges
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTelegram)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF59B0D7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded, size: 9, color: Color(0xFF0C0E12)),
                              SizedBox(width: 3),
                              Text(
                                'Telegram',
                                style: TextStyle(
                                  color: Color(0xFF0C0E12),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (aggregate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232A16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFB2D15A).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            isAmharic ? 'የገበያ ዋጋ' : 'REPORTED',
                            style: const TextStyle(
                              color: Color(0xFFB2D15A),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B250E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFD79C3A).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            isAmharic ? 'ሻጭ' : 'LISTING',
                            style: const TextStyle(
                              color: Color(0xFFD79C3A),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    tooltip: isAmharic
                        ? (isFavorite ? 'ከተቀመጡ አስወግድ' : 'እቃውን አስቀምጥ')
                        : (isFavorite ? 'Remove from saved' : 'Save item'),
                    onPressed: () => ref.read(favoritesProvider.notifier).toggle(item.id),
                    icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                    color: isFavorite ? const Color(0xFFF43F5E) : const Color(0xFFF8FAFC),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF0C0E12)),
                  ),
                ),
              ],
            ),

            // Card Body (Expanded to prevent any overflow)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Item Title & Price Block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.localizedName(isAmharic),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF8FAFC),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (median != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                median >= 1000000
                                    ? '${(median / 1000000).toStringAsFixed(1)}M'
                                    : median >= 100000
                                    ? '${(median / 1000).toStringAsFixed(0)}k'
                                    : median.toStringAsFixed(median.truncateToDouble() == median ? 0 : 1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB2D15A), // Neon lime
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'ETB/$unit',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8E9BAE),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            isAmharic ? 'ዋጋ ገና የለም' : 'Price pending',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9AA7B8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Location & Trend Indicator
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: Color(0xFF9AA7B8),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.sourceLocation ?? item.sourceLabel ?? (isAmharic ? 'አካባቢ አልተገለጸም' : 'Location not provided'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8E9BAE),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kalo Ultra-Sleek Dark List Item Card
class _KaloListCard extends ConsumerWidget {
  final ItemModel item;
  final PriceAggregateModel? aggregate;

  const _KaloListCard({
    required this.item,
    required this.aggregate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);

    final median = aggregate?.medianPrice ?? item.listingPrice;
    final unit = item.localizedStandardUnit(isAmharic);
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));


    return InkWell(
      onTap: () => context.push('/item/${item.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16191E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF262C36), width: 1),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 76,
                height: 76,
                child: MarketImage(
                  category: item.category,
                  imageUrl: item.displayImageUrl,
                  width: 76,
                  height: 76,
                  fit: item.correctedImageUrl != null ? BoxFit.contain : BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.localizedName(isAmharic),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isTelegram)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF59B0D7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Telegram', style: TextStyle(color: Color(0xFF0C0E12), fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF9AA7B8)),
                      const SizedBox(width: 3),
                      Text(
                        item.sourceLocation ?? item.sourceLabel ?? (isAmharic ? 'አካባቢ አልተገለጸም' : 'Location not provided'),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (median != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          median >= 1000000
                              ? '${(median / 1000000).toStringAsFixed(1)}M'
                              : '${median.toStringAsFixed(median.truncateToDouble() == median ? 0 : 1)} ETB',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB2D15A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/$unit',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Right Action & Trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: isAmharic ? (isFavorite ? 'ከተቀመጡ አስወግድ' : 'እቃውን አስቀምጥ') : (isFavorite ? 'Remove from saved' : 'Save item'),
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: isFavorite ? const Color(0xFFF43F5E) : const Color(0xFF9AA7B8),
                  ),
                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(item.id),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
