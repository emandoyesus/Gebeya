import 'package:flutter/material.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import '../widgets/market_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/category_filter_chips.dart';
import 'package:gebeya/features/items/presentation/widgets/market_selector_sheet.dart';
import 'package:gebeya/features/items/presentation/widgets/price_card.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchQueryProvider, (_, next) {
      if (_searchController.text != next) _searchController.text = next;
    });
    final itemsAsync = ref.watch(itemsProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final filteredItems = ref.watch(filteredItemsProvider);
    final aggregatesAsync = ref.watch(marketAggregatesProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isAmharic ? 'ገበያ' : 'Gebeya',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF136A36),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAmharic ? 'አዲስ አበባ' : 'Addis Ababa',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: () => MarketSelectorSheet.show(context),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF136A36)),
                  const SizedBox(width: 4),
                  Text(
                    selectedMarket != null
                        ? selectedMarket.localizedName(isAmharic)
                        : (isAmharic ? 'ገበያ ይምረጡ' : 'Select Market'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.black54),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isAmharic ? 'ቋንቋ ቀይር' : 'Change Language',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAmharic ? 'EN' : 'አማ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF136A36),
                ),
              ),
            ),
            onPressed: () {
              ref.read(localeProvider.notifier).toggle();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(itemsProvider);
          ref.invalidate(marketAggregatesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF153F2B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAmharic ? 'የገበያ ዋጋ መረጃ' : 'YOUR MARKET COMPANION',
                            style: const TextStyle(color: Color(0xFFE8C978),
                              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAmharic ? 'ዋጋ ያወዳድሩ። በእርግጠኝነት ይግዙ።' : 'Know the price.\nShop with confidence.',
                            style: const TextStyle(color: Colors.white,
                              fontSize: 24, height: 1.25, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAmharic ? 'በማህበረሰቡ የተጋሩ የአካባቢ ገበያ ዋጋዎች።' : 'Local prices, shared by your community.',
                            style: const TextStyle(color: Color(0xFFD6E4DA), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    if (MediaQuery.sizeOf(context).width > 440) ...[
                      const SizedBox(width: 20),
                      const MarketImage(width: 140, height: 160),
                    ],
                  ],
                ),
              ),
            ),
            // Search Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAmharic ? 'የእቃውን ስም ይፈልጉ...' : 'Search products or categories...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: query.isEmpty ? null : IconButton(
                      tooltip: isAmharic ? 'ፍለጋ አጽዳ' : 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                ),
              ),
            ),

            // Category Filter Chips
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: CategoryFilterChips(),
              ),
            ),

            // Price List Header Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAmharic ? 'እቃዎችና ዋጋዎች' : 'Products & prices',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      isAmharic ? '${filteredItems.length} እቃዎች' : '${filteredItems.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Items List
            itemsAsync.when(
              data: (_) {
                final aggregates = aggregatesAsync.valueOrNull ?? <String, PriceAggregateModel>{};
                if (filteredItems.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            isAmharic ? 'ከፍለጋዎ ጋር የሚዛመድ እቃ የለም' : 'No matches for your search',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () {
                              ref.read(searchQueryProvider.notifier).state = '';
                              ref.read(selectedCategoryProvider.notifier).state = ItemCategory.all;
                            },
                            child: Text(isAmharic ? 'ሁሉንም እቃዎች አሳይ' : 'Clear filters & show all'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        final aggregate = aggregates[item.id];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PriceCard(
                            item: item,
                            aggregate: aggregate,
                          ),
                        );
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 40),
                      const SizedBox(height: 12),
                      Text(isAmharic ? 'እቃዎችን መጫን አልተቻለም' : 'Could not load the catalog'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(itemsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(isAmharic ? 'እንደገና ሞክር' : 'Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF136A36),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: Text(
          isAmharic ? 'ዋጋ ሪፖርት አድርግ' : 'Report Price',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          context.push('/report');
        },
      ),
    );
  }
}
