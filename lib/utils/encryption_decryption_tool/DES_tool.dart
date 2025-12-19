import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';

class DESTool {
  static const _channel = MethodChannel("com.example/des");
  static const _serverSecretKey = 'X3N9bDHrUXt';

  /// 标准化8位密钥（UTF-8编码）→ 截断为8字节（DES-ECB必须）
  static String _get8ByteKey() {
    return _serverSecretKey.length >= 8
        ? _serverSecretKey.substring(0, 8)
        : _serverSecretKey.padRight(8, '0');
  }

  /// DES-ECB加密（无IV，原生返回标准Base64密文）
  static Future<String> desEncryptECB({required String plainText}) async {
    try {
      String key8Byte = _serverSecretKey;

      // 调用原生ECB加密方法（无IV）
      String base64Result = await _channel.invokeMethod(
        "desEncryptECB", // 对应原生的方法名
        {
          "plainText": plainText,
          "key": key8Byte,
        },
      );

      // 仅做一次URLSafe替换（和后端解密对齐，不移除=）
      String finalUrlSafeResult = base64Result
          .replaceAll('+', '-')
          .replaceAll('/', '_');

      print("ECB加密结果（URLSafe Base64）: $finalUrlSafeResult");
      return finalUrlSafeResult;
    } catch (e) {
      print("ECB加密错误：$e");
      rethrow;
    }
  }

  /// DES-ECB解密（无IV）
  static Future<String> desDecryptECB({required String base64UrlSafe}) async {
    try {
      // 还原为标准Base64（补=，还原+/_）
      int padding = 4 - (base64UrlSafe.length % 4);
      if (padding != 4) {
        base64UrlSafe += '=' * padding;
      }
      String standardBase64 = base64UrlSafe
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      String key8Byte = _serverSecretKey;
      // 调用原生ECB解密方法
      String plainText = await _channel.invokeMethod(
        "desDecryptECB",
        {
          "cipherText": standardBase64,
          "key": key8Byte,
        },
      );

      print("ECB解密结果：$plainText");
      return plainText;
    } catch (e) {
      print("ECB解密错误：$e");
      rethrow;
    }
  }

  // 保留原有CBC方法（备用），但新增ECB方法
  static Future<String> desEncrypt({required String plainText}) async {
    // 原有CBC逻辑（可保留，或删除）
    try {
      String key8Byte = _get8ByteKey();
      String iv = _generate8ByteIvBase64();
      String base64Result = await _channel.invokeMethod(
        "desEncrypt",
        {
          "plainText": plainText,
          "key": key8Byte,
          "ivBase64": iv,
        },
      );
      String finalUrlSafeResult = base64Result
          .replaceAll('+', '-')
          .replaceAll('/', '_');
      print("直接发送的密文: $finalUrlSafeResult");
      return finalUrlSafeResult;
    } catch (e) {
      print("加密错误：$e");
      rethrow;
    }
  }

  static String _generate8ByteIvBase64() {
    Uint8List ivBytes = Uint8List.fromList(
        List.generate(8, (index) => Random.secure().nextInt(256))
    );
    String ivBase64 = base64.encode(ivBytes);
    print("生成8字节IV的Base64: $ivBase64（长度：${ivBase64.length}）");
    return ivBase64;
  }

  static String encodeWithColonStr(String colonStr) {
    Uint8List strBytes = utf8.encode(colonStr);
    String base64UrlSafe = base64.encode(strBytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
    print("带:字符串编码结果：$base64UrlSafe");
    return base64UrlSafe;
  }

  static String decodeToColonStr(String base64UrlSafe) {
    int padding = 4 - (base64UrlSafe.length % 4);
    if (padding != 4) {
      base64UrlSafe += '=' * padding;
    }
    String standardBase64 = base64UrlSafe
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    Uint8List strBytes = base64.decode(standardBase64);
    String colonStr = utf8.decode(strBytes);
    print("解码还原带:字符串：$colonStr");
    return colonStr;
  }

  static Future<String> desDecrypt({required String base64UrlSafe}) async {
    try {
      String colonStr = decodeToColonStr(base64UrlSafe);
      List<String> parts = colonStr.split(':');
      if (parts.length != 2) {
        throw Exception("密文格式错误：需为「IVBase64:密文Base64UrlSafe」");
      }
      String ivBase64 = parts[0];
      String cipherTextBase64Url = parts[1];
      String key8Byte = _get8ByteKey();
      String plainText = await _channel.invokeMethod(
        "desDecrypt",
        {
          "cipherText": cipherTextBase64Url,
          "key": key8Byte,
          "ivBase64": ivBase64,
        },
      );
      print("解密结果：$plainText");
      return plainText;
    } catch (e) {
      print("解密错误：$e");
      rethrow;
    }
  }
}

