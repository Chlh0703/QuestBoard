import Cocoa

// donde termina y donde hago yo

class OverlayWindow: NSPanel {

    init() {
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
        isReleasedWhenClosed = false

        level = .statusBar

        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}