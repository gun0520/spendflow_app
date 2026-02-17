import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/expense.dart';
import '../main.dart'; // 先ほどのグローバルisarを参照

// リポジトリをアプリ全体に提供するプロバイダ
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

class ExpenseRepository {
  // 全データの取得
  Future<List<Expense>> getAllExpenses() async {
    return await isar.expenses.where().findAll();
  }

  // 支出の保存（または更新）
  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });
  }

  // 特定の日の支出を取得（カレンダー表示用）
  Future<List<Expense>> getExpensesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.expenses
        .filter()
        .dateGreaterThan(startOfDay.subtract(const Duration(seconds: 1)))
        .dateLessThan(endOfDay)
        .findAll();
  }
}
