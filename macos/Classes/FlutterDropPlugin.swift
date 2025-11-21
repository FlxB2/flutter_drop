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
        
        let mouseDownSelector = #selector(NSView.mouseDown(with:))
        if let originalMethod = class_getInstanceMethod(flutterViewClass, mouseDownSelector) {
            let originalIMP = method_getImplementation(originalMethod)
            let swizzledBlock: @convention(block) (AnyObject, NSEvent) -> Void = { view, event in
                print("mouseDown intercepted")
                
                if let nsview = view as? NSView {
                    let localPoint = nsview.convert(event.locationInWindow, from: nil)
                    self.hitTest(clickX: localPoint.x, clickY: localPoint.y)
                }
                
                // Call original
                let imp = unsafeBitCast(originalIMP, to: MouseDownIMP.self)
                imp(view, mouseDownSelector, event)
            }
            let imp = imp_implementationWithBlock(swizzledBlock as Any)
            method_setImplementation(originalMethod, imp)
        }
        
        // Swizzle mouseUp
        let mouseUpSelector = #selector(NSView.mouseUp(with:))
        if let originalMethod = class_getInstanceMethod(flutterViewClass, mouseUpSelector) {
            let originalIMP = method_getImplementation(originalMethod)
            let swizzledBlock: @convention(block) (AnyObject, NSEvent) -> Void = { view, event in
                // Custom logic
                print("mouseUp intercepted")
                
                // Call original
                let imp = unsafeBitCast(originalIMP, to: MouseUpIMP.self)
                imp(view, mouseUpSelector, event)
            }
            let imp = imp_implementationWithBlock(swizzledBlock as Any)
            method_setImplementation(originalMethod, imp)
        }
    }
    
    private func swizzleMethod(_ cls: AnyClass, original: Selector, swizzled: Selector) {
        guard let originalMethod = class_getInstanceMethod(cls, original),
              let swizzledMethod = class_getInstanceMethod(FlutterDropPlugin.self, swizzled) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
