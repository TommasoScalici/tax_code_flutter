package tommasoscalici.taxcode

import android.content.Intent
import android.net.Uri
import android.view.InputDevice
import android.view.MotionEvent
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.Node
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wear_os_bridge_controls"
    private val scope = CoroutineScope(Dispatchers.Main)
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openOnPhone" -> {
                    scope.launch {
                        try {
                            openAppOnPhone()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("OPEN_FAILED", e.message, null)
                        }
                    }
                }
                "isWearable" -> {
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        if (event.source and InputDevice.SOURCE_ROTARY_ENCODER != 0) {
            if (event.action == MotionEvent.ACTION_SCROLL) {
                val delta = event.getAxisValue(MotionEvent.AXIS_SCROLL)
                
                if (::channel.isInitialized) {
                    channel.invokeMethod("onRotaryScroll", delta)
                }
                
                return true
            }
        }
        return super.dispatchGenericMotionEvent(event)
    }

    private suspend fun openAppOnPhone() {
        val nodes = Wearable.getNodeClient(this).connectedNodes.await()
        val phoneNode = nodes.firstOrNull { it.isNearby }
        
        if (phoneNode != null) {
            val intent = Intent(Intent.ACTION_VIEW)
                .addCategory(Intent.CATEGORY_DEFAULT)
                .addCategory(Intent.CATEGORY_BROWSABLE)
                .setData(Uri.parse("tommasoscalici.taxcode://open"))

            Wearable.getMessageClient(this).sendMessage(
                phoneNode.id,
                "/open_app",
                intent.toUri(Intent.URI_INTENT_SCHEME).toByteArray()
            ).await()

            Wearable.getMessageClient(this).sendMessage(
                phoneNode.id,
                "/launch",
                ByteArray(0)
            ).await()
        } else {
            throw Exception("No phone connected")
        }
    }
}