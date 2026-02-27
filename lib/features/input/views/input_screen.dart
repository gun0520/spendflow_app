import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendflow_app/constants/app_colors.dart';
import '../providers/amount_provider.dart'; // 先ほど作成したProviderをインポート
import '../widgets/category_selector.dart';
import '../widgets/custom_numpad.dart';
import 'package:spendflow_app/features/calendar/views/calendar_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/input_state_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final expenseMemoProvider = StateProvider<String?>((ref) => null);

class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 金額の状態を監視
    final amount = ref.watch(amountProvider);
    //レシートの監視
    final receiptImagePath = ref.watch(receiptImageProvider);
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
            icon: Icon(
              // メモが入力されていれば色を変えて分かりやすくする
              ref.watch(expenseMemoProvider) != null
                  ? Icons.edit_note
                  : Icons.notes,
              color: ref.watch(expenseMemoProvider) != null
                  ? const Color(0xFF3AB2B5)
                  : const Color(0xFF1A415B),
            ),
            onPressed: () async {
              // メモ入力用のダイアログを表示
              String? initialMemo = ref.read(expenseMemoProvider);
              final memoController = TextEditingController(text: initialMemo);

              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('メモを入力', style: TextStyle(fontSize: 18)),
                  content: TextField(
                    controller: memoController,
                    autofocus: true,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '例：〇〇スーパー、〇〇さんとランチ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AB2B5),
                      ),
                      onPressed: () {
                        // Providerにメモを保存して閉じる
                        ref
                            .read(expenseMemoProvider.notifier)
                            .state = memoController.text.isEmpty
                            ? null
                            : memoController.text;
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '保存',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF1A415B),
            ),
            onPressed: () async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
              );

              if (image != null) {
                //アプリの安全な保存場所（ドキュメントディレクトリ）を取得
                final directory = await getApplicationDocumentsDirectory();

                //元の画像ファイル名を取得（例: image_picker_12345.jpg）
                final fileName = p.basename(image.path);

                //コピー先の新しいファイルパスを作成
                final savedImagePath = '${directory.path}/$fileName';

                // 一時ファイルを安全な場所へコピー
                await File(image.path).copy(savedImagePath);

                // 新しい安全なパスを状態（Provider）に保存
                ref.read(receiptImageProvider.notifier).state = savedImagePath;
              }
            },
          ),
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
                if (receiptImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // サムネイル画像
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(
                              receiptImagePath,
                            ), // ※エラーが出る場合は import 'dart:io'; をファイルの一番上に追加してください
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // 削除（バツ）ボタン
                        GestureDetector(
                          onTap: () {
                            ref.read(receiptImageProvider.notifier).state =
                                null;
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. カテゴリセレクター
          const Expanded(flex: 4, child: CategorySelector()),

          // 3. カスタムテンキー (画面下部)
          const Expanded(flex: 3, child: CustomNumpad()),
        ],
      ),
    );
  }
}
