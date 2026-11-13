import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/categories.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    final categories = ItemCategory.values;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final title = isAmharic ? category.nameAm(context) : category.nameEn(context);

          return FilterChip(
            selected: isSelected,
            label: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
            avatar: Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF136A36),
            checkmarkColor: Colors.white,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
          );
        },
      ),
    );
  }
}
