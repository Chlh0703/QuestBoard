import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()

        let channel = FlutterMethodChannel(
            name: "questboard/overlay",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        // Si flutter usa este canal, swift ejecutará esta parte de codigo directamente
        channel.setMethodCallHandler { [weak self] call, result in  // weak es para limpiar recursos
            guard let window = self else {
                result(FlutterError(
                    code: "NO_WINDOW",
                    message: nil,
                    details: nil
                ))
                return
            }

            switch call.method {
            case "enableClickThrough":
                window.ignoresMouseEvents = true
                result(nil)
            case "disableClickThrough":
                window.ignoresMouseEvents = false
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }


        self.isOpaque = false
        self.backgroundColor = .clear
        flutterViewController.backgroundColor = .clear

        let windowFrame = self.frame

        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }

}