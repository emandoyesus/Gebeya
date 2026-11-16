import 'package:flutter/material.dart';
import 'market_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final isAmharic = ref.watch(isAmharicProvider);
    final categories = ItemCategory.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isAmharic ? 'ምድቦች' : 'Shop by category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: Text(isAmharic ? 'ሁሉንም ይመልከቱ' : 'Browse all'),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const FractionallySizedBox(
                    heightFactor: 0.85,
                    child: _CategoryPicker(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                selected: category == selected,
                label: Text(isAmharic ? category.labelAm : category.labelEn),
                avatar: Icon(category.icon, size: 18),
                onSelected: (_) {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(selectedCategoryProvider.notifier).state = category;
                },
              );
            },
          ),
        ),
        if (selected != ItemCategory.all)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(isAmharic
                  ? '${selected.labelAm} — ሁሉንም አሳይ'
                  : '${selected.labelEn} — Show all items'),
              onPressed: () {
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(selectedCategoryProvider.notifier).state = ItemCategory.all;
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryPicker extends ConsumerStatefulWidget {
  const _CategoryPicker();

  @override
  ConsumerState<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<_CategoryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isAmharic = ref.watch(isAmharicProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final items = ref.watch(itemsProvider).valueOrNull;
    final categories = ItemCategory.values.where((category) =>
        category.labelEn.toLowerCase().contains(_query) ||
        category.labelAm.contains(_query)).toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isAmharic ? 'ሁሉም ምድቦች' : 'All categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: isAmharic ? 'ዝጋ' : 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: isAmharic ? 'ምድቦችን ፈልግ' : 'Find a category',
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() {
                _query = value.trim().toLowerCase();
              }),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: categories.isEmpty
                  ? Center(child: Text(isAmharic
                      ? 'ምንም ምድብ አልተገኘም' : 'No matching categories'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final count = items?.where((item) =>
                            category == ItemCategory.all ||
                            item.category == category).length;
                        return ListTile(
                          leading: MarketImage(category: category, width: 48, height: 48),
                          title: Text(isAmharic ? category.labelAm : category.labelEn),
                          subtitle: count == null ? null : Text(
                            isAmharic ? '$count እቃዎች' : '$count items',
                          ),
                          selected: selected == category,
                          trailing: selected == category
                              ? const Icon(Icons.check_circle_rounded) : null,
                          onTap: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = category;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
