import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import '../providers/amount_provider.dart'; // 先ほど作成したProviderをインポート
import '../widgets/category_selector.dart';
import '../widgets/custom_numpad.dart';
import 'package:spendflow_app/features/calendar/views/calendar_screen.dart';

class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 金額の状態を監視
    final amount = ref.watch(amountProvider);
    // 状態からフォーマット済みの文字列（カンマ区切り）を取得
    final formattedAmount = ref.read(amountProvider.notifier).formattedAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '支出を入力',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 金額表示エリア (中央寄せ)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '金額',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 金額が0のときは '0'、それ以外はカンマ区切りの数値を表示
                    Text(
                      amount == 0 ? '0' : formattedAmount,
                      style: const TextStyle(
                        fontSize: 64, // モダンで見やすい巨大フォント
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -2, // 数字の間隔を少し詰めてモダンに
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. カテゴリセレクター
          const CategorySelector(),

          // 3. カスタムテンキー (画面下部)
          const CustomNumpad(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        elevation: 4,
        onPressed: () {
          // TODO: カメラ起動（連写モード）
        },
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
    );
  }
}
