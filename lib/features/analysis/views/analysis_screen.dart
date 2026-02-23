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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '今月の分析',
          style: TextStyle(
            color: Color(0xFF1A415B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A415B)),
      ),
      body: categoryTotals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('エラー: $err')),
        data: (totals) {
          if (totals.isEmpty) return const Center(child: Text('データがありません'));

          final totalAmount = totals.values.fold(0, (sum, item) => sum + item);

          return Column(
            children: [
              // 1. 総支出額の表示（フラットなパネルデザインに変更）
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 32.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  // ★影を消して、薄いボーダー（#CAE8E9）で囲む
                  border: Border.all(
                    color: const Color(0xFFCAE8E9),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '総支出',
                      style: TextStyle(
                        color: Color(0xFF1A415B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥${totalAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900, // モダンに見せるため太字に
                        color: Color(0xFF1A415B),
                        letterSpacing: -1, // 少し文字間を詰める
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 円グラフ
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(totals),
                    sectionsSpace: 2, // スライス間の隙間
                    centerSpaceRadius: 50, // 真ん中の空洞を少し広げてドーナツ型に
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. カテゴリ別のリスト（フラットなリストアイテムに変更）
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  itemCount: totals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8), // アイテム間の余白
                  itemBuilder: (context, index) {
                    final entry = totals.entries.elementAt(index);
                    // アイテムの背景も白＋薄いボーダーでCSSのカード風に
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCAE8E9),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: _getColor(
                            index,
                          ), // グラフと同じ色を小さなドットで表示
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Color(0xFF1A415B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          '¥${entry.value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A415B),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // グラフとリストで共通の色を使うためのメソッド
  Color _getColor(int index) {
    // ご指定のカラーパレットをベースにした色の配列
    final colors = [
      const Color(0xFF1A415B), // 濃紺 (メイン)
      const Color(0xFF3AB2B5), // 青緑 (アクセント)
      const Color(0xFFD1C58C), // ゴールド
      const Color(0xFFCAE8E9), // 薄青
      const Color(0xFFF3F3E7), // 薄ベージュ
      const Color(0xFF8BA5B5), // 濃紺を少し薄くした色(補色)
    ];
    return colors[index % colors.length];
  }

  List<PieChartSectionData> _buildChartSections(Map<String, int> totals) {
    int index = 0;
    return totals.entries.map((entry) {
      final color = _getColor(index);
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        // グラフ上に文字が被るとごちゃつくので、あえて文字を消す（リスト側で確認させる）モダンな手法
        showTitle: false,
        radius: 40,
      );
    }).toList();
  }
}
