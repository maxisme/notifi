import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var statusBarItem: NSStatusItem!
    let popover = NSPopover()
    @IBOutlet weak var window: NSWindow!
    
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window?.titlebarAppearsTransparent = true;
        self.window?.titleVisibility = .hidden;
        window?.styleMask.remove(.titled)
        
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusBarItem.button {
            button.image = NSImage(named:NSImage.Name("AppIcon"))
            button.action = #selector(togglePopover(_:))
        }
        
        let flutterViewController = FlutterViewController.init()
        popover.contentViewController = flutterViewController
        popover.contentSize = NSSize(width: 250, height: 600)
        
        NSApp.activate(ignoringOtherApps: true)

        RegisterGeneratedPlugins(registry: flutterViewController)
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @objc func togglePopover(_ sender: Any?) {
      if popover.isShown {
        closePopover(sender: sender)
      } else {
        showPopover(sender: sender)
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
