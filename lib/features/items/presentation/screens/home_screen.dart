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
  int _selectedFilterIndex = 0; // 0: Week, 1: Month, 2: 3 Months, 3: Year

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
                color: const Color(0xFFC7F33B),
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
          // Fire streak badge (like the "🔥 7" in Kalo)
          Container(
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
                  color: Color(0xFFF59E0B),
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
          const SizedBox(width: 8),

          // Market Selector Pill
          InkWell(
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
                  const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFC7F33B)),
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
          const SizedBox(width: 8),

          // User Profile avatar (like Kalo top right avatar)
          InkWell(
            onTap: () => ref.read(localeProvider.notifier).toggle(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF1E232B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: Center(
                child: Text(
                  isAmharic ? 'EN' : 'አማ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC7F33B),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7F33B),
        backgroundColor: const Color(0xFF16191E),
        onRefresh: () async {
          ref.invalidate(itemsProvider);
          ref.invalidate(marketAggregatesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Kalo Hero Header: "Your progress / Small steps, big changes."
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAmharic ? 'የገበያ እንቅስቃሴ' : 'Market Pulse',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF8FAFC),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAmharic
                          ? 'የአዲስ አበባ ገበያዎች ዕለታዊ የዋጋ ሚዛን'
                          : 'Real-time Ethiopian commodity intelligence',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E9BAE),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Time Horizon Filter Pills: [Week] [Month] [3 Months] [Year]
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16191E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Row(
                    children: [
                      _buildTimePill(0, isAmharic ? 'ሳምንት' : 'Week'),
                      _buildTimePill(1, isAmharic ? 'ወር' : 'Month'),
                      _buildTimePill(2, isAmharic ? '3 ወራት' : '3 Months'),
                      _buildTimePill(3, isAmharic ? 'ዓመት' : 'Year'),
                    ],
                  ),
                ),
              ),
            ),

            // Kalo Signature Widget 1: Primary Bar Chart Card (Calories Intake style -> Inflation / Commodity Intake)
            if (query.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16191E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAmharic ? 'የገበያ ቅርጫት አማካይ' : 'Market basket average',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E9BAE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    '1,420',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF8FAFC),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAmharic ? 'ETB አማካይ' : 'ETB avg',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8E9BAE),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '↓ 8%',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFC7F33B), // Neon Lime
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAmharic ? 'ካለፈው ሳምንት' : 'vs last week',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF566171),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Weekly Bar Chart (Glowing lime & amber bars)
                      _buildWeeklyBarChart(),
                    ],
                  ),
                ),
              ),

            // Kalo Signature Widget 2: Line Trend Chart Card (Weight Trend style -> Grain & Teff Index)
            if (query.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16191E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAmharic ? 'የጤፍና እህል ዋጋ አቅጣጫ' : 'Teff & grain index',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E9BAE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    '114.5',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF8FAFC),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAmharic ? 'ETB/ኪ.ግ አማካይ' : 'ETB/kg avg',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8E9BAE),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '↓ 1.2 ETB',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFC7F33B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAmharic ? 'ካለፈው ሳምንት' : 'vs last week',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF566171),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Smooth Dot-and-Line Trend
                      _buildSmoothLineChart(),
                    ],
                  ),
                ),
              ),

            // Kalo Signature Widget 3: Twin Metric Rings (Streak & Daily Goal)
            if (query.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Streak Flame Ring
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16191E),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF262C36)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAmharic ? 'ተከታታይነት' : 'Streak',
                                      style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          '12',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFF8FAFC),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAmharic ? 'ቀናት' : 'days',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAmharic ? 'በርታ!' : 'Keep it up!',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF566171)),
                                    ),
                                  ],
                                ),
                              ),
                              // Glowing Flame Circle
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF38230D),
                                  border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_fire_department_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Market Goal / Target Meter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16191E),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF262C36)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAmharic ? 'የዋጋ ግብ' : 'Budget target',
                                style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    '68%',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF8FAFC),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAmharic ? 'የሳምንቱ' : 'weekly',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.68,
                                  backgroundColor: const Color(0xFF262C36),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFFC7F33B)),
                                  minHeight: 5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAmharic ? 'በቁጥጥር ስር ነው!' : 'On track!',
                                style: const TextStyle(fontSize: 10, color: Color(0xFFC7F33B), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Kalo Signature Widget 4: Insights 3-Card Row
            if (query.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAmharic ? 'ግምገማዎችና መረጃዎች' : 'Insights',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // 1. Avg Spend
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16191E),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF262C36)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Avg. basket', style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 10)),
                                  SizedBox(height: 6),
                                  Text('1,420 ETB', style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 13)),
                                  SizedBox(height: 4),
                                  Text('↓ 180 vs last wk', style: TextStyle(color: Color(0xFFC7F33B), fontSize: 9)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. Category Donut / Macro Balance
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16191E),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF262C36)),
                              ),
                              child: Row(
                                children: [
                                  // Mini Donut
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFF59E0B), width: 5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('40% Grains', style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 9)),
                                        Text('35% Veg', style: TextStyle(color: Color(0xFFC7F33B), fontSize: 9)),
                                        Text('25% Meat', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3. Best Day
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16191E),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF262C36)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('Best market', style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 10)),
                                      Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Merkato', style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  const Text('Save 15%!', style: TextStyle(color: Color(0xFFC7F33B), fontSize: 9)),
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
                    hintStyle: const TextStyle(color: Color(0xFF566171), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC7F33B), size: 22),
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
                      borderSide: const BorderSide(color: Color(0xFFC7F33B), width: 1.5),
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
                      isAmharic ? '${filteredItems.length} እቃዎች' : '${filteredItems.length} Live Items',
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
                              color: const Color(0xFFC7F33B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              viewMode == ViewMode.grid
                                  ? (isAmharic ? 'ዝርዝር' : 'List')
                                  : (isAmharic ? 'ፍርግርግ' : 'Grid'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC7F33B)),
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
                          const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF566171)),
                          const SizedBox(height: 12),
                          Text(
                            isAmharic ? 'ከፍለጋዎ ጋር የሚዛመድ እቃ የለም' : 'No matches for your search',
                            style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC7F33B), foregroundColor: const Color(0xFF0C0E12)),
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
                child: Center(child: CircularProgressIndicator(color: Color(0xFFC7F33B))),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text(err.toString(), style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC7F33B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    // 7 days of the week M T W T F S S (Friday highlighted in golden amber like Kalo)
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final heights = [55.0, 50.0, 60.0, 58.0, 75.0, 62.0, 48.0];

    return Column(
      children: [
        // Horizontal guidelines (2,100, 1,400, 700, 0)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isHighlighted = i == 4; // Friday
                    return Container(
                      width: 10,
                      height: heights[i],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isHighlighted
                              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                              : [const Color(0xFFC7F33B), const Color(0xFF84A618)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: isHighlighted
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Right Y-axis labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('2,100', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                SizedBox(height: 12),
                Text('1,400', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                SizedBox(height: 12),
                Text('700', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                SizedBox(height: 12),
                Text('0', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Day labels
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((d) {
                  return SizedBox(
                    width: 14,
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Color(0xFF8E9BAE),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 36), // Align with Y axis
          ],
        ),
      ],
    );
  }

  Widget _buildSmoothLineChart() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: CustomPaint(
                  painter: _KaloLinePainter(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('74', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                Text('73', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                Text('72', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
                Text('71', style: TextStyle(color: Color(0xFF566171), fontSize: 9)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((d) {
                  return SizedBox(
                    width: 14,
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Color(0xFF8E9BAE),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ],
    );
  }
}

class _KaloLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFFC7F33B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFC7F33B)
      ..style = PaintingStyle.fill;

    // 7 sample points stepping down gracefully
    final points = [
      Offset(size.width * 0.08, size.height * 0.2),
      Offset(size.width * 0.22, size.height * 0.25),
      Offset(size.width * 0.36, size.height * 0.3),
      Offset(size.width * 0.50, size.height * 0.55),
      Offset(size.width * 0.64, size.height * 0.65),
      Offset(size.width * 0.78, size.height * 0.72),
      Offset(size.width * 0.92, size.height * 0.85),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintLine);

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = const Color(0xFFC7F33B).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
