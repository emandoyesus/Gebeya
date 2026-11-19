import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/basket/presentation/basket_provider.dart';
import 'package:gebeya/features/items/data/price_aggregate_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/category_filter_chips.dart';
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
    final itemsAsync = ref.watch(itemsProvider);
    final aggregatesAsync = ref.watch(marketAggregatesProvider);
    final filteredItems = ref.watch(filteredItemsProvider);
    final isAmharic = ref.watch(isAmharicProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isDataSaver = ref.watch(dataSaverProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
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
          // Shopping Basket Quick Action with badge
          Stack(
            alignment: Alignment.center,
            children: [
              Tooltip(
                message: isAmharic ? 'የገበያ ቅርጫት' : 'Market Basket',
                child: InkWell(
                  onTap: () => context.push('/basket'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E232B),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF262C36)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 20,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                ),
              ),
              if (ref.watch(basketTotalCountProvider) > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB2D15A),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ref.watch(basketTotalCountProvider)}',
                      style: const TextStyle(
                        color: Color(0xFF0C0E12),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
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
                  width: 44,
                  height: 44,
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
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isAmharic ? 'የእቃ ስም ፈልግ (ለምሳሌ፡ ጤፍ፣ ሽንኩርት)...' : 'Search commodities (e.g., Teff, Onion)...',
                    hintStyle: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB2D15A)),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Color(0xFF8E9BAE), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        key: ValueKey<int>(filteredItems.length),
                        isAmharic ? '${filteredItems.length} እቃዎች' : '${filteredItems.length} Items',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                    // Grid / List View Toggle with Micro-Interaction
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: animation, child: child),
                          ),
                          child: Row(
                            key: ValueKey<ViewMode>(viewMode),
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
                              _searchController.clear();
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 245,
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        final aggregate = aggregates[item.id];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFB2D15A)),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    isAmharic ? 'መረጃ መጫን አልተቻለም፡ $err' : 'Error loading catalog: $err',
                    style: const TextStyle(color: Colors.white70),
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
