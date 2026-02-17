import 'package:isar/isar.dart';

// この行が重要です。build_runnerがこの名前のファイルを生成します。
part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement; // データを一意に識別するID

  late int amount; // 金額

  @Index() // カレンダーでの検索を高速化するためにインデックスを付与
  late DateTime date;

  late String category; // カテゴリ名（例：食費、住居費）

  late String type; // 種類（fixed: 固定費, variable: 変動費）

  late String frequency; // 頻度（monthly: 毎月, irregular: 不定期）

  String? receiptImagePath; // レシート画像の保存パス（任意）

  bool isPending = false; // 未入力（レシート撮影のみ）フラグ
}
