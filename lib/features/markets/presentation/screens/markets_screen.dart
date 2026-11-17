import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketsProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        title: Text(
          isAmharic ? 'የአዲስ አበባ ገበያዎች' : 'Addis Ababa Markets',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF8FAFC)),
        ),
      ),
      body: marketsAsync.when(
        data: (markets) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: markets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final market = markets[index];
              final isCurrent = selectedMarket?.id == market.id;

              return Container(
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF1E232B) : const Color(0xFF16191E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFC7F33B) : const Color(0xFF262C36),
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
                      border: Border.all(color: isCurrent ? const Color(0xFFC7F33B) : const Color(0xFF262C36)),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: isCurrent ? const Color(0xFFC7F33B) : const Color(0xFF8E9BAE),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        market.localizedName(isAmharic),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF8FAFC)),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7F33B),
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
                          '${market.city} • ${market.subcity ?? ""}',
                          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF566171)),
                            const SizedBox(width: 4),
                            Text(
                              '${market.latitude?.toStringAsFixed(3)}, ${market.longitude?.toStringAsFixed(3)}',
                              style: const TextStyle(color: Color(0xFF566171), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF566171)),
                  onTap: () {
                    ref.read(selectedMarketProvider.notifier).state = market;
                    context.go('/');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFC7F33B))),
        error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
