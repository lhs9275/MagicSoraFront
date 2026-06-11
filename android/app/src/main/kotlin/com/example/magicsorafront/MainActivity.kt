package com.example.magicsorafront

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "magicsorafront/kakao_config"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNativeAppKey" -> result.success(BuildConfig.KAKAO_NATIVE_APP_KEY)
                else -> result.notImplemented()
            }
        }
    }
}
