import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import '../providers/analysis_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotals = ref.watch(categoryTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '今月の分析',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: categoryTotals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('エラー: $err')),
        data: (totals) {
          if (totals.isEmpty) return const Center(child: Text('データがありません'));

          final totalAmount = totals.values.fold(0, (sum, item) => sum + item);

          return Column(
            children: [
              // 1. 総支出額の表示
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('総支出', style: TextStyle(color: Colors.grey)),
                    Text(
                      '¥${totalAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 円グラフ
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(totals),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),

              // 3. カテゴリ別のリスト
              Expanded(
                child: ListView(
                  children: totals.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      trailing: Text('¥${entry.value}'),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(Map<String, int> totals) {
    // 簡易的な色分けロジック
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
    ];
    int index = 0;

    return totals.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
