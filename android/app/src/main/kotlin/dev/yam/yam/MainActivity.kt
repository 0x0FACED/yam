package dev.yam.yam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var updatesChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AppUpdateInstaller.start(applicationContext)
        updatesChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev.yam.yam/updates").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getUpdateDirectory" -> AppUpdateInstaller.getUpdateDirectory(applicationContext, result)
                    "cleanupUpdates" -> AppUpdateInstaller.cleanupUpdates(applicationContext, result)
                    "installUpdate" -> AppUpdateInstaller.installUpdate(this@MainActivity, call, result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        updatesChannel?.setMethodCallHandler(null)
        updatesChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
