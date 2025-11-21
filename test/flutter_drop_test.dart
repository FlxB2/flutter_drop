import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_drop/flutter_drop.dart';
import 'package:flutter_drop/flutter_drop_platform_interface.dart';
import 'package:flutter_drop/flutter_drop_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDropPlatform
    with MockPlatformInterfaceMixin
    implements FlutterDropPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDropPlatform initialPlatform = FlutterDropPlatform.instance;

  test('$MethodChannelFlutterDrop is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDrop>());
  });

  test('getPlatformVersion', () async {
    FlutterDrop flutterDropPlugin = FlutterDrop();
    MockFlutterDropPlatform fakePlatform = MockFlutterDropPlatform();
    FlutterDropPlatform.instance = fakePlatform;

    expect(await flutterDropPlugin.getPlatformVersion(), '42');
  });
}
