library;

export 'drop_widget.dart';

import 'package:flutter/services.dart';
import 'package:flutter_drop/drop_registry.dart';

class FlutterDrop {
  static const MethodChannel _channel = MethodChannel("flutter_drop");

  static void initialize() {
    _channel.setMethodCallHandler(_handleCall);
  }

  static Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == "hitTestAt") {
      final x = call.arguments["x"] as double;
      final y = call.arguments["y"] as double;
      return DropRegistry.hitTest(Offset(x, y));
    }

    return null;
  }
}
