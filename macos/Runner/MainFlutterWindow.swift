import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Configure exact mobile phone dimensions (iPhone 16 / 15 Pro aspect)
    let mobileSize = NSSize(width: 414, height: 896)
    var frame = self.frame
    frame.size = mobileSize
    self.setFrame(frame, display: true)
    self.minSize = NSSize(width: 375, height: 750)
    self.maxSize = NSSize(width: 460, height: 980)
    self.center()
    self.title = "Capsule"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
