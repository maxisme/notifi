import Cocoa
import FlutterMacOS
import UserNotifications

extension NSImage.Name {
    static let grey = NSImage.Name("menu_icon")
    static let red = NSImage.Name("red_menu_icon")
    static let error = NSImage.Name("menu_error_icon")
}

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var statusBarItem: NSStatusItem!
    let popover = NSPopover()
    @IBOutlet weak var window: MainFlutterWindow!

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusBarItem.button {
            let image = NSImage(named: .red);
            image?.size = NSSize(width: 25, height: 25);
            button.image = image
            button.action = #selector(togglePopover(_:))
        }

        let flutterViewController = FlutterViewController.init();

        let notificationChannel = FlutterMethodChannel(name: "max.me.uk/notifications",
                binaryMessenger: flutterViewController.engine.binaryMessenger);

        notificationChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let menu_image: NSImage?;
            switch call.method {
            case "red_menu_icon":
                menu_image = NSImage(named: .red)
            case "grey_menu_icon":
                menu_image = NSImage(named: .grey)
            case "error_icon":
                menu_image = NSImage(named: .error)
            default:
                return
            }
            if (menu_image != nil) {
                if let button = self.statusBarItem.button {
                    menu_image?.size = NSSize(width: 25, height: 25);
                    button.image = menu_image;
                    result(0); // success
                }
            }
        })

        RegisterGeneratedPlugins(registry: flutterViewController)

        popover.contentViewController = flutterViewController

        // to connect to ws in background
        popover.contentSize = NSSize(width: 1, height: 1)
        showPopover(sender: nil)
        closePopover(sender: nil)

        popover.contentSize = NSSize(width: 400, height: 600)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            if #available(OSX 10.14, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications();
            }

            // open popup
            showPopover(sender: sender)

            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
}
