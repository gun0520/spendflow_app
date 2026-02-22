import 'package:flutter_riverpod/flutter_riverpod.dart';

// 頻度（毎月/不定期）を管理
final selectedFrequencyProvider = StateProvider<String>((ref) => '毎月');

// 種類（固定費/変動費）を管理
final selectedTypeProvider = StateProvider<String>((ref) => '固定費');

// 現在選択されているカテゴリを管理（初期値は毎月・固定費の最初の項目）
final selectedCategoryProvider = StateProvider<String>((ref) => '🏠 住居費');

// 画像のパス
final receiptImageProvider = StateProvider<String?>((ref) => null);

// ★ カテゴリの区分分け定義マップ
final Map<String, List<String>> categoryMap = {
  '毎月_固定費': [
    '🏠 住居費',
    '💧 水道光熱費',
    '🏥 社会保険料',
    '🛡️ 生命保険料',
    '📱 通信費',
    '🎓 教育費',
    '🎵 サブスク費',
  ],
  '毎月_変動費': [
    '🍽️ 食費',
    '👕 被服費',
    '🏥 医療費',
    '⛽ ガソリン費',
    '🧻 日用品費',
    '✂️ 美容費',
    '🚃 交通費',
  ],
  '不定期_固定費': ['🏛️ 税金', '🔥 火災保険料', '🚗 自動車保険料', '💳 年会費', '🚘 車検費', '🎓 教育費'],
  '不定期_変動費': [
    '📺 家電、家具',
    '📝 諸経費',
    '✈️ 旅行',
    '🎀 冠婚葬祭',
    '🎒 学費',
    '💊 治療費',
    '📦 引っ越し',
  ],
};
