import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

class MarketSelectorSheet extends ConsumerStatefulWidget {
  const MarketSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16191E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: MarketSelectorSheet(),
      ),
    );
  }

  @override
  ConsumerState<MarketSelectorSheet> createState() => _MarketSelectorSheetState();
}

class _MarketSelectorSheetState extends ConsumerState<MarketSelectorSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    return SafeArea(
      child: Container(
        color: const Color(0xFF16191E),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262C36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAmharic ? 'የኢትዮጵያ ገበያ ይምረጡ' : 'Select Market in Ethiopia',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
            ),
            const SizedBox(height: 4),
            Text(
              isAmharic ? 'ዋጋዎችን ለማየት የሚፈልጉትን የገበያ ቦታ ወይም ከተማ ይምረጡ' : 'Choose a local market or city across Ethiopia',
              style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
            ),
            const SizedBox(height: 12),
            // Search field
            TextField(
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: isAmharic ? 'ገበያ ወይም ከተማ ይፈልጉ...' : 'Search market or city...',
                hintStyle: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB2D15A), size: 20),
                filled: true,
                fillColor: const Color(0xFF0C0E12),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF262C36))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF262C36))),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: marketsAsync.when(
                data: (markets) {
                  final query = _search.trim().toLowerCase();
                  final filtered = markets.where((m) {
                    if (query.isEmpty) return true;
                    return m.nameEn.toLowerCase().contains(query) ||
                        m.nameAm.contains(query) ||
                        m.city.toLowerCase().contains(query) ||
                        (m.region?.toLowerCase().contains(query) ?? false) ||
                        (m.subcity?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        isAmharic ? 'ምንም ገበያ አልተገኘም' : 'No markets found',
                        style: const TextStyle(color: Color(0xFF8E9BAE)),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF262C36)),
                    itemBuilder: (context, index) {
                      final market = filtered[index];
                      final isSelected = selectedMarket?.id == market.id;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? const Color(0xFFB2D15A) : const Color(0xFF1E232B),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: isSelected ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          market.localizedName(isAmharic),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFFB2D15A) : const Color(0xFFF8FAFC),
                          ),
                        ),
                        subtitle: Text(
                          market.localizedLocation(isAmharic),
                          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFFB2D15A))
                            : null,
                        onTap: () {
                          ref.read(selectedMarketProvider.notifier).state = market;
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: Color(0xFFB2D15A)),
                  ),
                ),
                error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
