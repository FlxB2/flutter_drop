import Cocoa
import FlutterMacOS
import ObjectiveC.runtime

typealias MouseDownIMP = @convention(c) (AnyObject, Selector, NSEvent) -> Void
typealias MouseUpIMP = @convention(c) (AnyObject, Selector, NSEvent) -> Void
typealias DragMaskIMP =
@convention(c) (AnyObject, Selector, NSDraggingSession, NSDraggingContext) -> NSDragOperation
typealias DragEndedIMP =
@convention(c) (AnyObject, Selector, NSDraggingSession, NSPoint, NSDragOperation) -> Void
typealias DragMovedIMP = @convention(c) (AnyObject, Selector, NSDraggingSession, NSPoint) -> Void

public class FlutterDropPlugin: NSObject, FlutterPlugin, NSDraggingSource {
    private var channel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_drop", binaryMessenger: registrar.messenger)
        let instance = FlutterDropPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startNativeDrag":
            if let args = call.arguments as? [String: Any],
               let x = args["x"] as? Double,
               let y = args["y"] as? Double,
               let width = args["width"] as? Double,
               let height = args["height"] as? Double,
               let uri = args["uri"] as? String
            {
                startDrag(
                    at: NSPoint(x: x, y: y), size: NSSize(width: width, height: height), fileUri: uri)
                result("drag started")
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing x/y", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Start native drag for a single widget
    func startDrag(at point: NSPoint, size: NSSize, fileUri: String?) {
        guard let window = NSApp.mainWindow else {
            print("No main window found")
            return
        }
        
        // Find the FlutterView
        guard let flutterView = findFlutterView(in: window.contentView) else {
            print("FlutterView not found")
            return
        }
        
        let dragImage: NSImage
        if let uri = fileUri {
            let url = URL(fileURLWithPath: uri) // not optional
            if let image = NSImage(contentsOf: url) {
                // Clip the image to rounded corners
                dragImage = NSImage(size: size)
                dragImage.lockFocus()
                
                let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: 8, yRadius: 8)
                path.addClip()
                
                image.draw(in: NSRect(origin: .zero, size: size),
                           from: NSRect(origin: .zero, size: image.size),
                           operation: .sourceOver,
                           fraction: 1.0)
                
                dragImage.unlockFocus()
            } else {
                // fallback placeholder
                dragImage = NSImage(size: size)
                dragImage.lockFocus()
                let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: 8, yRadius: 8)
                NSColor.systemBlue.setFill()
                path.fill()
                dragImage.unlockFocus()
            }
        } else {
            // fallback placeholder
            dragImage = NSImage(size: size)
            dragImage.lockFocus()
            let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: 8, yRadius: 8)
            NSColor.systemBlue.setFill()
            path.fill()
            dragImage.unlockFocus()
        }
        
        // Create pasteboard item
        let pasteboardItem = NSPasteboardItem()
        
        if let uri = fileUri {
            let fileURL = URL(fileURLWithPath: uri)
            pasteboardItem.setData(fileURL.dataRepresentation, forType: .fileURL)
            pasteboardItem.setString(fileURL.lastPathComponent, forType: .string)
        } else {
            pasteboardItem.setString("placeholder", forType: .string)
        }
        
        // Create NSDraggingItem
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(NSRect(origin: point, size: dragImage.size), contents: dragImage)
        
        // Begin drag session
        let draggingSession = flutterView.beginDraggingSession(
            with: [draggingItem], event: NSEvent(), source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = false
    }
    
    public func draggingSession(
        _ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation
    ) {
        print("Drag ended at \(screenPoint) with operation \(operation.rawValue)")
    }
    
    private func findFlutterView(in view: NSView?) -> NSView? {
        guard let view = view else { return nil }
        if NSStringFromClass(type(of: view)) == "FlutterView" {
            return view
        }
        for subview in view.subviews {
            if let found = findFlutterView(in: subview) {
                return found
            }
        }
        return nil
    }
    
    public func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        switch context {
        case .outsideApplication:
            // allow drag to other apps
            return .copy
        case .withinApplication:
            // allow drag inside the same app
            return .copy
        @unknown default:
            return .copy
        }
    }
}
