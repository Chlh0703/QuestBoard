import Cocoa

class OverlayWindow: CustomWindow {

    override init(configuration: WindowConfiguration) {
        super.init(configuration: configuration)

        styleMask = [.borderless]

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false

        level = .floating

        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}