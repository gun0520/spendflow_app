import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import '../providers/input_state_provider.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  void _updateToggle(WidgetRef ref, {String? newFreq, String? newType}) {
    final currentFreq = ref.read(selectedFrequencyProvider);
    final currentType = ref.read(selectedTypeProvider);

    final freq = newFreq ?? currentFreq;
    final type = newType ?? currentType;

    if (newFreq != null)
      ref.read(selectedFrequencyProvider.notifier).state = freq;
    if (newType != null) ref.read(selectedTypeProvider.notifier).state = type;

    final newCategories = categoryMap['${freq}_${type}'] ?? [];
    final currentCat = ref.read(selectedCategoryProvider);

    if (!newCategories.contains(currentCat) && newCategories.isNotEmpty) {
      ref.read(selectedCategoryProvider.notifier).state = newCategories.first;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final freq = ref.watch(selectedFrequencyProvider);
    final type = ref.watch(selectedTypeProvider);

    final currentCategories = categoryMap['${freq}_${type}'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 頻度トグル
          _buildSectionLabel('頻度'),
          Row(
            children: [
              _buildToggleBtn(
                '毎月',
                freq == '毎月',
                () => _updateToggle(ref, newFreq: '毎月'),
              ),
              const SizedBox(width: 12),
              _buildToggleBtn(
                '不定期',
                freq == '不定期',
                () => _updateToggle(ref, newFreq: '不定期'),
              ),
            ],
          ),

          // 2. 種類トグル
          _buildSectionLabel('種類'),
          Row(
            children: [
              _buildToggleBtn(
                '固定費',
                type == '固定費',
                () => _updateToggle(ref, newType: '固定費'),
              ),
              const SizedBox(width: 12),
              _buildToggleBtn(
                '変動費',
                type == '変動費',
                () => _updateToggle(ref, newType: '変動費'),
              ),
            ],
          ),

          // 3. カテゴリグリッド
          _buildSectionLabel('カテゴリ'),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // スクロールは親に任せる
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.8,
              ),
              itemCount: currentCategories.length,
              itemBuilder: (context, index) {
                final category = currentCategories[index];
                return _buildCategoryItem(
                  category,
                  selectedCategory == category,
                  () => ref.read(selectedCategoryProvider.notifier).state =
                      category,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UIパーツ群 (デザイン用コンポーネント)
  // ==========================================

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A415B).withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3AB2B5) : const Color(0xFFCAE8E9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? Colors.white : const Color(0xFF1A415B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F3E7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3AB2B5)
                : const Color(0xFFCAE8E9),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A415B),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
