import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/category_filter_chips.dart';
import 'package:gebeya/features/items/presentation/widgets/market_selector_sheet.dart';
import 'package:gebeya/features/items/presentation/widgets/price_card.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

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
    final viewMode = ref.watch(viewModeProvider);
    final isDataSaver = ref.watch(dataSaverProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0C0E12),
        titleSpacing: 16,
        title: Row(
          children: [
            // Kalo style glowing green brand logo & name
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFB2D15A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 20,
                  color: Color(0xFF0C0E12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isAmharic ? 'ገበያ' : 'Gebeya',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFFF8FAFC),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Data / window indicator pill
          Tooltip(
            message: isDataSaver
                ? (isAmharic ? 'ዳታ ቆጣቢ ሁነታ በርቷል' : 'Data saver active')
                : (isAmharic ? 'የቅርብ 7 ቀናት መረጃ' : 'Last 7 days data window'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E232B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFD79C3A),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDataSaver ? 'DATA' : '7d',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Market Selector Pill
          Tooltip(
            message: isAmharic ? 'የገበያ ቦታ ይምረጡ' : 'Select market location',
            child: Semantics(
              button: true,
              label: isAmharic ? 'የገበያ ቦታ ይምረጡ' : 'Select market location',
              child: InkWell(
                onTap: () => MarketSelectorSheet.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E232B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFB2D15A)),
                      const SizedBox(width: 4),
                      Text(
                        selectedMarket?.localizedName(isAmharic) ?? 'Merkato',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Language Toggle
          Tooltip(
            message: isAmharic ? 'ወደ English ቀይር' : 'ወደ አማርኛ ቀይር',
            child: Semantics(
              button: true,
              label: isAmharic ? 'Switch to English' : 'Switch to Amharic',
              child: InkWell(
                onTap: () => ref.read(localeProvider.notifier).toggle(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E232B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Center(
                    child: Text(
                      isAmharic ? 'EN' : 'አማ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB2D15A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFB2D15A),
        backgroundColor: const Color(0xFF16191E),
        onRefresh: () async {
          ref.invalidate(itemsProvider);
          ref.invalidate(marketAggregatesProvider);
          await ref.read(itemsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: InputDecoration(
                    hintText: isAmharic
                        ? '${selectedMarket?.localizedName(isAmharic) ?? "መርካቶ"} ውስጥ ይፈልጉ...'
                        : 'Search in ${selectedMarket?.localizedName(isAmharic) ?? "Merkato"}...',
                    hintStyle: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB2D15A), size: 22),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: isAmharic ? 'ፍለጋ አጽዳ' : 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF8E9BAE)),
                            onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                          ),
                    filled: true,
                    fillColor: const Color(0xFF16191E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF262C36)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF262C36)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFB2D15A), width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                ),
              ),
            ),

            // Category Carousel
            const SliverToBoxAdapter(
              child: CategoryFilterChips(),
            ),

            // Feed Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAmharic ? '${filteredItems.length} እቃዎች' : '${filteredItems.length} Items',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                    // Grid / List View Toggle
                    InkWell(
                      onTap: () => ref.read(viewModeProvider.notifier).toggle(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16191E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262C36)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              viewMode == ViewMode.grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                              size: 16,
                              color: const Color(0xFFB2D15A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              viewMode == ViewMode.grid
                                  ? (isAmharic ? 'ዝርዝር' : 'List')
                                  : (isAmharic ? 'ፍርግርግ' : 'Grid'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB2D15A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid / List (Zero overflow layout)
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
                          const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF9AA7B8)),
                          const SizedBox(height: 12),
                          Text(
                            isAmharic ? 'ከፍለጋዎ ጋር የሚዛመድ እቃ የለም' : 'No matches for your search',
                            style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB2D15A), foregroundColor: const Color(0xFF0C0E12)),
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

                if (viewMode == ViewMode.grid && !isDataSaver && MediaQuery.textScalerOf(context).scale(14) <= 18) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 235,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filteredItems[index];
                          final aggregate = aggregates[item.id];
                          return PriceCard(
                            item: item,
                            aggregate: aggregate,
                          );
                        },
                        childCount: filteredItems.length,
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
                child: Center(child: CircularProgressIndicator(color: Color(0xFFB2D15A))),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isAmharic ? 'እቃዎችን መጫን አልተቻለም' : 'Could not load items. Please try again.'),
                      TextButton(onPressed: () => ref.invalidate(itemsProvider), child: Text(isAmharic ? 'እንደገና ሞክር' : 'Retry')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
