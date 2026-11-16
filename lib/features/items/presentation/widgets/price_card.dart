import 'package:flutter/material.dart';
import 'market_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/core/utils/relative_time.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

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
    final isAmharic = ref.watch(isAmharicProvider);

    final isListing = aggregate == null && item.listingPrice != null;
    final median = aggregate?.medianPrice ?? item.listingPrice;
    final min = aggregate?.minPrice;
    final max = aggregate?.maxPrice;
    final count = aggregate?.reportCount ?? 0;
    final unit = item.localizedStandardUnit(isAmharic);

    return InkWell(
      onTap: () {
        context.push('/item/${item.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            MarketImage(category: item.category, width: 64, height: 76),
            const SizedBox(width: 14),

            // Item Name & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedName(isAmharic),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.listingSource != null)
                    Text(
                      Uri.tryParse(item.listingSource!)?.host == 't.me'
                          ? 'Telegram · ${Uri.parse(item.listingSource!).pathSegments.first}'
                          : Uri.tryParse(item.listingSource!)?.host ?? '',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Wrap(
                    spacing: 2,
                    runSpacing: 4,
                    children: [
                      Text(
                        isAmharic ? item.category.nameAm(context) : item.category.nameEn(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (count > 0) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        Text(
                          isAmharic ? '$count ሪፖርቶች' : '$count reports',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price & Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (median != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        median.toStringAsFixed(median.truncateToDouble() == median ? 0 : 1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF136A36),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        ' ETB/$unit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (isListing)
                    Text(isAmharic ? 'የሻጭ ዋጋ' : 'Listing price',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  if (min != null && max != null)
                    Text(
                      '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} ETB',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  if (aggregate?.lastReportedAt != null)
                    Text(
                      RelativeTime.format(aggregate!.lastReportedAt, isAmharic: isAmharic),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ] else ...[
                  Text(
                    isAmharic ? 'ዋጋ ገና የለም' : 'Price pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
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
