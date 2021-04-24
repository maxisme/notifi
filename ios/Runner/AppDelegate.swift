import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let notificationChannel = FlutterMethodChannel(name: "max.me.uk/notifications",
                binaryMessenger: controller.binaryMessenger)

        notificationChannel.setMethodCallHandler { [self]
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "UUID":
                let uuid = UIDevice.current.identifierForVendor?.uuidString;
                result(uuid)
                return
            default:
                return
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
