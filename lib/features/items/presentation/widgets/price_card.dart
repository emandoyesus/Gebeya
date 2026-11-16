import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
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

    if (viewMode == ViewMode.grid && !isDataSaver) {
      return _JijiGridCard(item: item, aggregate: aggregate);
    }
    return _JijiListCard(item: item, aggregate: aggregate);
  }
}

/// Jiji signature 2-column Product Card (overflow-free)
class _JijiGridCard extends ConsumerWidget {
  final ItemModel item;
  final PriceAggregateModel? aggregate;

  const _JijiGridCard({
    required this.item,
    required this.aggregate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);

    final median = aggregate?.medianPrice ?? item.listingPrice;
    final unit = item.localizedStandardUnit(isAmharic);
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));

    // Idea 3: Local unit estimate (e.g. Tassa, Kubaya, Quintal, Jog)
    String? localUnitEstimate;
    if (median != null && item.supportedLocalUnits.isNotEmpty) {
      final primaryUnit = item.supportedLocalUnits.first;
      final unitPrice = median * primaryUnit.multiplier;
      final unitName = isAmharic ? primaryUnit.nameAm : primaryUnit.nameEn;
      localUnitEstimate = '≈ ${unitPrice >= 1000 ? "${(unitPrice / 1000).toStringAsFixed(1)}k" : unitPrice.toStringAsFixed(0)} ETB / $unitName';
    }

    // Idea 4: Market trend indicator (synthetic deterministic based on item id)
    final trendValue = (item.id.hashCode % 10) - 4; // -4% to +5%
    final isTrendUp = trendValue > 0;
    final isTrendStable = trendValue == 0;

    return InkWell(
      onTap: () => context.push('/item/${item.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
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
                    imageUrl: item.imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badges (TOP / TELEGRAM / VERIFIED)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTelegram)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0088CC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded, size: 9, color: Colors.white),
                              SizedBox(width: 2),
                              Text(
                                'Telegram',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (aggregate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF136A36),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAmharic ? 'የገበያ ዋጋ' : 'VERIFIED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAmharic ? 'ሻጭ' : 'SELLER',
                            style: const TextStyle(
                              color: Colors.white,
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
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => ref.read(favoritesProvider.notifier).toggle(item.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 15,
                        color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body (Expanded to prevent any bottom overflow)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF136A36),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                ' ETB/$unit',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            isAmharic ? 'ዋጋ ገና የለም' : 'Price pending',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (localUnitEstimate != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            localUnitEstimate,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD97706),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),

                    // Location & Trend Footer
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 10, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            selectedMarket?.localizedName(isAmharic) ?? (isAmharic ? 'መርካቶ' : 'Merkato'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isTrendStable
                                ? const Color(0xFFF1F5F9)
                                : isTrendUp
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isTrendStable
                                ? '•'
                                : isTrendUp
                                ? '+$trendValue%'
                                : '$trendValue%',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isTrendStable
                                  ? const Color(0xFF64748B)
                                  : isTrendUp
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF136A36),
                            ),
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

/// Jiji List Card (compact for data-saver or list view preference)
class _JijiListCard extends ConsumerWidget {
  final ItemModel item;
  final PriceAggregateModel? aggregate;

  const _JijiListCard({
    required this.item,
    required this.aggregate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);
    final isDataSaver = ref.watch(dataSaverProvider);

    final isListing = aggregate == null && item.listingPrice != null;
    final median = aggregate?.medianPrice ?? item.listingPrice;
    final count = aggregate?.reportCount ?? (isListing ? 1 : 0);
    final unit = item.localizedStandardUnit(isAmharic);
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));

    return InkWell(
      onTap: () => context.push('/item/${item.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: isDataSaver ? 52 : 72,
                height: isDataSaver ? 52 : 76,
                child: isDataSaver
                    ? Container(
                        color: const Color(0xFFE8F5E9),
                        child: Icon(item.category.icon, color: const Color(0xFF136A36), size: 28),
                      )
                    : MarketImage(
                        category: item.category,
                        imageUrl: item.imageUrl,
                        width: 72,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Item Details
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
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(favoritesProvider.notifier).toggle(item.id),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isTelegram)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0088CC).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Telegram',
                            style: TextStyle(fontSize: 10, color: Color(0xFF0088CC), fontWeight: FontWeight.bold),
                          ),
                        ),
                      Text(
                        isAmharic ? item.category.nameAm(context) : item.category.nameEn(context),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      if (count > 0) ...[
                        const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                        Text(
                          isAmharic ? '$count ሪፖርቶች' : '$count reports',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 2),
                      Text(
                        selectedMarket?.localizedName(isAmharic) ?? 'Addis Ababa',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Price Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (median != null) ...[
                  Text(
                    median >= 1000000
                        ? '${(median / 1000000).toStringAsFixed(1)}M'
                        : median >= 100000
                        ? '${(median / 1000).toStringAsFixed(0)}k'
                        : median.toStringAsFixed(median.truncateToDouble() == median ? 0 : 1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF136A36),
                    ),
                  ),
                  Text(
                    'ETB / $unit',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ] else ...[
                  Text(
                    isAmharic ? 'ዋጋ ገና የለም' : 'Pending',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
