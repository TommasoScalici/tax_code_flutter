package tommasoscalici.tax_code_flutter_wear_os

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.concurrent.futures.await
import androidx.core.net.toUri
import androidx.wear.remote.interactions.RemoteActivityHelper
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.util.Locale

class PhoneAppLauncherService(private val context: Context) {
    private val remoteActivityHelper = RemoteActivityHelper(context)
    private val nodeClient = Wearable.getNodeClient(context)
    
    sealed class LaunchResult {
        data class Success(val message: String) : LaunchResult()
        data class Error(val message: String) : LaunchResult()
    }
    
    // Suppressing warning on Intent.FLAG_ACTIVITY_NEW_TASK since it's required
    // for cross-device app launch
    @SuppressLint("WearRecents")
    suspend fun launchPhoneApp(packageName: String): LaunchResult = withContext(Dispatchers.IO) {
        try {
            val nodes = try {
                nodeClient.connectedNodes.await()
            } catch (e: Exception) {
                Log.e(TAG, "Error getting connected nodes", e)
                return@withContext LaunchResult.Error(context.getString(R.string.phone_not_connected))
            }
            
            if (nodes.isEmpty()) {
                Log.d(TAG, "No connected nodes found")
                return@withContext LaunchResult.Error(context.getString(R.string.phone_not_connected))
            }
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = "app://$packageName".toUri()
                addCategory(Intent.CATEGORY_DEFAULT)
                addCategory(Intent.CATEGORY_BROWSABLE)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                setPackage(packageName)
            }
            
            try {
                remoteActivityHelper.startRemoteActivity(intent).await()
                Log.d(TAG, "Remote activity started successfully")
                LaunchResult.Success(context.getString(R.string.app_opened))
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start remote activity", e)
                LaunchResult.Error(context.getString(R.string.unable_to_open))
            }
            
        } catch (e: Exception) {
            when (e) {
                is PackageManager.NameNotFoundException -> {
                    Log.e(TAG, "App not installed on phone", e)
                    LaunchResult.Error(context.getString(R.string.app_not_installed))
                }
                is CancellationException -> throw e
                else -> {
                    Log.e(TAG, "Error launching phone app", e)
                    LaunchResult.Error(context.getString(R.string.error_opening_app))
                }
            }
        }
    }
    
    companion object {
        private const val TAG = "PhoneAppLauncherService"
    }
}
