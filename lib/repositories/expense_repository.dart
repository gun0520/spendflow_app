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

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return await isar.expenses
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .findAll();
  }

  Future<List<Expense>> getExpensesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await isar.expenses
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }
}
