import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

class MarketSelectorSheet extends ConsumerWidget {
  const MarketSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16191E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const MarketSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketsProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    return SafeArea(
      child: Container(
        color: const Color(0xFF16191E),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              isAmharic ? 'ገበያ ይምረጡ' : 'Select Market',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
            ),
            const SizedBox(height: 6),
            Text(
              isAmharic ? 'ዋጋዎችን ለማየት የሚፈልጉትን የገበያ ቦታ ይምረጡ' : 'Choose a local market in Addis Ababa',
              style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
            ),
            const SizedBox(height: 16),
            marketsAsync.when(
              data: (markets) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: markets.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF262C36)),
                  itemBuilder: (context, index) {
                    final market = markets[index];
                    final isSelected = selectedMarket?.id == market.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? const Color(0xFFC7F33B) : const Color(0xFF1E232B),
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
                          color: isSelected ? const Color(0xFFC7F33B) : const Color(0xFFF8FAFC),
                        ),
                      ),
                      subtitle: Text(
                        '${market.city}${market.subcity != null ? ' • ${market.subcity}' : ''}',
                        style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC7F33B))
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
                  child: CircularProgressIndicator(color: Color(0xFFC7F33B)),
                ),
              ),
              error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.red))),
            ),
          ],
        ),
      ),
    );
  }
}
