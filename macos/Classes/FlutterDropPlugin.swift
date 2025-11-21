import Cocoa
import FlutterMacOS
import ObjectiveC.runtime

typealias MouseDownIMP = @convention(c) (AnyObject, Selector, NSEvent) -> Void
typealias MouseUpIMP   = @convention(c) (AnyObject, Selector, NSEvent) -> Void

public class FlutterDropPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_drop", binaryMessenger: registrar.messenger)
        let instance = FlutterDropPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        instance.patchFlutterView()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func hitTest(clickX: Double, clickY: Double) {
        channel.invokeMethod("hitTestAt", arguments: ["x": clickX, "y": clickY]) { response in
            if let widgetName = response as? String {
                print("Clicked on widget: \(widgetName)")
            } else {
                print("No widget at this position")
            }
        }
    }
    
    
    // Monkey patch flutter view to receive mouseDown / Up for drag / drop
    private func patchFlutterView() {
        guard let flutterViewClass: AnyClass = NSClassFromString("FlutterView") else {
            print("FlutterView class not found!")
            return
        }
        
        swizzleMethod(flutterViewClass, selector: #selector(NSView.mouseDown(with:))) { view, event in
            // This gets called from FlutterViewWrapper and from FlutterView
            // the coordinates differ slightly, the latter seems to be more accurate
            // offset is approx 83.0 -> maybe statusbar on top of the view is inclueded
            // in FlutterView but not in FlutterViewWrapper, not sure
            // TODO: check this later, FlutterView gives accurate results
            guard NSStringFromClass(type(of: view)) == "FlutterView" else { return }
                            
            if let nsview = view as? NSView {
                let localPoint = nsview.convert(event.locationInWindow, from: nil)
                self.hitTest(clickX: localPoint.x, clickY: localPoint.y)
            }
        }
    }
    
    // Generic monkey patching / swizzle helper
    private func swizzleMethod(_ cls: AnyClass, selector: Selector, handler: @escaping (AnyObject, NSEvent) -> Void) {
        guard let originalMethod = class_getInstanceMethod(cls, selector) else { return }
        let originalIMP = method_getImplementation(originalMethod)
        
        let swizzledBlock: @convention(block) (AnyObject, NSEvent) -> Void = { view, event in
            // Call original implementation
            typealias MethodIMP = @convention(c) (AnyObject, Selector, NSEvent) -> Void
            let imp = unsafeBitCast(originalIMP, to: MethodIMP.self)
            imp(view, selector, event)
            
            // Call custom handler
            handler(view, event)
        }
        
        let imp = imp_implementationWithBlock(swizzledBlock as Any)
        method_setImplementation(originalMethod, imp)
    }
}
