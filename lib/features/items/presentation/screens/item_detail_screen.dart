import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/utils/relative_time.dart';
import 'package:gebeya/core/utils/unit_converter.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/market_image.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loadingHistory = true;
  LocalUnitInfo? _selectedUnit;
  double _unitQty = 1.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final selectedMarket = ref.read(selectedMarketProvider);
    final marketId = selectedMarket?.id ?? 'm-merkato';
    final history = await ref
        .read(itemsRepositoryProvider)
        .getItemHistory(widget.itemId, marketId);
    if (mounted) {
      setState(() {
        _history = history;
        _loadingHistory = false;
      });
    }
  }

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
        backgroundColor: const Color(0xFF0088CC),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAmharic
                    ? 'የቴሌግራም መልእክት ተቀድቷል! ቴሌግራም ላይ ፔስት ያድርጉ።'
                    : 'Telegram deal copied to clipboard! Paste in Telegram.',
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
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.itemId);
    final comparisonAsync = ref.watch(marketComparisonProvider(widget.itemId));
    final marketsAsync = ref.watch(marketsProvider);

    final matches = itemsAsync.valueOrNull
        ?.where((candidate) => candidate.id == widget.itemId);
    final ItemModel? item =
        matches == null || matches.isEmpty ? null : matches.first;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }

    final aggregate = aggregatesAsync.valueOrNull?[item.id];
    final unit = item.localizedStandardUnit(isAmharic);
    final isListing = aggregate == null && item.listingPrice != null;
    final effectivePrice = aggregate?.medianPrice ?? item.listingPrice;
    final minPrice = aggregate?.minPrice ?? (isListing ? (item.listingPrice! * 0.95) : null);
    final maxPrice = aggregate?.maxPrice ?? (isListing ? (item.listingPrice! * 1.05) : null);
    final isTelegram = item.listingSource != null &&
        (item.listingSource!.contains('t.me') || item.listingSource!.contains('telegram'));

    // Set initial unit if null and available
    if (_selectedUnit == null && item.supportedLocalUnits.isNotEmpty) {
      _selectedUnit = item.supportedLocalUnits.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          item.localizedName(isAmharic),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        actions: [
          // Favorite button
          IconButton(
            tooltip: isFavorite ? 'Remove from saved' : 'Save item',
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF64748B),
            ),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(item.id),
          ),
          // Share to Telegram button (Idea 5)
          IconButton(
            tooltip: isAmharic ? 'ለቴሌግራም አጋራ' : 'Share to Telegram',
            icon: const Icon(Icons.send_rounded, color: Color(0xFF0088CC)),
            onPressed: () => _shareToTelegram(
              item,
              effectivePrice,
              unit,
              selectedMarket?.localizedName(isAmharic) ?? 'Merkato',
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
            // JIJI Style Large Photo Showcase Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                          imageUrl: item.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
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
                                  color: const Color(0xFF0088CC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.send_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Telegram Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            else if (aggregate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF136A36),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAmharic ? 'የተረጋገጠ የገበያ ዋጋ' : 'Verified Market Price',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                                color: Color(0xFF136A36),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ $unit',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (minPrice != null && maxPrice != null)
                          Text(
                            isAmharic
                                ? 'የዋጋ ክልል፡ ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} ETB'
                                : 'Market range: ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} ETB',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // Location & Freshness row
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF136A36)),
                            const SizedBox(width: 4),
                            Text(
                              selectedMarket?.localizedName(isAmharic) ?? 'Addis Ababa',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                            ),
                            const Spacer(),
                            if (aggregate?.lastReportedAt != null)
                              Text(
                                RelativeTime.format(aggregate!.lastReportedAt, isAmharic: isAmharic),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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

            // IDEA 2: Physical Market Comparison Card (Merkato vs Shola vs Saris vs Kera vs Megenagna)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 20, color: Color(0xFF136A36)),
                      const SizedBox(width: 8),
                      Text(
                        isAmharic ? 'የአዲስ አበባ ገበያዎች ንጽጽር' : 'Addis Ababa Markets Comparison',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAmharic
                        ? 'በየትኛው ገበያ ርካሽ እንደሆነ ይመልከቱ (ለመቀየር ገበያውን ይጫኑ)'
                        : 'See which market offers the best price (Tap to switch)',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  comparisonAsync.when(
                    data: (comparison) {
                      final allMarkets = marketsAsync.valueOrNull ?? [];
                      if (comparison.isEmpty || allMarkets.isEmpty) {
                        return const Text('Comparison not available');
                      }
                      // Find minimum price
                      double minP = double.infinity;
                      for (final p in comparison.values) {
                        if (p < minP) minP = p;
                      }

                      return Column(
                        children: allMarkets.map((market) {
                          final price = comparison[market.id] ?? effectivePrice;
                          final isCheapest = price != null && (price - minP).abs() < 1;
                          final isCurrent = market.id == selectedMarket?.id;

                          return InkWell(
                            onTap: () {
                              ref.read(selectedMarketProvider.notifier).state = market;
                              _loadHistory();
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCurrent ? const Color(0xFFE8F5E9) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCurrent ? const Color(0xFF136A36) : const Color(0xFFE2E8F0),
                                  width: isCurrent ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    size: 16,
                                    color: isCurrent ? const Color(0xFF136A36) : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          market.localizedName(isAmharic),
                                          style: TextStyle(
                                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                            fontSize: 13,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          market.subcity ?? '',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        price != null ? '${price.toStringAsFixed(0)} ETB' : '--',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isCheapest ? const Color(0xFF136A36) : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (isCheapest)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF136A36),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isAmharic ? '💰 በጣም ርካሽ' : '💰 Best Price',
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IDEA 3: Native Ethiopian Units & Interactive Converter
            if (item.supportedLocalUnits.isNotEmpty && effectivePrice != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.balance_rounded, size: 20, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text(
                          isAmharic ? 'የኢትዮጵያ የገበያ መለኪያዎችና አስሊ' : 'Ethiopian Market Unit Calculator',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAmharic
                          ? 'እንደ ጣሳ፣ ኩባያ፣ ኩንታል፣ ወይም ጆግ ያሉ ባህላዊ መለኪያዎችን አስላ'
                          : 'Calculate prices for traditional units (Tassa, Kubaya, Quintal, Jog)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                          selectedColor: const Color(0xFFFEF3C7),
                          label: Text(
                            isAmharic ? lu.nameAm : lu.nameEn,
                            style: TextStyle(
                              color: isSel ? const Color(0xFFB45309) : const Color(0xFF475569),
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
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFD97706)),
                                      onPressed: _unitQty > 1
                                          ? () => setState(() => _unitQty -= 1)
                                          : null,
                                    ),
                                    Text(
                                      _unitQty.toStringAsFixed(0),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFD97706)),
                                      onPressed: () => setState(() => _unitQty += 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_unitQty.toStringAsFixed(0)} ${_selectedUnit!.nameAm} ≈ ${(_unitQty * _selectedUnit!.multiplier).toStringAsFixed(2)} $unit',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  '${(_unitQty * _selectedUnit!.multiplier * effectivePrice).toStringAsFixed(0)} ETB',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF136A36),
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

            // IDEA 4: Daily Commodity & 30-Day Inflation/Trend Chart
            if (effectivePrice != null || _history.isNotEmpty || _loadingHistory) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded, size: 20, color: Color(0xFF136A36)),
                            const SizedBox(width: 8),
                            Text(
                              isAmharic ? 'የ30 ቀናት የዋጋ እንቅስቃሴ' : '30-Day Price Trend',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'WAGA INDEX',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF136A36)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: _loadingHistory
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF136A36)))
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.shade100,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 45,
                                      getTitlesWidget: (val, meta) {
                                        final intVal = val.toInt();
                                        String text;
                                        if (intVal >= 1000000) {
                                          text = '${(intVal / 1000000).toStringAsFixed(1)}M';
                                        } else if (intVal >= 1000) {
                                          text = '${(intVal / 1000).toStringAsFixed(0)}k';
                                        } else {
                                          text = '$intVal';
                                        }
                                        return Text(
                                          text,
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _history.asMap().entries.map((e) {
                                      return FlSpot(
                                        e.key.toDouble(),
                                        (e.value['price'] as num).toDouble(),
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF136A36),
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFF136A36).withValues(alpha: 0.12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // IDEA 5: Telegram & Listing Sources Action Card
            if (item.listingSource != null || item.listingNote != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF0088CC)),
                        const SizedBox(width: 8),
                        Text(
                          isAmharic ? 'የእቃውና የሻጩ መረጃ' : 'Listing & Verification Details',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    if (item.listingNote != null) ...[
                      const SizedBox(height: 8),
                      Text(item.listingNote!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    ],
                    if (item.listingSource != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0088CC),
                                side: const BorderSide(color: Color(0xFF0088CC)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                selectedMarket?.localizedName(isAmharic) ?? 'Merkato',
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

            // Primary Bottom Action: Report Price
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136A36),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(
                  isAmharic ? 'የገዙበትን ዋጋ ያስመዝግቡ' : 'Report What You Paid',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => context.push('/report?itemId=${item.id}'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
