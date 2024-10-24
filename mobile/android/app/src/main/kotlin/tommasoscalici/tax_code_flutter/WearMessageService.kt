// package tommasoscalici.taxcode

// import android.content.Intent
// import android.util.Log
// import com.google.android.gms.wearable.MessageEvent
// import com.google.android.gms.wearable.WearableListenerService

// class WearMessageService : WearableListenerService() {
//     companion object {
//         private const val TAG = "WearMessageService"
//     }

//     override fun onCreate() {
//         super.onCreate()
//         Log.d(TAG, "Service created")
//     }

//     override fun onMessageReceived(messageEvent: MessageEvent) {
//         Log.d(TAG, "Message received: ${messageEvent.path}")
        
//         if (messageEvent.path == "/open_app") {
//             try {
//                 val intent = Intent(this, MainActivity::class.java).apply {
//                     addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
//                     data = android.net.Uri.parse("tommasoscalici.taxcode://open")
//                     //putExtra("from_wear", true) // Useful to pass extra data
//                 }
                
//                 Log.d(TAG, "Starting main activity")
//                 startActivity(intent)
//                 Log.d(TAG, "Main activity started successfully")
//             } catch (e: Exception) {
//                 Log.e(TAG, "Error starting activity", e)
//             }
//         }
//     }
// }