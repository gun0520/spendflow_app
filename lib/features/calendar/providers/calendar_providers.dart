import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/models/expense.dart';
import 'package:spendflow_app/repositories/expense_repository.dart';

// カレンダーで「今どの日を選択しているか」を管理する
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 選択された日の支出リストをDBから取得するFutureProvider
final dailyExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final repository = ref.read(expenseRepositoryProvider);

  // Repositoryに新しく作成するメソッドを呼び出す
  return repository.getExpensesByDate(date);
});
