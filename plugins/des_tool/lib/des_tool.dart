
import 'package:flutter/services.dart';

import 'des_tool_platform_interface.dart';

class ChannelConstants {
  static const String desChannel = "com.example/des"; // 通道标识
  static const String methodEncrypt = "desEncrypt"; // 加密方法名
  static const String methodDecrypt = "desDecrypt"; // 解密方法名
}

class DesTool {

  Future<String?> getPlatformVersion() {
    return DesToolPlatform.instance.getPlatformVersion();
  }
}
