import 'package:flutter_riverpod/flutter_riverpod.dart';

// 現在選択されているカテゴリを管理（初期値は未分類など）
final selectedCategoryProvider = StateProvider<String>((ref) => '食費');

// 種類（固定費/変動費）を管理
final selectedTypeProvider = StateProvider<String>((ref) => 'variable');

// 頻度（毎月/不定期）を管理
final selectedFrequencyProvider = StateProvider<String>((ref) => 'monthly');
