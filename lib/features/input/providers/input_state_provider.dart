import 'package:flutter_riverpod/flutter_riverpod.dart';

// 現在選択されているカテゴリを管理（初期値は未分類など）
final selectedCategoryProvider = StateProvider<String>((ref) => '食費');

const categories = [
  {'name': '食費', 'icon': '🍽️'},
  {'name': '日用品', 'icon': '🛒'},
  {'name': '交通費', 'icon': '🚆'},
  {'name': '美容・服', 'icon': '✂️'},
  {'name': '交際費', 'icon': '🍻'},
  {'name': '娯楽', 'icon': '🎮'},
  {'name': 'その他', 'icon': '💰'},
];

// 種類（固定費/変動費）を管理
final selectedTypeProvider = StateProvider<String>((ref) => 'variable');

// 頻度（毎月/不定期）を管理
final selectedFrequencyProvider = StateProvider<String>((ref) => 'monthly');
