import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/utils/relative_time.dart';
import 'package:gebeya/core/utils/unit_converter.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/market_image.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  LocalUnitInfo? _selectedUnit;
  double _unitQty = 1.0;

  void _shareToTelegram(ItemModel item, double? price, String unit, String marketName, bool isAmharic) {
    final priceStr = price != null ? '${price.toStringAsFixed(0)} ETB/$unit' : 'ዋጋ ገና አልተረጋገጠም';
    final msg = '''
🛒 *${isAmharic ? item.nameAm : item.nameEn}*
💰 *የገበያ ዋጋ:* $priceStr
📍 *ገበያ:* $marketName
ℹ️ *ምንጭ:* ገበያ (Gebeya Ethiopia) · የሸማቾች ዋጋ መረጃ
🔗 ${item.listingSource ?? "https://t.me/gebeya_et"}
''';
    Clipboard.setData(ClipboardData(text: msg));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16191E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF262C36)),
        ),
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Color(0xFF59B0D7), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAmharic
                    ? 'የቴሌግራም መልእክት ተቀድቷል! ቴሌግራም ላይ ፔስት ያድርጉ።'
                    : 'Telegram deal copied to clipboard! Paste in Telegram.',
                style: const TextStyle(color: Color(0xFFF8FAFC)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final aggregatesAsync = ref.watch(marketAggregatesProvider);
    final isAmharic = ref.watch(isAmharicProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.itemId);

    final matches = itemsAsync.valueOrNull
        ?.where((candidate) => candidate.id == widget.itemId);
    final ItemModel? item =
        matches == null || matches.isEmpty ? null : matches.first;

    if (itemsAsync.isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (itemsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: TextButton(
          onPressed: () => ref.invalidate(itemsProvider),
          child: Text(isAmharic ? 'እንደገና ሞክር' : 'Could not load item. Retry'),
        )),
      );
    }
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(isAmharic ? 'እቃው አልተገኘም' : 'Item not found')),
      );
    }

    final aggregate = aggregatesAsync.valueOrNull?[item.id];
    final unit = item.localizedStandardUnit(isAmharic);
    final effectivePrice = aggregate?.medianPrice ?? item.listingPrice;
    final minPrice = aggregate?.minPrice;
    final maxPrice = aggregate?.maxPrice;
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));

    // Set initial unit if null and available
    if (_selectedUnit == null && item.supportedLocalUnits.isNotEmpty) {
      _selectedUnit = item.supportedLocalUnits.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        title: Text(
          item.localizedName(isAmharic),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
        ),
        actions: [
          // Favorite button
          IconButton(
            tooltip: isFavorite ? 'Remove from saved' : 'Save item',
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? const Color(0xFFF43F5E) : const Color(0xFF8E9BAE),
            ),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(item.id),
          ),
          // Share to Telegram button (Idea 5)
          IconButton(
            tooltip: isAmharic ? 'ለቴሌግራም አጋራ' : 'Share to Telegram',
            icon: const Icon(Icons.send_rounded, color: Color(0xFF59B0D7)),
            onPressed: () => _shareToTelegram(
              item,
              effectivePrice,
              unit,
              item.sourceLocation ?? item.sourceLabel ?? 'Location not provided',
              isAmharic,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kalo Style Dark Large Photo Showcase Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 250,
                        child: MarketImage(
                          category: item.category,
                          imageUrl: item.displayImageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: item.correctedImageUrl != null ? BoxFit.contain : BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            if (isTelegram)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF59B0D7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.send_rounded, size: 12, color: Color(0xFF0C0E12)),
                                    SizedBox(width: 4),
                                    Text('Telegram listing', style: TextStyle(color: Color(0xFF0C0E12), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            else if (aggregate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFB2D15A).withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  isAmharic ? 'የዋጋ ግምት' : 'Price estimate',
                                  style: const TextStyle(color: Color(0xFFB2D15A), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.localizedName(isAmharic),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                        ),
                        const SizedBox(height: 8),
                        // Price Banner
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              effectivePrice != null
                                  ? '${effectivePrice.toStringAsFixed(effectivePrice.truncateToDouble() == effectivePrice ? 0 : 1)} ETB'
                                  : (isAmharic ? 'ዋጋ ገና የለም' : 'Price pending'),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB2D15A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ $unit',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8E9BAE)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (minPrice != null && maxPrice != null)
                          Text(
                            isAmharic
                                ? 'የዋጋ ክልል፡ ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} ETB'
                                : 'Market range: ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} ETB',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                          ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFF262C36)),
                        const SizedBox(height: 12),
                        // Location & Freshness row
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFB2D15A)),
                            const SizedBox(width: 4),
                            Text(
                              item.sourceLocation ?? item.sourceLabel ?? (isAmharic ? 'አካባቢ አልተገለጸም' : 'Location not provided'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC)),
                            ),
                            const Spacer(),
                            if (aggregate?.lastReportedAt != null)
                              Text(
                                RelativeTime.format(aggregate!.lastReportedAt, isAmharic: isAmharic),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAmharic ? 'አካባቢ እና ምንጭ' : 'Location & source',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.sourceLocation != null
                        ? '${isAmharic ? "በዝርዝሩ የተጠቀሰ አካባቢ" : "Listed location"}: ${item.sourceLocation}'
                        : (isAmharic ? 'የሻጩ አካባቢ አልተገለጸም' : 'Seller location not provided'),
                    style: const TextStyle(color: Color(0xFFB2D15A), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.sourceLabel != null
                        ? '${isAmharic ? "የመረጃ ምንጭ" : "Listing source"}: ${item.sourceLabel}'
                        : (isAmharic ? 'የመረጃ ምንጭ አልተገለጸም' : 'Source not provided'),
                    style: const TextStyle(color: Color(0xFF8E9BAE)),
                  ),
                  if (item.listingSource?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    SelectableText(item.listingSource!, style: const TextStyle(color: Color(0xFF59B0D7), fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IDEA 3: Native Ethiopian Units & Interactive Converter
            if (item.supportedLocalUnits.isNotEmpty && effectivePrice != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16191E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF262C36)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.balance_rounded, size: 20, color: Color(0xFFD79C3A)),
                        const SizedBox(width: 8),
                        Text(
                          isAmharic ? 'የኢትዮጵያ የገበያ መለኪያዎችና አስሊ' : 'Ethiopian Market Unit Calculator',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAmharic
                          ? 'እንደ ጣሳ፣ ኩባያ፣ ኩንታል፣ ወይም ጆግ ያሉ ባህላዊ መለኪያዎችን አስላ'
                          : 'Calculate prices for traditional units (Tassa, Kubaya, Quintal, Jog)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                    ),
                    const SizedBox(height: 12),
                    // Unit Selection Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.supportedLocalUnits.map((lu) {
                        final isSel = _selectedUnit?.unitKey == lu.unitKey;
                        return ChoiceChip(
                          selected: isSel,
                          selectedColor: const Color(0xFFB2D15A),
                          backgroundColor: const Color(0xFF1E232B),
                          label: Text(
                            isAmharic ? lu.nameAm : lu.nameEn,
                            style: TextStyle(
                              color: isSel ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedUnit = lu;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedUnit != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF281C0B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD79C3A).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAmharic
                                      ? 'ብዛት (${_selectedUnit!.nameAm})'
                                      : 'Quantity (${_selectedUnit!.nameEn})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC)),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFD79C3A)),
                                      onPressed: _unitQty > 1
                                          ? () => setState(() => _unitQty -= 1)
                                          : null,
                                    ),
                                    Text(
                                      _unitQty.toStringAsFixed(0),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF8FAFC)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFD79C3A)),
                                      onPressed: () => setState(() => _unitQty += 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF38230D)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_unitQty.toStringAsFixed(0)} ${_selectedUnit!.nameAm} ≈ ${(_unitQty * _selectedUnit!.multiplier).toStringAsFixed(2)} $unit',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                                ),
                                Text(
                                  '${(_unitQty * _selectedUnit!.multiplier * effectivePrice).toStringAsFixed(0)} ETB',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB2D15A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart_rounded, size: 20, color: Color(0xFFB2D15A)),
                      const SizedBox(width: 8),
                      Text(
                        isAmharic ? 'የዋጋ ታሪክ' : 'Price History',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.history_toggle_off_rounded, size: 18, color: Color(0xFF8E9BAE)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAmharic ? 'የተመዘገበ የዋጋ ታሪክ ገና የለም።' : 'Recorded price history is not available yet.',
                          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IDEA 5: Telegram & Listing Sources Action Card
            if (item.listingSource != null || item.listingNote != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16191E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF262C36)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF59B0D7)),
                        const SizedBox(width: 8),
                        Text(
                          isAmharic ? 'የእቃውና የሻጩ መረጃ' : 'Listing & Verification Details',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                        ),
                      ],
                    ),
                    if (item.listingNote != null) ...[
                      const SizedBox(height: 8),
                      Text(item.listingNote!, style: const TextStyle(fontSize: 13, color: Color(0xFF8E9BAE))),
                    ],
                    if (item.listingSource != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF59B0D7),
                                side: const BorderSide(color: Color(0xFF59B0D7)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.send_rounded, size: 16),
                              label: Text(
                                isAmharic ? 'ለቴሌግራም አጋራ' : 'Share to Telegram',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _shareToTelegram(
                                item,
                                effectivePrice,
                                unit,
                                item.sourceLocation ?? item.sourceLabel ?? 'Location not provided',
                                isAmharic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
