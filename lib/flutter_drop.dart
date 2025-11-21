
import 'flutter_drop_platform_interface.dart';

class FlutterDrop {
  Future<String?> getPlatformVersion() {
    return FlutterDropPlatform.instance.getPlatformVersion();
  }
}
