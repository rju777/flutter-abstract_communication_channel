import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'des_tool_platform_interface.dart';

/// An implementation of [DesToolPlatform] that uses method channels.
class MethodChannelDesTool extends DesToolPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('des_tool');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
