import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/features/basket/presentation/basket_provider.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

enum BasketStepperStyle {
  compact, // For grid cards
  standard, // For list cards & detail screens
}

class BasketStepper extends ConsumerWidget {
  final ItemModel item;
  final double? unitPrice;
  final String? unit;
  final BasketStepperStyle style;

  const BasketStepper({
    super.key,
    required this.item,
    this.unitPrice,
    this.unit,
    this.style = BasketStepperStyle.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final quantity = ref.watch(basketItemQuantityProvider(item.id));
    final notifier = ref.read(basketProvider.notifier);

    final isCompact = style == BasketStepperStyle.compact;
    final height = isCompact ? 28.0 : 34.0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: quantity == 0
          ? _buildAddButton(
              key: const ValueKey('add_btn'),
              context: context,
              isAmharic: isAmharic,
              height: height,
              isCompact: isCompact,
              onTap: () {
                notifier.addItem(
                  item,
                  quantity: 1,
                  unit: unit,
                  unitPrice: unitPrice,
                );
              },
            )
          : _buildStepper(
              key: const ValueKey('stepper'),
              context: context,
              quantity: quantity,
              height: height,
              isCompact: isCompact,
              onDecrement: () => notifier.decrementItem(item.id),
              onIncrement: () => notifier.addItem(
                item,
                quantity: 1,
                unit: unit,
                unitPrice: unitPrice,
              ),
            ),
    );
  }

  Widget _buildAddButton({
    required Key key,
    required BuildContext context,
    required bool isAmharic,
    required double height,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: isAmharic ? 'ወደ ቅርጫት ጨምር' : 'Add to basket',
      child: Material(
        key: key,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2618), // Rich forest dark green
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFB2D15A).withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 15,
                  color: Color(0xFFB2D15A),
                ),
                SizedBox(width: isCompact ? 2 : 4),
                Text(
                  isAmharic ? 'ጨምር' : 'ADD',
                  style: TextStyle(
                    fontSize: isCompact ? 10.5 : 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFFB2D15A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper({
    required Key key,
    required BuildContext context,
    required int quantity,
    required double height,
    required bool isCompact,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFB2D15A), // High contrast neon lime
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB2D15A).withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrement Button
            _buildIconButton(
              icon: quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
              isCompact: isCompact,
              onTap: onDecrement,
            ),
            // Quantity Display with AnimatedSwitcher
            Container(
              constraints: BoxConstraints(minWidth: isCompact ? 18 : 24),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  key: ValueKey<int>(quantity),
                  '$quantity',
                  style: TextStyle(
                    color: const Color(0xFF0C0E12), // Pitch black on lime
                    fontSize: isCompact ? 12 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Increment Button
            _buildIconButton(
              icon: Icons.add_rounded,
              isCompact: isCompact,
              onTap: onIncrement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 5 : 8,
          vertical: 4,
        ),
        child: Icon(
          icon,
          size: isCompact ? 14 : 16,
          color: const Color(0xFF0C0E12),
        ),
      ),
    );
  }
}
