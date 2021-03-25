import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        // empty window
        contentViewController = nil
        let rect = NSRect(x: 1, y: 1, width: 1, height: 1)
        let frame = frameRect(forContentRect: rect)
        setFrame(frame, display: false, animate: false)
        super.awakeFromNib()
    }
}
