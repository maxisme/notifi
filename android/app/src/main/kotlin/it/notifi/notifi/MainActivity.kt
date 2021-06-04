package it.notifi.notifi

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    var tManager: TelephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    var uuid: String = tManager.getDeviceId()
}
