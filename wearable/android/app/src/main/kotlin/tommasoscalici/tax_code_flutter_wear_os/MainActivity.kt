package tommasoscalici.tax_code_flutter_wear_os

import android.content.Intent
import android.view.WindowManager
import androidx.lifecycle.lifecycleScope
import androidx.wear.activity.ConfirmationActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "tommasoscalici.tax_code_flutter_wear_os/channel"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "enableHighBrightnessMode" -> {
                    try {
                        val window = this.window
                        val layoutParams = window.attributes
                        layoutParams.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_FULL
                        window.attributes = layoutParams
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to enable high brightness", e.message)
                    }
                }
                "disableHighBrightnessMode" -> {
                    try {
                        val window = this.window
                        val layoutParams = window.attributes
                        layoutParams.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
                        window.attributes = layoutParams
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to disable high brightness", e.message)
                    }
                }
                "launchPhoneApp" -> {
                    lifecycleScope.launch {
                        val launcher = PhoneAppLauncherService(this@MainActivity)
                        val launchResult = launcher.launchPhoneApp("tommasoscalici.taxcode")

                        withContext(Dispatchers.Main) {
                            val animationType: Int
                            val message: String

                            when (launchResult) {
                                is PhoneAppLauncherService.LaunchResult.Success -> {
                                    animationType = ConfirmationActivity.SUCCESS_ANIMATION
                                    message = launchResult.message
                                    result.success(true)
                                }
                                is PhoneAppLauncherService.LaunchResult.Error -> {
                                    animationType = ConfirmationActivity.FAILURE_ANIMATION
                                    message = launchResult.message
                                    result.error("LAUNCH_ERROR", message, null)
                                }
                            }

                            val intent = Intent(this@MainActivity, ConfirmationActivity::class.java).apply {
                                putExtra(ConfirmationActivity.EXTRA_ANIMATION_TYPE, animationType)
                                putExtra(ConfirmationActivity.EXTRA_MESSAGE, message)
                            }
                            startActivity(intent)
                        }
                    }
                }
                "closeNativeContactList",
                "openNativeContactList",
                "updateContactList" -> {
                    // No-op for legacy calls during Pure Flutter transition
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
