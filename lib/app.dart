import 'package:flutter/material.dart';
import 'package:spendflow_app/features/main_screen.dart'; // この後作成するファイルをインポート
import 'package:spendflow_app/constants/app_colors.dart';

class SpendFlowApp extends StatelessWidget {
  const SpendFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendFlow',
      debugShowCheckedModeBanner: false, // 右上のデバッグラベルを消す
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Hiragino Kaku Gothic ProN', // フォントはお好みで
      ),
      // ここを MainScreen に変えることで、タブバー付きの画面が最初に開きます
      home: const MainScreen(),
    );
  }
}
