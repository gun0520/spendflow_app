import 'package:spendflow_app/features/calendar/providers/calendar_providers.dart';
import 'package:spendflow_app/features/analysis/providers/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/repositories/expense_repository.dart';
import 'package:spendflow_app/models/expense.dart';
import '../providers/amount_provider.dart';
import '../providers/input_state_provider.dart';
import 'package:spendflow_app/constants/app_colors.dart';

class CustomNumpad extends ConsumerWidget {
  const CustomNumpad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態を操作するための notifier
    final amountNotifier = ref.read(amountProvider.notifier);

    void onKeyTap(String val) {
      if (val == 'C') {
        amountNotifier.clear();
      } else if (val == '00') {
        amountNotifier.pushDoubleZero();
      } else {
        amountNotifier.pushNumber(int.parse(val));
      }
    }

    return Container(
      // 下部に少し余白を持たせて、画面端ギリギリになるのを防ぐ
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: 24.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFCAE8E9), width: 1)),
      ),
      child: Column(
        children: [
          // 1. テンキー部分 (Expandedで余ったスペースを自動で均等割り当て)
          Expanded(
            child: Column(
              children: [
                _buildRow(['1', '2', '3'], onKeyTap),
                _buildRow(['4', '5', '6'], onKeyTap),
                _buildRow(['7', '8', '9'], onKeyTap),
                _buildRow(['00', '0', 'C'], onKeyTap),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. 保存ボタン (高さを固定し、フラットでモダンなデザインに)
          SizedBox(
            width: double.infinity,
            height: 56, // コンパクトかつ押しやすい高さ
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0, // ★ 影を消してフラットデザインに
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                // 1. 現在の入力値を取得
                final amount = ref.read(amountProvider);
                if (amount <= 0) return; // 0円は保存しない

                final type = ref.read(selectedTypeProvider);
                final freq = ref.read(selectedFrequencyProvider);
                final selectedCategory = ref.read(selectedCategoryProvider);
                final receiptPath = ref.read(receiptImageProvider);

                // 2. 保存するデータモデルを作成
                final expense = Expense()
                  ..amount = amount
                  ..date =
                      DateTime.now() // 今日の日付
                  ..category = selectedCategory
                  ..type = type
                  ..frequency = freq
                  ..isPending = false
                  ..receiptImagePath = receiptPath;

                // 3. リポジトリ経由でDBに保存
                await ref.read(expenseRepositoryProvider).saveExpense(expense);

                ref.invalidate(dailyExpensesProvider);
                ref.invalidate(monthlyExpensesProvider);

                // 4. 入力値をリセット
                ref.read(amountProvider.notifier).reset();
                ref.read(receiptImageProvider.notifier).state = null;

                // 5. 保存完了のフィードバック
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('保存しました！'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  // TODO: カレンダー画面へ戻る、などの遷移処理
                }
              },
              child: const Text(
                '保存して完了',
                style: TextStyle(
                  fontSize: 16, // 少し控えめなフォントサイズにしてモダンに
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1行分の構築 ---
  Widget _buildRow(List<String> keys, Function(String) onKeyTap) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key, onKeyTap)).toList(),
      ),
    );
  }

  // --- 1ボタン分の構築 ---
  Widget _buildKey(String label, Function(String) onKeyTap) {
    // アクションキー（00やC）は少しデザインを変えて視認性を上げる
    final isAction = label == 'C' || label == '00';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0), // ボタン間の隙間
        child: InkWell(
          onTap: () => onKeyTap(label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAction ? const Color(0xFFF3F3E7) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24, // ミニマルでスッキリしたサイズ
                fontWeight: isAction ? FontWeight.w600 : FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
