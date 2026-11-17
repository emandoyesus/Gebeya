import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isAmharic ? 'ምድቦች' : 'Categories',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
              ),
              InkWell(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF16191E),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const FractionallySizedBox(
                    heightFactor: 0.85,
                    child: _CategoryPicker(),
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAmharic ? 'ሁሉንም' : 'See all',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7F33B),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFC7F33B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 94,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selected;

              return InkWell(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(selectedCategoryProvider.notifier).state = category;
                },
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFC7F33B)
                              : const Color(0xFF16191E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFC7F33B)
                                : const Color(0xFF262C36),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFC7F33B).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            category.icon,
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF0C0E12)
                                : const Color(0xFF8E9BAE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isAmharic ? category.labelAm : category.labelEn,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFC7F33B) : const Color(0xFF8E9BAE),
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selected != ItemCategory.all)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232A16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC7F33B).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAmharic ? selected.labelAm : selected.labelEn,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC7F33B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(selectedCategoryProvider.notifier).state = ItemCategory.all;
                        },
                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFC7F33B)),
                      ),
                    ],
                  ),
                ),
              ],
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
      child: Container(
        color: const Color(0xFF16191E),
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
                    isAmharic ? 'ሁሉም ምድቦች' : 'All Categories',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                  ),
                ),
                IconButton(
                  tooltip: isAmharic ? 'ዝጋ' : 'Close',
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9BAE)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: isAmharic ? 'ምድቦችን ፈልግ' : 'Find a category',
                hintStyle: const TextStyle(color: Color(0xFF566171)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC7F33B)),
                filled: true,
                fillColor: const Color(0xFF0C0E12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() {
                _query = value.trim().toLowerCase();
              }),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        isAmharic ? 'ምንም ምድብ አልተገኘም' : 'No matching categories',
                        style: const TextStyle(color: Color(0xFF8E9BAE)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final count = items?.where((item) =>
                            category == ItemCategory.all ||
                            item.category == category).length;
                        final isSelected = selected == category;

                        return ListTile(
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFC7F33B) : const Color(0xFF1E232B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category.icon,
                              color: isSelected ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            isAmharic ? category.labelAm : category.labelEn,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFFC7F33B) : const Color(0xFFF8FAFC),
                            ),
                          ),
                          subtitle: count == null ? null : Text(
                            isAmharic ? '$count እቃዎች' : '$count items',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                          ),
                          selected: isSelected,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC7F33B))
                              : null,
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
