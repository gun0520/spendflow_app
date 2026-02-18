import 'package:spendflow_app/features/calendar/providers/calendar_providers.dart';
import 'package:spendflow_app/features/analysis/providers/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/amount_provider.dart';
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
      // ...（前回のコンテナ設定は維持）
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            children:
                [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  'C',
                  '0',
                  '00',
                ].map((val) {
                  return InkWell(
                    onTap: () => onKeyTap(val),
                    child: Center(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          // 保存ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                // 1. 現在の入力値を取得
                final amount = ref.read(amountProvider);
                if (amount <= 0) return; // 0円は保存しない

                final type = ref.read(selectedTypeProvider);
                final freq = ref.read(selectedFrequencyProvider);
                final selectedCategory = ref.read(selectedCategoryProvider);

                // 2. 保存するデータモデルを作成
                final expense = Expense()
                  ..amount = amount
                  ..date =
                      DateTime.now() // 今日の日付
                  ..category = selectedCategory
                  ..type = type
                  ..frequency = freq
                  ..isPending = false;

                // 3. リポジトリ経由でDBに保存
                await ref.read(expenseRepositoryProvider).saveExpense(expense);

                ref.invalidate(dailyExpensesProvider);
                ref.invalidate(monthlyExpensesProvider);

                // 4. 入力値をリセット
                ref.read(amountProvider.notifier).reset();

                // 5. 保存完了のフィードバック（スナックバー等）
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
                  fontSize: 18,
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
}
