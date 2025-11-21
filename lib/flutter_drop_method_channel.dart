import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_drop_platform_interface.dart';

/// An implementation of [FlutterDropPlatform] that uses method channels.
class MethodChannelFlutterDrop extends FlutterDropPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_drop');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
