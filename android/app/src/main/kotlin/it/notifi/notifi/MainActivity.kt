package it.notifi.notifi

import android.content.Context
import android.content.SharedPreferences
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*


class MainActivity: FlutterActivity() {
    private var uniqueID: String? = null
    private val PREF_UNIQUE_ID = "PREF_UNIQUE_ID"
    private val CHANNEL = "max.me.uk/notifications"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "UUID") {
                var tManager: TelephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                var uuid = try {
                    tManager.getDeviceId()
                }catch (e: Exception){
                    null;
                }

                if (uuid != null) {
                    result.success(uuid)
                } else {
                    val sharedPrefs: SharedPreferences = context.getSharedPreferences(
                            PREF_UNIQUE_ID, MODE_PRIVATE)
                    uniqueID = sharedPrefs.getString(PREF_UNIQUE_ID, null)
                    if (uniqueID == null) {
                        uniqueID = UUID.randomUUID().toString()
                        val editor: SharedPreferences.Editor = sharedPrefs.edit()
                        editor.putString(PREF_UNIQUE_ID, uniqueID)
                        editor.apply()
                    }
                    result.success(uniqueID)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
