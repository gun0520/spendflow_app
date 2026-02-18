import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/models/expense.dart';
import 'package:spendflow_app/repositories/expense_repository.dart';

// 表示対象の「月」を管理
final analysisMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// その月の全データを取得
final monthlyExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final month = ref.watch(analysisMonthProvider);
  final repository = ref.read(expenseRepositoryProvider);
  return repository.getExpensesByMonth(month);
});

// カテゴリ別の合計金額を計算するプロバイダ
final categoryTotalProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final asyncExpenses = ref.watch(monthlyExpensesProvider);

  return asyncExpenses.whenData((expenses) {
    final Map<String, int> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  });
});
