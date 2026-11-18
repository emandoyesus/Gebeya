import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  String _searchQuery = '';
  String? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        title: Text(
          isAmharic ? 'የኢትዮጵያ ገበያዎች' : 'Ethiopian Markets',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF8FAFC)),
        ),
      ),
      body: marketsAsync.when(
        data: (markets) {
          final query = _searchQuery.trim().toLowerCase();
          final regions = markets
              .map((m) => m.region ?? m.city)
              .where((r) => r.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filteredMarkets = markets.where((market) {
            final matchesRegion = _selectedRegion == null ||
                (market.region == _selectedRegion || market.city == _selectedRegion);
            if (!matchesRegion) return false;

            if (query.isEmpty) return true;
            return market.nameEn.toLowerCase().contains(query) ||
                market.nameAm.contains(query) ||
                market.city.toLowerCase().contains(query) ||
                (market.subcity?.toLowerCase().contains(query) ?? false) ||
                (market.region?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: InputDecoration(
                    hintText: isAmharic
                        ? 'ገበያ፣ ከተማ ወይም ክልል ይፈልጉ...'
                        : 'Search market, city or region...',
                    hintStyle: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB2D15A), size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF8E9BAE)),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF16191E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF262C36)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF262C36)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFB2D15A), width: 1.5),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Region filter chips
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      selected: _selectedRegion == null,
                      selectedColor: const Color(0xFFB2D15A),
                      backgroundColor: const Color(0xFF16191E),
                      label: Text(
                        isAmharic ? 'ሁሉም ክልሎች' : 'All Regions',
                        style: TextStyle(
                          color: _selectedRegion == null ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                          fontWeight: _selectedRegion == null ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedRegion = null),
                    ),
                    const SizedBox(width: 8),
                    ...regions.map((region) {
                      final isSel = _selectedRegion == region;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSel,
                          selectedColor: const Color(0xFFB2D15A),
                          backgroundColor: const Color(0xFF16191E),
                          label: Text(
                            region,
                            style: TextStyle(
                              color: isSel ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          onSelected: (_) => setState(() => _selectedRegion = isSel ? null : region),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Markets list
              Expanded(
                child: filteredMarkets.isEmpty
                    ? Center(
                        child: Text(
                          isAmharic ? 'ከፍለጋው ጋር የሚዛመድ ገበያ አልተገኘም' : 'No markets matched your search',
                          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filteredMarkets.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final market = filteredMarkets[index];
                          final isCurrent = selectedMarket?.id == market.id;

                          return Container(
                            decoration: BoxDecoration(
                              color: isCurrent ? const Color(0xFF1E232B) : const Color(0xFF16191E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isCurrent ? const Color(0xFFB2D15A) : const Color(0xFF262C36),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isCurrent ? const Color(0xFF232A16) : const Color(0xFF0C0E12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isCurrent ? const Color(0xFFB2D15A) : const Color(0xFF262C36)),
                                ),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: isCurrent ? const Color(0xFFB2D15A) : const Color(0xFF8E9BAE),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      market.localizedName(isAmharic),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF8FAFC)),
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB2D15A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAmharic ? 'የተመረጠ' : 'Selected',
                                        style: const TextStyle(
                                          color: Color(0xFF0C0E12),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      market.localizedLocation(isAmharic),
                                      style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
                                    ),
                                    if (market.latitude != null && market.longitude != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9AA7B8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${market.latitude?.toStringAsFixed(3)}, ${market.longitude?.toStringAsFixed(3)}',
                                            style: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E9BAE)),
                              onTap: () {
                                ref.read(selectedMarketProvider.notifier).state = market;
                                context.go('/');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFB2D15A))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAmharic ? 'የገበያ መረጃዎችን መጫን አልተቻለም' : 'Could not load markets.',
                style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 15),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB2D15A),
                  foregroundColor: const Color(0xFF0C0E12),
                ),
                onPressed: () => ref.invalidate(marketsProvider),
                child: Text(isAmharic ? 'እንደገና ሞክር' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
