import 'package:flutter_riverpod/flutter_riverpod.dart';

// 現在のインデックス（0: 入力, 1: カレンダー, 2: 分析）を管理
final navigationIndexProvider = StateProvider<int>((ref) => 0);
