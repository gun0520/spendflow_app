import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import 'package:spendflow_app/features/input/views/input_screen.dart';
import 'package:spendflow_app/features/calendar/views/calendar_screen.dart';
import 'package:spendflow_app/features/analysis/views/analysis_screen.dart';
import 'package:spendflow_app/core/providers/navigation_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在どのタブを選択しているかを監視
    final index = ref.watch(navigationIndexProvider);

    // 表示する画面のリスト
    final List<Widget> screens = [
      const InputScreen(),
      const CalendarScreen(),
      const AnalysisScreen(),
    ];

    return Scaffold(
      // IndexedStackを使うと、タブを切り替えても入力中の数字などが消えません
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (newIndex) {
          // タップされたらProviderの値を更新して表示を切り替える
          ref.read(navigationIndexProvider.notifier).state = newIndex;
        },
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.primary.withOpacity(0.4),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: '入力',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: '履歴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: '分析',
          ),
        ],
      ),
    );
  }
}
