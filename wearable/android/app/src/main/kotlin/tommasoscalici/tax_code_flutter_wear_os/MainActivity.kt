package tommasoscalici.tax_code_flutter_wear_os

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.wear.activity.ConfirmationActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private const val CONTACT_LIST_FRAGMENT_TAG = "CONTACT_LIST_FRAGMENT"

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "tommasoscalici.tax_code_flutter_wear_os/channel"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
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
                "openNativeContactList" -> {
                    try {
                        val contacts = call.argument<ArrayList<HashMap<String, Any>>>("contacts")
                        showContactList(contacts)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error opening contact list", e.message)
                    }
                }
                "updateContactList" -> {
                    try {
                        val contacts = call.argument<ArrayList<HashMap<String, Any>>>("contacts")
                        val fragment = supportFragmentManager.findFragmentByTag(CONTACT_LIST_FRAGMENT_TAG) as? ContactListFragment
                        fragment?.updateContacts(contacts)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error updating contact list", e.message)
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
        val fragment = ContactListFragment.newInstance(contacts)
        supportFragmentManager.beginTransaction()
            .replace(android.R.id.content, fragment, CONTACT_LIST_FRAGMENT_TAG)
            .commit()
    }
}
