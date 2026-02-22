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
  DateTime? _selectedDay = DateTime.now(); // 初期値を今日にしておくと便利です

  @override
  Widget build(BuildContext context) {
    // 月間の支出データを取得（カレンダーのマーカー判定用）
    final monthlyExpenses = ref.watch(monthlyExpensesProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 基盤色
      appBar: AppBar(
        title: const Text(
          '支出カレンダー',
          style: TextStyle(
            color: Color(0xFF1A415B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A415B)),
      ),
      body: Column(
        children: [
          // 1. カレンダー本体
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFCAE8E9), width: 1.5),
            ),
            child: TableCalendar<Expense>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

              // ★ その日の支出データを抽出してイベントとして渡す
              eventLoader: (day) {
                return monthlyExpenses
                    .where((e) => isSameDay(e.date, day))
                    .toList();
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                ref.read(selectedDateProvider.notifier).state = selectedDay;
              },

              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFCAE8E9), // 今日は薄い色で控えめに
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF3AB2B5), // 選択した日はアクセントカラー
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Color(0xFF1A415B),
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A415B),
                ),
              ),

              // ★ マーカー（・）のカスタムUI
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 6, // 日付の下の方に配置
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD1C58C), // マーカーはゴールド色で上品に
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. 選択した日の支出リスト
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

            // ★ カテゴリ文字列（例: "🏠 住居費"）から絵文字だけを抽出
            final String emojiIcon = item.category.contains(' ')
                ? item.category.split(' ').first
                : '💰'; // 万が一絵文字がない場合のフォールバック

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFCAE8E9), width: 1),
              ),
              child: ListTile(
                onTap: () => _showEditBottomSheet(context, ref, item),

                // ★ アイコンの動的表示
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
                        backgroundColor: const Color(0xFFF3F3E7), // 薄い背景
                        child: Text(
                          emojiIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),

                title: Text(
                  item.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A415B),
                  ),
                ),

                // ★ サブタイトルを「頻度・種類」の組み合わせに
                subtitle: Text(
                  '${item.frequency}・${item.type}', // 例：「毎月・固定費」
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

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

  Future<void> _showEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の高さを柔軟に調整するため
      backgroundColor: Colors.transparent, // 角丸を綺麗に見せるため透明に
      builder: (context) {
        // このファイルの下部で定義する専用のテンキーWidgetを呼び出す
        return _EditExpenseNumpad(expense: expense);
      },
    );
  }
}

class _EditExpenseNumpad extends ConsumerStatefulWidget {
  final Expense expense;
  const _EditExpenseNumpad({required this.expense});

  @override
  ConsumerState<_EditExpenseNumpad> createState() => _EditExpenseNumpadState();
}

class _EditExpenseNumpadState extends ConsumerState<_EditExpenseNumpad> {
  late String amountStr;

  @override
  void initState() {
    super.initState();
    // 最初に現在の金額をセットしておく
    amountStr = widget.expense.amount.toInt().toString();
  }

  // テンキーが押された時の処理
  void _onKeyTap(String val) {
    setState(() {
      if (val == 'C') {
        amountStr = '0';
      } else if (val == '00') {
        if (amountStr != '0') amountStr += '00';
      } else {
        if (amountStr == '0') {
          amountStr = val;
        } else {
          amountStr += val;
        }
      }
      // 異常な桁数を防ぐセーフティ
      if (amountStr.length > 9) amountStr = amountStr.substring(0, 9);
    });
  }

  // カンマ区切りのフォーマット
  String get formattedAmount {
    final intAmount = int.tryParse(amountStr) ?? 0;
    return intAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    // 画面の約70%の高さのハーフモーダル
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. ヘッダー部分（キャンセル・タイトル・削除）
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  '金額の修正',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A415B),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // 削除処理
                    await ref
                        .read(expenseRepositoryProvider)
                        .deleteExpense(widget.expense.id);
                    ref.invalidate(dailyExpensesProvider);
                    ref.invalidate(monthlyExpensesProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
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
              ],
            ),
          ),

          // 2. 金額表示エリア
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF3AB2B5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A415B),
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),

          // 3. テンキーエリア
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 24.0,
              ),
              child: Column(
                children: [
                  _buildRow(['1', '2', '3']),
                  _buildRow(['4', '5', '6']),
                  _buildRow(['7', '8', '9']),
                  _buildRow(['00', '0', 'C']),
                  const SizedBox(height: 12),

                  // 保存ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AB2B5), // アクセント色
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final newAmount = int.tryParse(amountStr);
                        if (newAmount != null && newAmount > 0) {
                          widget.expense.amount = newAmount;
                          await ref
                              .read(expenseRepositoryProvider)
                              .saveExpense(widget.expense);
                          ref.invalidate(dailyExpensesProvider);
                          ref.invalidate(monthlyExpensesProvider);
                          if (context.mounted) {
                            Navigator.pop(context);
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- テンキーの行生成 ---
  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  // --- テンキーのボタン生成 ---
  Widget _buildKey(String label) {
    final isAction = label == 'C' || label == '00';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyTap(label),
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
                fontSize: 24,
                fontWeight: isAction ? FontWeight.w600 : FontWeight.bold,
                color: const Color(0xFF1A415B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
