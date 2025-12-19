import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';

/// HMAC-SHA256 数字签名工具类（对称签名，需共享密钥）
class HmacSha256Signature {
  // HMAC 密钥
  static const _serverSignatureKey = 'bH1BfaNEp7AXVozVXaWe87lPn35RjNQy';

  // /// 1. 生成安全的 HMAC 密钥（推荐32字节=256位，增强安全性）
  // /// [keyLength] 密钥长度（字节），最小16字节，推荐32字节
  // static String generateSecureKey({int keyLength = 32}) {
  //   // 生成随机字节（安全随机数，避免伪随机）
  //   final randomBytes = Uint8List(keyLength);
  //
  //   for (int i = 0; i < keyLength; i++) {
  //     randomBytes[i] = (DateTime.now().microsecond % 256);
  //   }
  //
  //   // 转 Base64
  //   return base64.encode(randomBytes);
  // }

  /// 2. 生成 HMAC-SHA256 签名
  /// [data] 待签名的原始字符串
  /// [secretKey] 共享密钥（Base64格式，generateSecureKey生成）
  static String sign(String data, String secretKey) {
    try {
      // step1 解码密钥（Base64→字节）
      final keyBytes = base64.decode(secretKey);

      // step2 数据转UTF8字节（统一编码，避免中文乱码）
      final dataBytes = utf8.encode(data);

      // step3 计算HMAC-SHA256哈希
      final hmac = Hmac(sha256, keyBytes);
      final digest = hmac.convert(dataBytes);

      // step4 转Base64
      String result = base64.encode(digest.bytes);
      debugPrint("数字签名生成成功：$result");
      return result;
    } catch (e) {
      throw Exception("HMAC-SHA256签名失败：$e");
    }
  }

  /// 3. 生成十六进制格式的 HMAC-SHA256 签名
  static String signToHex(String data, String secretKey) {
    final keyBytes = utf8.encode(secretKey);
    final dataBytes = utf8.encode(data);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);
    // 转十六进制
    return hex.encode(digest.bytes);
  }

  /// 4. 验证 HMAC-SHA256 签名
  /// [data] 原始字符串
  /// [signature] 待验证的签名（Base64格式）
  /// [secretKey] 共享密钥（Base64格式）
  static bool verify(String data, String signature, String secretKey) {
    try {
      // step1 重新计算签名
      final calculatedSign = sign(data, secretKey);

      // step2 对比签名（恒等对比，防计时攻击）
      return _constantTimeCompare(calculatedSign, signature);
    } catch (e) {
      return false;
    }
  }

  /// 4. 恒等对比（防计时攻击，避免通过耗时差异破解密钥）
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}