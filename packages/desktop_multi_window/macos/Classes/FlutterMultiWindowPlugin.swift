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

        let mainChannel = FlutterMethodChannel(
            name: "questboard/main",
            binaryMessenger: registrar.messenger
        )

        mainChannel.setMethodCallHandler { call, result in
            switch call.method {
            case "setAlwaysOnTop":
                guard let value = call.arguments as? Bool else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENT",
                            message: "Expected a Boolean argument",
                            details: call.arguments
                        )
                    )
                    return
                }

                DispatchQueue.main.async {
                    var overlayFound = false

                    for (_, flutterWindow) in MultiWindowManager.shared.windows {
                        guard flutterWindow.window is OverlayWindow else {
                            continue
                        }

                        flutterWindow.window.level =
                            value ? .statusBar : .normal

                        overlayFound = true

                        NSLog(
                            "QuestBoard: Overlay always on top = \(value)"
                        )
                    }

                    if overlayFound {
                        result(nil)
                    } else {
                        result(
                            FlutterError(
                                code: "OVERLAY_NOT_FOUND",
                                message: "No overlay window was found",
                                details: nil
                            )
                        )
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

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

        window.contentViewController = flutterViewController
        window.acceptsMouseMovedEvents = true
        window.setFrame(overlayFrame(), display: true)

        if config.arguments.contains("\"overlay\"") {
            let flutterView = flutterViewController.view
            let dragView = OverlayDragRegionView(
                frame: flutterView.bounds
            )

            dragView.autoresizingMask = [.width, .height]

            flutterView.addSubview(
                dragView,
                positioned: .above,
                relativeTo: nil
            )
        }

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
    let width: CGFloat = 400
    let height: CGFloat = 350

    return NSRect(
        x: visible.maxX - width - 20,
        y: visible.midY - height / 2,
        width: width,
        height: height
    )
}

final class OverlayDragRegionView: NSView {
    private let resizeThickness: CGFloat = 15
    private let minimumWidth: CGFloat = 250
    private let aspectRatio: CGFloat = 400.0 / 350.0

    private let dragRegionHeight: CGFloat = 80
    private let homeButtonWidth: CGFloat = 70

    private var dragRect: NSRect {
        NSRect(
            x: bounds.minX,
            y: bounds.maxY - dragRegionHeight,
            width: bounds.width - homeButtonWidth,
            height: dragRegionHeight
        )
    }

    private var trackingArea: NSTrackingArea?

    private struct ResizeEdges: OptionSet {
        let rawValue: Int
        static let left   = ResizeEdges(rawValue: 1 << 0)
        static let right  = ResizeEdges(rawValue: 1 << 1)
        static let bottom = ResizeEdges(rawValue: 1 << 2)
        static let top    = ResizeEdges(rawValue: 1 << 3)
    }

    private var activeResizeEdges: ResizeEdges = []
    private var initialWindowFrame: NSRect = .zero
    private var initialMouseLocation: NSPoint = .zero

    private func resizeEdges(at point: NSPoint) -> ResizeEdges {
        var edges: ResizeEdges = []

        if point.x <= bounds.minX + resizeThickness {edges.insert(.left)}
        if point.x >= bounds.maxX - resizeThickness {edges.insert(.right)}
        if point.y <= bounds.minY + resizeThickness {edges.insert(.bottom)}
        if point.y >= bounds.maxY - resizeThickness {edges.insert(.top)}

        return edges
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Prioridad
        let localPoint = convert(point, from: superview)
        if !resizeEdges(at: localPoint).isEmpty { return self }
        if dragRect.contains(localPoint) { return self }
        return nil
    }

    override func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }

        let localPoint = convert(
            event.locationInWindow,
            from: nil
        )

        let edges = resizeEdges(at: localPoint)

        if !edges.isEmpty {
            activeResizeEdges = edges
            initialWindowFrame = window.frame

            initialMouseLocation = window.convertPoint(toScreen: event.locationInWindow)
            return
        }

        if dragRect.contains(localPoint) {
            window.performDrag(with: event)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard
            !activeResizeEdges.isEmpty,
            let window = self.window
        else {return}

        NSCursor.closedHand.set()

        let currentMouseLocation = window.convertPoint(
            toScreen: event.locationInWindow
        )

        let deltaX = currentMouseLocation.x - initialMouseLocation.x
        let deltaY = currentMouseLocation.y - initialMouseLocation.y

        let initialWidth = initialWindowFrame.width

        // Calculamos cuánto debería cambiar el tamaño.
        var widthChange: CGFloat

        let isCorner =
            (activeResizeEdges.contains(.left) ||
             activeResizeEdges.contains(.right)) &&
            (activeResizeEdges.contains(.top) ||
             activeResizeEdges.contains(.bottom))

        if isCorner {
            // En las esquinas, usamos el movimiento que más
            // representa la intención del usuario.
            let horizontalChange =
                activeResizeEdges.contains(.left) ? -deltaX : deltaX

            let verticalChange =
                activeResizeEdges.contains(.bottom) ? -deltaY : deltaY

            let widthChangeFromHeight = verticalChange * aspectRatio

            if abs(horizontalChange) > abs(widthChangeFromHeight) {
                widthChange = horizontalChange
            } else {
                widthChange = widthChangeFromHeight
            }
        } else if activeResizeEdges.contains(.left) ||
                    activeResizeEdges.contains(.right) {
            widthChange = activeResizeEdges.contains(.left)
                ? -deltaX
                : deltaX
        } else {
            let heightChange = activeResizeEdges.contains(.bottom)
                ? -deltaY
                : deltaY

            widthChange = heightChange * aspectRatio
        }

        var newWidth = initialWidth + widthChange
        var newHeight = newWidth / aspectRatio

        if newWidth < minimumWidth {
            newWidth = minimumWidth
            newHeight = newWidth / aspectRatio
        }

        var newX = initialWindowFrame.minX
        var newY = initialWindowFrame.minY

        if activeResizeEdges.contains(.left) {
            newX = initialWindowFrame.maxX - newWidth
        }

        if activeResizeEdges.contains(.bottom) {
            newY = initialWindowFrame.maxY - newHeight
        }

        let newFrame = NSRect(
            x: newX,
            y: newY,
            width: newWidth,
            height: newHeight
        )

        window.setFrame(
            newFrame,
            display: true,
            animate: false
        )
    }

    override func mouseUp(with event: NSEvent) {
        activeResizeEdges = []
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )

        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let edges = resizeEdges(at: point)

        if edges.contains(.left) || edges.contains(.right) {
            NSCursor.resizeLeftRight.set()
        } else if edges.contains(.top) || edges.contains(.bottom) {
            NSCursor.resizeUpDown.set()
        } else if dragRect.contains(point) {
            NSCursor.openHand.set()
        }else {
            NSCursor.arrow.set()
        }
    }
}