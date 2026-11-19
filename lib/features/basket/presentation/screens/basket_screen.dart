import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/basket/data/basket_item_model.dart';
import 'package:gebeya/features/basket/presentation/basket_provider.dart';
import 'package:gebeya/features/basket/presentation/widgets/basket_stepper.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/items/presentation/widgets/market_image.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class BasketScreen extends ConsumerWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final basketItems = ref.watch(basketItemsListProvider);
    final totalCount = ref.watch(basketTotalCountProvider);
    final totalPrice = ref.watch(basketTotalPriceProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF8FAFC)),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              isAmharic ? 'የገበያ ቅርጫት' : 'Market Basket',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
              ),
            ),
            if (totalCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2D15A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C0E12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (basketItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _showClearConfirmation(context, ref, isAmharic);
              },
              icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: Color(0xFFE57373)),
              label: Text(
                isAmharic ? 'አጽዳ' : 'Clear',
                style: const TextStyle(color: Color(0xFFE57373), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: basketItems.isEmpty
          ? _buildEmptyState(context, isAmharic)
          : CustomScrollView(
              slivers: [
                // Smart Market Optimizer Recommendation Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _buildSmartMarketBanner(context, ref, isAmharic, selectedMarket?.nameEn ?? 'Merkato'),
                  ),
                ),

                // Section Title: Items in Basket
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAmharic ? 'የተመረጡ እቃዎች' : 'Selected Groceries',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9AA7B8),
                          ),
                        ),
                        Text(
                          isAmharic ? '$totalCount እቃዎች' : '$totalCount items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB2D15A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Basket Items List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = basketItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildBasketItemCard(context, ref, item, isAmharic),
                        );
                      },
                      childCount: basketItems.length,
                    ),
                  ),
                ),

                // Order & Estimated Bill Breakdown
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: _buildCostSummaryCard(isAmharic, totalCount, totalPrice),
                  ),
                ),

                // Quick Action Buttons: Share & Find Markets
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      children: [
                        // Share Shopping List (Telegram / Clipboard)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB2D15A),
                              foregroundColor: const Color(0xFF0C0E12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              _shareShoppingList(context, basketItems, totalPrice, isAmharic);
                            },
                            icon: const Icon(Icons.share_rounded, size: 20),
                            label: Text(
                              isAmharic ? 'የገበያ ዝርዝር አጋራ / ቅዳ' : 'Share / Copy Shopping List',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Compare Across Markets
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF8FAFC),
                              side: const BorderSide(color: Color(0xFF262C36)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => context.push('/markets'),
                            icon: const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFFB2D15A)),
                            label: Text(
                              isAmharic ? 'የገበያ ቦታዎችን ይመልከቱ' : 'Explore Markets & Locations',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSmartMarketBanner(
    BuildContext context,
    WidgetRef ref,
    bool isAmharic,
    String marketName,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2818),
            const Color(0xFF16191E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB2D15A).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFB2D15A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFFB2D15A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAmharic ? 'የዋጋ ቆጣቢ ገበያ' : 'Best Market Estimate',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB2D15A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232A16),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAmharic ? '10-15% ቅናሽ' : '~15% Save',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB2D15A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isAmharic
                      ? '$marketName ውስጥ መግዛት ከሌሎች ቦታዎች ከ10% በላይ ይቆጥባል!'
                      : 'Buying these together at $marketName offers the best wholesale rates!',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E9BAE),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketItemCard(
    BuildContext context,
    WidgetRef ref,
    BasketItem basketItem,
    bool isAmharic,
  ) {
    final item = basketItem.item;
    final unit = item.localizedStandardUnit(isAmharic);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16191E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF262C36), width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail Image
          InkWell(
            onTap: () => context.push('/item/${item.id}'),
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MarketImage(
                category: item.category,
                imageUrl: item.displayImageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details: Name, Unit Price, Line Total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.push('/item/${item.id}'),
                  child: Text(
                    item.localizedName(isAmharic),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF8FAFC),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ETB ${basketItem.unitPrice.toStringAsFixed(0)} / $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E9BAE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ETB ${basketItem.totalPrice.toStringAsFixed(basketItem.totalPrice.truncateToDouble() == basketItem.totalPrice ? 0 : 2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB2D15A),
                  ),
                ),
              ],
            ),
          ),

          // Stepper Controls
          BasketStepper(
            item: item,
            unitPrice: basketItem.unitPrice,
            unit: basketItem.unit,
            style: BasketStepperStyle.standard,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummaryCard(
    bool isAmharic,
    int totalCount,
    double totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16191E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF262C36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAmharic ? 'የዋጋ ማጠቃለያ' : 'Estimated Bill Breakdown',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            isAmharic ? 'የእቃዎች ድምር' : 'Items subtotal',
            'ETB ${totalPrice.toStringAsFixed(totalPrice.truncateToDouble() == totalPrice ? 0 : 2)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            isAmharic ? 'የገበያ ቦርሳ / ክፍያ' : 'Market fee & bag',
            isAmharic ? 'ነፃ (0.00)' : 'Free (0.00)',
            isGreen: true,
          ),
          const Divider(color: Color(0xFF262C36), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAmharic ? 'ጠቅላላ የሚገመት ዋጋ' : 'Total Estimated Cost',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              Text(
                'ETB ${totalPrice.toStringAsFixed(totalPrice.truncateToDouble() == totalPrice ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB2D15A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF8E9BAE),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFFB2D15A) : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isAmharic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 42,
                color: Color(0xFF8E9BAE),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAmharic ? 'ቅርጫትዎ ባዶ ነው' : 'Your market basket is empty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAmharic
                  ? 'ከገበያ መረጃው ላይ የሚፈልጓቸውን እቃዎች በመምረጥ የዋጋ ዝርዝርዎን ያዘጋጁ።'
                  : 'Add fresh groceries and essentials from local markets to plan your budget and compare prices.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E9BAE),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB2D15A),
                foregroundColor: const Color(0xFF0C0E12),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: Text(
                isAmharic ? 'እቃዎችን ያስሱ' : 'Browse Groceries',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref, bool isAmharic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAmharic ? 'ቅርጫቱን ማጽዳት ይፈልጋሉ?' : 'Clear Market Basket?',
          style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAmharic
              ? 'በቅርጫቱ ውስጥ ያሉ ሁሉም እቃዎች ይወገዳሉ።'
              : 'All items will be removed from your shopping basket.',
          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAmharic ? 'ይቅር' : 'Cancel', style: const TextStyle(color: Color(0xFF8E9BAE))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
            onPressed: () {
              ref.read(basketProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: Text(isAmharic ? 'አጽዳ' : 'Clear All'),
          ),
        ],
      ),
    );
  }

  void _shareShoppingList(
    BuildContext context,
    List<BasketItem> items,
    double totalPrice,
    bool isAmharic,
  ) {
    final buffer = StringBuffer();
    if (isAmharic) {
      buffer.writeln('🛒 የገበያ ዝርዝር (Gebeya Shopping Basket)');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      for (final b in items) {
        final unit = b.item.localizedStandardUnit(true);
        buffer.writeln('• ${b.item.nameAm} x ${b.quantity} $unit = ${b.totalPrice.toStringAsFixed(0)} ብር');
      }
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('ጠቅላላ ግምት: ${totalPrice.toStringAsFixed(0)} ብር');
      buffer.writeln('የተዘጋጀው በ: ገበያ (Gebeya Market Price Tracker)');
    } else {
      buffer.writeln('🛒 Market Shopping List (Gebeya)');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      for (final b in items) {
        final unit = b.item.localizedStandardUnit(false);
        buffer.writeln('• ${b.item.nameEn} x ${b.quantity} $unit = ETB ${b.totalPrice.toStringAsFixed(0)}');
      }
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('Total Estimated Cost: ETB ${totalPrice.toStringAsFixed(0)}');
      buffer.writeln('Created with: Gebeya Price Tracker');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16191E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFB2D15A)),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFB2D15A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAmharic ? 'የገበያ ዝርዝሩ ተገልብጧል (Clipboard)' : 'Shopping list copied to clipboard!',
                style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
