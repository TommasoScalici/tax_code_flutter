package tommasoscalici.tax_code_flutter

import android.content.Intent
import android.net.Uri
import android.util.Log
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService

class WearMessageService : WearableListenerService() {
    companion object {
        private const val TAG = "WearMessageService"
        private const val DEEP_LINK_SCHEME = BuildConfig.DEEP_LINK_SCHEME
        private const val ENABLE_WEAR_LOGGING = BuildConfig.ENABLE_WEAR_LOGGING
        private const val WEAR_PATH_OPEN_APP = BuildConfig.WEAR_PATH_OPEN_APP
    }

    override fun onCreate() {
        super.onCreate()
        if (ENABLE_WEAR_LOGGING) {
            Log.d(TAG, "Service created")
        }
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        if (ENABLE_WEAR_LOGGING) {
            Log.d(TAG, "Message received: ${messageEvent.path}")
        }
        
        if (messageEvent.path == WEAR_PATH_OPEN_APP) {
            launchMainActivity()
        }
    }

    private fun launchMainActivity() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                data = Uri.parse("$DEEP_LINK_SCHEME://open")
            }
            
            if (ENABLE_WEAR_LOGGING) {
                Log.d(TAG, "Starting main activity")
            }
            
            startActivity(intent)
            
            if (ENABLE_WEAR_LOGGING) {
                Log.d(TAG, "Main activity started successfully")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting activity", e)
        }
    }
}
