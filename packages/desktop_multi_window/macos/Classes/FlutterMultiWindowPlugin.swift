import Cocoa
import FlutterMacOS

public class FlutterMultiWindowPlugin: NSObject, FlutterPlugin {

    private let windowId: WindowId
    private let windowArgument: String
    

    init(window: FlutterWindow) {
        self.windowId = window.windowId
        self.windowArgument = window.windowArgument
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        guard let app = NSApplication.shared.delegate as? FlutterAppDelegate else {
            debugPrint(
                "failed to find flutter main window, application delegate is not FlutterAppDelegate"
            )
            return
        }
        guard let window = app.mainFlutterWindow else {
            debugPrint("failed to find flutter main window")
            return
        }
        MultiWindowManager.shared.AttachWindow(window: window, registrar: registrar)
    }

    public typealias OnWindowCreatedCallback = (FlutterViewController) -> Void
    static var onWindowCreatedCallback: OnWindowCreatedCallback?

    public static func setOnWindowCreatedCallback(_ callback: @escaping OnWindowCreatedCallback) {
        onWindowCreatedCallback = callback
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isWindowEvent = call.method.hasPrefix("window_")
        if isWindowEvent {
            let arguments = call.arguments as! [String: Any?]
            let windowId = arguments["windowId"] as! WindowId
            guard let window = MultiWindowManager.shared.windows[windowId] else {
                result(
                    FlutterError(
                        code: "-1", message: "failed to find target window. \(windowId)",
                        details: nil))
                return
            }

            window.handleWindowMethod(method: call.method, arguments: arguments, result: result)
            return
        }

        switch call.method {
        case "createWindow":
            let arguments = call.arguments as! [String: Any?]
            let windowId = MultiWindowManager.shared.CreateWindow(arguments: arguments)
            result(windowId)
        case "getWindowDefinition":
            let definition: [String: Any] = [
                "windowId": windowId,
                "windowArgument": windowArgument,
            ]
            result(definition)
        case "getAllWindows":
            let windows = MultiWindowManager.shared.getAllWindows()
            result(windows)
        default:
            result(FlutterMethodNotImplemented)
        }

    }
}

class MultiWindowManager: NSObject {

    static let shared: MultiWindowManager = MultiWindowManager()

    private override init() {}

    var windows: [WindowId: FlutterWindow] = [:]

    func AttachWindow(window: NSWindow, registrar: FlutterPluginRegistrar) {
        // check window exists
        for (_, flutterWindow) in windows {
            if flutterWindow.window == window {
                return
            }
        }
        let windowId = WindowId.generate()
        let flutterWindow = FlutterWindow(windowId: windowId, windowArgument: "", window: window)
        windows[windowId] = flutterWindow

        let channel = registerMultiWindowChannel(window: flutterWindow, with: registrar)
        flutterWindow.setChannel(channel)

        notifyWindowsChanged()
    }

    func CreateWindow(arguments: [String: Any?]) -> WindowId {
        let windowId = WindowId.generate()

        let config = WindowConfiguration.fromJson(arguments)

        let window: CustomWindow

        if config.arguments.contains("\"overlay\"") {
            window = OverlayWindow(configuration: config)
        } else {
            window = CustomWindow(configuration: config)
        }

        let project = FlutterDartProject()
        project.dartEntrypointArguments = ["multi_window", windowId, config.arguments]
        let flutterViewController = FlutterViewController(project: project)
        if config.arguments.contains("\"overlay\"") {
            flutterViewController.backgroundColor = .clear

            let overlayChannel = FlutterMethodChannel(
                name: "questboard/overlay",
                binaryMessenger: flutterViewController.engine.binaryMessenger
            )

            overlayChannel.setMethodCallHandler { [weak window] call, result in

                guard let window = window else {
                    result(FlutterError(
                        code: "NO_WINDOW",
                        message: "Window not found",
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
        }
        window.contentViewController = flutterViewController
        window.acceptsMouseMovedEvents = true
        window.setFrame(overlayFrame(), display: true)

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        FlutterMultiWindowPlugin.onWindowCreatedCallback?(flutterViewController)

        let registrar = flutterViewController.registrar(forPlugin: "DesktopMultiWindowPlugin")

        let flutterWindow = FlutterWindow(
            windowId: windowId, windowArgument: config.arguments, window: window)
        windows[windowId] = flutterWindow

        let channel = registerMultiWindowChannel(window: flutterWindow, with: registrar)
        flutterWindow.setChannel(channel)

        notifyWindowsChanged()

        return windowId
    }

    func removeWindow(windowId: WindowId) {
        if windows.removeValue(forKey: windowId) != nil {
            notifyWindowsChanged()
        }
    }

    func getAllWindowIds() -> [WindowId] {
        return Array(windows.keys)
    }

    func getAllWindows() -> [[String: String]] {
        return windows.values.map { window in
            [
                "windowId": window.windowId,
                "windowArgument": window.windowArgument,
            ]
        }
    }

    private func notifyWindowsChanged() {
        for (_, window) in windows {
            window.notifyWindowEvent("onWindowsChanged", data: [:])
        }
    }

    // register multi window method channel for all engine. include main or created by this plugin
    private func registerMultiWindowChannel(
        window: FlutterWindow, with registrar: FlutterPluginRegistrar
    ) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(
            name: "mixin.one/desktop_multi_window", binaryMessenger: registrar.messenger)
        registrar.addMethodCallDelegate(FlutterMultiWindowPlugin(window: window), channel: channel)

        // register window method channel plugin
        WindowChannel.register(with: registrar)

        return channel
    }

}

func overlayFrame() -> NSRect {
    guard let screen = NSScreen.main else {
        return NSRect(x: 0, y: 0, width: 200, height: 350)
    }

    let visible = screen.visibleFrame
    let width: CGFloat = 200
    let height: CGFloat = 350

    return NSRect(
        x: visible.maxX - width - 20,
        y: visible.midY - height / 2,
        width: width,
        height: height
    )
}

