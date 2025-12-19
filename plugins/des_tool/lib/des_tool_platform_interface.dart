import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'des_tool_method_channel.dart';

abstract class DesToolPlatform extends PlatformInterface {
  /// Constructs a DesToolPlatform.
  DesToolPlatform() : super(token: _token);

  static final Object _token = Object();

  static DesToolPlatform _instance = MethodChannelDesTool();

  /// The default instance of [DesToolPlatform] to use.
  ///
  /// Defaults to [MethodChannelDesTool].
  static DesToolPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DesToolPlatform] when
  /// they register themselves.
  static set instance(DesToolPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
