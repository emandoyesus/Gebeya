import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
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
    final viewMode = ref.watch(viewModeProvider);
    final isDataSaver = ref.watch(dataSaverProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Brand Title in Forest Green
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isAmharic ? 'ገበያ ' : 'Gebeya ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Color(0xFF136A36),
                        ),
                      ),
                      TextSpan(
                        text: isAmharic ? 'ኢትዮጵያ' : 'Ethiopia',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Idea 6: Offline Ready status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDataSaver ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDataSaver ? Icons.offline_bolt_rounded : Icons.check_circle_rounded,
                        size: 10,
                        color: isDataSaver ? const Color(0xFFD97706) : const Color(0xFF136A36),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isDataSaver
                            ? (isAmharic ? 'ዳታ ቆጣቢ' : 'Data Saver')
                            : (isAmharic ? 'ከመስመር ውጭ' : 'Offline OK'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDataSaver ? const Color(0xFFB45309) : const Color(0xFF0E4C26),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Idea 2: Physical Market Comparison / Selector affordance
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.black54),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Idea 6: Data Saver toggle button
          IconButton(
            tooltip: isAmharic ? 'ዳታ ቆጣቢ ሁነታ' : 'Toggle Data Saver Mode',
            icon: Icon(
              isDataSaver ? Icons.offline_bolt_rounded : Icons.offline_bolt_outlined,
              color: isDataSaver ? const Color(0xFFD97706) : const Color(0xFF64748B),
            ),
            onPressed: () {
              ref.read(dataSaverProvider.notifier).toggle();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    ref.read(dataSaverProvider)
                        ? (isAmharic ? 'ዳታ ቆጣቢ ሁነታ በርቷል (ፈጣንና አነስተኛ ዳታ)' : 'Data Saver enabled (High speed & minimal data)')
                        : (isAmharic ? 'ዳታ ቆጣቢ ሁነታ ጠፍቷል' : 'Standard view restored'),
                  ),
                ),
              );
            },
          ),
          // Language toggle
          IconButton(
            tooltip: isAmharic ? 'ቋንቋ ቀይር' : 'Change Language',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isAmharic ? 'EN' : 'አማ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF136A36),
                ),
              ),
            ),
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
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
            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAmharic
                        ? '${selectedMarket?.localizedName(isAmharic) ?? "መርካቶ"} ውስጥ ይፈልጉ...'
                        : 'Search in ${selectedMarket?.localizedName(isAmharic) ?? "Merkato"}...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF136A36), size: 22),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: isAmharic ? 'ፍለጋ አጽዳ' : 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF136A36), width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                ),
              ),
            ),

            // Category Carousel
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: const CategoryFilterChips(),
              ),
            ),

            // Value Proposition / Ideas 2, 4, 5 Quick Highlights Banner
            if (query.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3D24), Color(0xFF136A36)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF136A36).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isAmharic ? 'የገበያ ዋጋ ጠቋሚ' : 'MARKET INTELLIGENCE',
                                    style: const TextStyle(
                                      color: Color(0xFFFEF3C7),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.trending_up_rounded, color: Color(0xFFFEF3C7), size: 14),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isAmharic
                                  ? 'ትክክለኛውን የገበያ ዋጋ ይወቁ'
                                  : 'Know true market prices',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAmharic
                                  ? 'መርካቶ፣ ሾላ፣ ሳሪስና ቴሌግራምን ያወዳድሩ'
                                  : 'Compare Merkato, Shola, Saris & Telegram',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => MarketSelectorSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAmharic ? 'አወዳድር' : 'Compare',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF136A36),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Feed Header: Count + Grid/List Switcher
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAmharic ? '${filteredItems.length} እቃዎች ይገኛሉ' : '${filteredItems.length} items found',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Row(
                      children: [
                        // View mode toggle
                        InkWell(
                          onTap: () => ref.read(viewModeProvider.notifier).toggle(),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  viewMode == ViewMode.grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                  size: 16,
                                  color: const Color(0xFF136A36),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  viewMode == ViewMode.grid
                                      ? (isAmharic ? 'ዝርዝር' : 'List')
                                      : (isAmharic ? 'ፍርግርግ' : 'Grid'),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF136A36)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            isAmharic ? 'ከፍለጋዎ ጋር የሚዛመድ እቃ የለም' : 'No matches for your search',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF136A36)),
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

                // 2-Column Responsive Grid View with fixed height (guarantees zero overflow)
                if (viewMode == ViewMode.grid && !isDataSaver) {
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

                // Compact List View (Default in Data Saver mode)
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
                child: Center(child: CircularProgressIndicator(color: Color(0xFF136A36))),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 40),
                      const SizedBox(height: 12),
                      Text(isAmharic ? 'እቃዎችን መጫን አልተቻለም' : 'Could not load catalog'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF136A36)),
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
          isAmharic ? 'ዋጋ ሪፖርት አድርግ' : 'Post / Report Price',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.push('/report'),
      ),
    );
  }
}
