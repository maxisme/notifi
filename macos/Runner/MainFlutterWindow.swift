import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    self.contentViewController = flutterViewController

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
