import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_drop_method_channel.dart';

abstract class FlutterDropPlatform extends PlatformInterface {
  /// Constructs a FlutterDropPlatform.
  FlutterDropPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDropPlatform _instance = MethodChannelFlutterDrop();

  /// The default instance of [FlutterDropPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDrop].
  static FlutterDropPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDropPlatform] when
  /// they register themselves.
  static set instance(FlutterDropPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
