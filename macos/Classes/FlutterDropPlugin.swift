import Cocoa
import FlutterMacOS
import ObjectiveC.runtime
import UniformTypeIdentifiers

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
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing or not a dictionary", details: nil))
                return
            }

            guard let x = args["x"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing argument: x", details: nil))
                return
            }
            guard let y = args["y"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing argument: y", details: nil))
                return
            }
            guard let width = args["width"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing argument: width", details: nil))
                return
            }
            guard let height = args["height"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing argument: height", details: nil))
                return
            }

            guard let fileDict = args["fileInfo"] as? [String: Any],
                  let fileInfo = DropFileInfo(dict: fileDict) else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing or invalid argument: file", details: nil))
                return
            }

            startDrag(at: NSPoint(x: x, y: y), size: NSSize(width: width, height: height), fileInfo: fileInfo)
            result("drag started")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func startDrag(at point: NSPoint, size: NSSize, fileInfo: DropFileInfo?) {
        guard let window = NSApp.mainWindow else { return }
        guard let flutterView = findFlutterView(in: window.contentView) else { return }

        let dragImage: NSImage
        if let uri = fileInfo?.uri,
           let image = NSImage(contentsOf: URL(fileURLWithPath: uri)) {
            dragImage = roundedImage(from: image, size: size)
        } else {
            dragImage = roundedPlaceholder(size: size)
        }

        let pasteboardItem = NSPasteboardItem()
        
        if let uri = fileInfo?.uri {
            let fileURL = URL(fileURLWithPath: uri)
            pasteboardItem.setData(fileURL.dataRepresentation, forType: .fileURL)
        } else {
            pasteboardItem.setString("placeholder", forType: .string)
        }
        
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(NSRect(origin: point, size: dragImage.size), contents: dragImage)
        
        // Begin drag session
        let draggingSession = flutterView.beginDraggingSession(
            with: [draggingItem], event: NSEvent(), source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = false
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
        return .copy
    }
    
    func roundedPlaceholder(size: NSSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size),
                                xRadius: 8, yRadius: 8)
        NSColor.systemBlue.setFill()
        path.fill()
        img.unlockFocus()
        return img
    }

    func roundedImage(from image: NSImage, size: NSSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()

        let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size),
                                xRadius: 8, yRadius: 8)
        path.addClip()

        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver,
                   fraction: 1.0)

        img.unlockFocus()
        return img
    }
}

struct DropFileInfo {
    let uri: String

    init?(dict: [String: Any]) {
        guard let uri = dict["uri"] as? String else {
            return nil
        }
        self.uri = uri
    }
}
