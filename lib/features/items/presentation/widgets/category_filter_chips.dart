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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAmharic ? 'ሁሉንም' : 'See all',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB2D15A),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFB2D15A)),
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
                      AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        scale: isSelected ? 1.06 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFB2D15A)
                                : const Color(0xFF16191E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB2D15A)
                                  : const Color(0xFF262C36),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFB2D15A).withValues(alpha: 0.35),
                                      blurRadius: 12,
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
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFB2D15A) : const Color(0xFF8E9BAE),
                        ),
                        child: Text(
                          isAmharic ? category.labelAm : category.labelEn,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: selected != ItemCategory.all
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232A16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB2D15A).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isAmharic ? selected.labelAm : selected.labelEn,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB2D15A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: isAmharic ? 'ምድብ አጽዳ' : 'Clear category',
                              onPressed: () {
                                ref.read(searchQueryProvider.notifier).state = '';
                                ref.read(selectedCategoryProvider.notifier).state = ItemCategory.all;
                              },
                              icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFB2D15A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
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
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCategoryProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    final filtered = ItemCategory.values.where((c) {
      if (_search.trim().isEmpty) return true;
      final q = _search.trim().toLowerCase();
      return c.labelEn.toLowerCase().contains(q) || c.labelAm.contains(q);
    }).toList();

    return SafeArea(
      child: Container(
        color: const Color(0xFF16191E),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    isAmharic ? 'ሁሉንም ምድቦች ይምረጡ' : 'All Categories',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9BAE)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: isAmharic ? 'ምድብ ፈልግ...' : 'Search categories...',
                hintStyle: const TextStyle(color: Color(0xFF9AA7B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB2D15A)),
                filled: true,
                fillColor: const Color(0xFF0C0E12),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        isAmharic ? 'ምንም ምድብ አልተገኘም' : 'No categories found',
                        style: const TextStyle(color: Color(0xFF8E9BAE)),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final category = filtered[index];
                        final isSelected = category == selected;

                        return InkWell(
                          onTap: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = category;
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFB2D15A) : const Color(0xFF1E232B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFB2D15A) : const Color(0xFF262C36),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  category.icon,
                                  size: 28,
                                  color: isSelected ? const Color(0xFF0C0E12) : const Color(0xFF8E9BAE),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    isAmharic ? category.labelAm : category.labelEn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? const Color(0xFFB2D15A) : const Color(0xFFF8FAFC),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
