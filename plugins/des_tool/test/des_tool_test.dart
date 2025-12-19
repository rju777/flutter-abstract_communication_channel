import 'package:flutter_test/flutter_test.dart';
import 'package:des_tool/des_tool.dart';
import 'package:des_tool/des_tool_platform_interface.dart';
import 'package:des_tool/des_tool_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDesToolPlatform
    with MockPlatformInterfaceMixin
    implements DesToolPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DesToolPlatform initialPlatform = DesToolPlatform.instance;

  test('$MethodChannelDesTool is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDesTool>());
  });

  test('getPlatformVersion', () async {
    DesTool desToolPlugin = DesTool();
    MockDesToolPlatform fakePlatform = MockDesToolPlatform();
    DesToolPlatform.instance = fakePlatform;

    expect(await desToolPlugin.getPlatformVersion(), '42');
  });
}
