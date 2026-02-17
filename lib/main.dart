import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/expense.dart'; // 作成したモデル
import 'app.dart';

// Isarのインスタンスを保持するグローバルなプロバイダ
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 保存先のディレクトリを取得
  final dir = await getApplicationDocumentsDirectory();

  // 2. Isarの初期化（Expenseモデルを登録）
  isar = await Isar.open([ExpenseSchema], directory: dir.path);

  runApp(const ProviderScope(child: SpendFlowApp()));
}
