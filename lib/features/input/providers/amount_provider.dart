import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// 金額の状態を管理するNotifier
class AmountNotifier extends Notifier<int> {
  @override
  int build() => 0; // 初期値は0円

  // 数字ボタンが押された時
  void pushNumber(int number) {
    // 最大8桁（99,999,999円）までに制限
    if (state.toString().length >= 8) return;
    state = state * 10 + number;
  }

  // 「00」ボタンが押された時
  void pushDoubleZero() {
    if (state == 0) return;
    if (state.toString().length >= 7) return; // 00を足して8桁を超えるなら無視
    state = state * 100;
  }

  // 「C（クリア/バックスペース）」が押された時
  void clear() {
    if (state == 0) return;
    // 1桁消す (例: 1280 -> 128)
    state = state ~/ 10;
  }

  // 全消去（長押し用など）
  void reset() => state = 0;

  // カンマ区切りの文字列を返す（表示用）
  String get formattedAmount {
    return NumberFormat('#,###').format(state);
  }
}

// UIからこのプロバイダを監視する
final amountProvider = NotifierProvider<AmountNotifier, int>(
  AmountNotifier.new,
);
