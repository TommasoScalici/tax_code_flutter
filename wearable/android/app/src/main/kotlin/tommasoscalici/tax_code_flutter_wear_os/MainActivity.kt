package tommasoscalici.tax_code_flutter_wear_os

import android.os.Bundle
import android.view.InputDevice
import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "tommasoscalici.tax_code_flutter_wear_os/navigation"
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        window.decorView.setOnGenericMotionListener { _, event ->
            when {
                event.action == MotionEvent.ACTION_SCROLL && event.source == InputDevice.SOURCE_ROTARY_ENCODER -> {
                    val delta = event.getAxisValue(MotionEvent.AXIS_SCROLL)
                    channel.invokeMethod("onRotaryInput", delta)
                    true
                }
                else -> false
            }
        }
    }
}
