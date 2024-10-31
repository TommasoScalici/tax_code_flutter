package tommasoscalici.tax_code_flutter_wear_os

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channelName = "tommasoscalici.tax_code_flutter_wear_os/channel"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("default", flutterEngine)
        setupMethodChannel(flutterEngine)
    }

    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler(::handleMethodCall)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openNativeContactList" -> handleOpenContactList(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleOpenContactList(call: MethodCall, result: MethodChannel.Result) {
        try {
            val contacts = call.argument<ArrayList<HashMap<String, Any>>>("contacts")
            val intent = Intent(this, ContactListActivity::class.java).apply {
                putExtra("contacts", contacts)
            }
            startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to open contact list", e.message)
        }
    }
}