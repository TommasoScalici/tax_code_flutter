package tommasoscalici.tax_code_flutter_wear_os

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "tommasoscalici.tax_code_flutter_wear_os/channel"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openNativeContactList" -> {
                    try {
                        val contacts = call.argument<ArrayList<HashMap<String, Any>>>("contacts")
                        showContactList(contacts)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error opening contact list", e.message)
                    }
                }
                else -> result.notImplemented()
            }
        }

        flutterEngine.navigationChannel.setInitialRoute("/barcode")
    }

    fun getEngine(): FlutterEngine? {
        return flutterEngine
    }

    private fun showContactList(contacts: ArrayList<HashMap<String, Any>>?) {
        supportFragmentManager.beginTransaction()
            .replace(android.R.id.content, ContactListFragment.newInstance(contacts))
            .commit()
    }
}