import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import 'package:spendflow_app/repositories/expense_repository.dart';
import 'package:spendflow_app/models/expense.dart';
import 'package:spendflow_app/features/calendar/providers/calendar_providers.dart';
import 'dart:io';
import 'package:spendflow_app/features/analysis/providers/analysis_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '支出カレンダー',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // カレンダー本体
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFCAE8E9), width: 1.5),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                ref.read(selectedDateProvider.notifier).state = selectedDay;
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.lightAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // 選択した日の支出リスト（ここにDBから取得したデータを表示）
          Expanded(child: _buildExpenseList()),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    final asyncExpenses = ref.watch(dailyExpensesProvider);

    return asyncExpenses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(
            child: Text('この日の記録はありません', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final item = expenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFCAE8E9), width: 1),
              ),
              child: ListTile(
                onTap: () => _showEditDialog(context, ref, item),

                leading: item.receiptImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.receiptImagePath!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: AppColors.lightAccent,
                        child: const Text('💰'), //本当ならここは各項目のアイコン
                      ),
                title: Text(
                  item.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                subtitle: Text(item.type == 'fixed' ? '固定費' : '変動費'),
                trailing: Text(
                  '¥${item.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A415B),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    // 現在の金額を最初から入力欄に入れておく
    final amountController = TextEditingController(
      text: expense.amount.toInt().toString(),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFCAE8E9), width: 2),
          ),
          title: const Text(
            '金額の修正',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '新しい金額',
              prefixText: '¥ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // DBから削除
                await ref
                    .read(expenseRepositoryProvider)
                    .deleteExpense(expense.id);

                // 画面を最新に更新
                ref.invalidate(dailyExpensesProvider);
                ref.invalidate(monthlyExpensesProvider);

                if (context.mounted) {
                  Navigator.pop(context); // ダイアログを閉じる
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('削除しました')));
                }
              },
              child: const Text(
                '削除',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AB2B5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // 入力された文字を数字に変換
                final newAmount = int.tryParse(amountController.text);
                if (newAmount != null && newAmount > 0) {
                  // 1. 金額を上書き
                  expense.amount = newAmount;

                  // 2. DBに保存（Isarは同じIDなら自動で「上書き更新」になります）
                  await ref
                      .read(expenseRepositoryProvider)
                      .saveExpense(expense);

                  // 3. 画面のデータを最新にリセット
                  ref.invalidate(dailyExpensesProvider);
                  ref.invalidate(monthlyExpensesProvider);

                  if (context.mounted) {
                    Navigator.pop(context); // ダイアログを閉じる
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('金額を修正しました！'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
