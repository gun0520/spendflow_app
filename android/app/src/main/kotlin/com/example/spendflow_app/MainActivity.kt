package com.example.spendflow_app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // ★ タスク一覧画面での覗き見と、スクリーンショット撮影を防止する魔法の1行
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}