import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// 仅支持 Uint8List 与 String 之间的转换.
class Base64UrlSafeTool {
  /// 编码：
  static String encode(Uint8List bytes) {
    String encodeResult = base64.encode(bytes);

    encodeResult = encodeResult
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
    print("base64UrlSafe编码结果: $encodeResult");
    return encodeResult;
  }

  /// 解码：
  static Uint8List decode(String urlStr) {
    // 补全填充符（4的倍数）
    int padding = 4 - (urlStr.length % 4);
    if (padding != 4) {
      urlStr += '=' * padding;
    }
    // 还原为标准Base64
    String base64Str = urlStr
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    print("还原后标准base64: $base64Str");
    // 解码容错
    try {
      Uint8List decodeResult = base64.decode(base64Str);
      debugPrint("解码成功！字节长度：${decodeResult.length}");
      return decodeResult;
    } catch (e) {
      print("解码异常：$e");
      return Uint8List(0);
    }
  }
}