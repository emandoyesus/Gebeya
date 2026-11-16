import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/market_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/core/utils/relative_time.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final aggregatesAsync = ref.watch(marketAggregatesProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(item.localizedName(isAmharic)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    aggregate == null && item.listingPrice == null
                        ? (isAmharic ? 'የዋጋ መረጃ ገና የለም' : 'Price not reported yet')
                        : item.listingPrice != null && aggregate == null
                        ? '${item.nameEn}: ${item.listingPrice} ETB (seller listing)\n${item.listingSource ?? ""}'
                        : isAmharic
                        ? '${item.nameAm} በ${selectedMarket?.nameAm ?? ''} አማካኝ ዋጋ፡ ${aggregate?.medianPrice ?? 0} ETB'
                        : '${item.nameEn} median price in ${selectedMarket?.nameEn ?? ''}: ${aggregate?.medianPrice ?? 0} ETB',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketImage(
              category: item.category,
              imageUrl: item.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            Text(
              item.imageUrl != null
                  ? (isAmharic ? 'የእቃው ፎቶ' : 'Product photo')
                  : (isAmharic ? 'የምድቡ ምሳሌ ፎቶ' : 'Illustrative category photo'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            // Market and Freshness badge
            Row(
              children: [
                const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF136A36)),
                const SizedBox(width: 6),
                Text(
                  selectedMarket?.localizedName(isAmharic) ?? 'Addis Ababa',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                if (aggregate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      RelativeTime.format(aggregate.lastReportedAt, isAmharic: isAmharic),
                      style: const TextStyle(
                        color: Color(0xFF136A36),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (item.listingPrice != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.localizedName(isAmharic),
                        style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('${item.listingPrice!.toStringAsFixed(0)} ETB / $unit',
                        style: const TextStyle(fontSize: 28,
                          fontWeight: FontWeight.bold, color: Color(0xFF136A36))),
                      Text(isAmharic ? 'የሻጭ ዋጋ' : 'Seller listing price'),
                      const SizedBox(height: 12),
                      Text(item.listingNote ?? ''),
                      const SizedBox(height: 8),
                      SelectableText(item.listingSource ?? '',
                        style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Price Highlight Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    isAmharic ? 'አማካይ የገበያ ዋጋ' : 'Fair Market Value (Median)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        aggregate != null
                            ? aggregate.medianPrice.toStringAsFixed(0)
                            : item.listingPrice != null
                            ? item.listingPrice!.toStringAsFixed(0)
                            : '--',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF136A36),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ETB / $unit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: isAmharic ? 'ዝቅተኛ' : 'Lowest',
                        value: aggregate != null
                            ? '${aggregate.minPrice.toStringAsFixed(0)} ETB'
                            : item.listingPrice != null
                            ? '${(item.listingPrice! * 0.95).toStringAsFixed(0)} ETB'
                            : '--',
                      ),
                      _StatColumn(
                        label: isAmharic ? 'ከፍተኛ' : 'Highest',
                        value: aggregate != null
                            ? '${aggregate.maxPrice.toStringAsFixed(0)} ETB'
                            : item.listingPrice != null
                            ? '${(item.listingPrice! * 1.05).toStringAsFixed(0)} ETB'
                            : '--',
                      ),
                      _StatColumn(
                        label: isAmharic ? 'የሪፖርት ብዛት' : 'Reports',
                        value: aggregate != null ? '${aggregate.reportCount}' : (item.listingPrice != null ? '1' : '0'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (aggregate != null || _history.isNotEmpty || _loadingHistory) ...[
            // 30-Day Trend Chart
            Text(
              isAmharic ? 'የ30 ቀናት የዋጋ እንቅስቃሴ' : '30-Day Price Trend',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(16, 24, 20, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 52,
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
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
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
                              color: const Color(0xFF136A36).withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            ],
            // Local Units Conversion Guide (e.g. Tassa, Quintal)
            if (item.supportedLocalUnits.isNotEmpty) ...[
              Text(
                isAmharic ? 'የገበያ መለኪያዎች' : 'Common Market Units',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.supportedLocalUnits.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final unitInfo = item.supportedLocalUnits[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.straighten_rounded, size: 20, color: Color(0xFFD97706)),
                      title: Text(
                        isAmharic ? unitInfo.nameAm : unitInfo.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '≈ ${unitInfo.multiplier} $unit',
                        style: const TextStyle(
                          color: Color(0xFF136A36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136A36),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(
                  isAmharic ? 'የገዙበትን ዋጋ ያስመዝግቡ' : 'Report What You Paid',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  context.push('/report?itemId=${item.id}');
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
