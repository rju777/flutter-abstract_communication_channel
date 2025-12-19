import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class AESTool{
  // 字符串密钥
  static const  _serverSecretKey = 'X3N9bDHrUXt';

  /// 1. 把字符串密钥转化为 Uint8List 类型
  static Key _getKey(){
    // 密钥转 Uint8List 类型：
    Uint8List keyBytes = Uint8List.fromList(_serverSecretKey.codeUnits);
    int keyLength = keyBytes.length;

    // 确保密钥为 16字节
    if(keyLength < 16){
      print("key warning: length not long (complete key automatically)");
      List<int> padding = List<int>.filled(16 - keyLength, 0, growable: false);
      List<int> newBytes = [...keyBytes.toList(), ...padding];
      keyBytes = Uint8List.fromList(newBytes);
    }
    else if(keyBytes.hashCode.bitLength > 16){
      keyBytes = keyBytes.sublist(0,16);
    }

    return Key(keyBytes);
  }

  /// 2. 加密
  static String aesEncrypt (String plainText){
    try{
      // step 1 获取密钥
      final key = _getKey();

      // step 2 生成16字节随机 IV
      final iv = IV.fromLength(16);

      // step 3 创建 AES 加密器实例，指定加密规则
      // 指定为 AES 加密算法
      final aesAlgorithm = AES(
          key,
        mode: AESMode.cbc,
        padding: 'PKCS7'
      );
      final encrypter = Encrypter(aesAlgorithm);

      // step 4 加密
      final encrypted = encrypter.encrypt(plainText,iv: iv);

      // step 5 拼接 IV 和 密文
      final ivBase64 = iv.base64;
      final cipherBase64 = encrypted.base64;

      // step 6 转为 base64UrlSafe 类型
      return "$ivBase64:$cipherBase64"
          .replaceAll('+', '-')
          .replaceAll('/', '_');
          //.replaceAll('=', '');
    }catch(e){
      print("AES encrypt error: $e");
      rethrow;
    }
  }

  /// 3. 解密
  static String aesDecrypt (String cipherText){
    try{
      // step 1 获取密钥
      final key = _getKey();

      // step 2 从 base64UrlSafe 类型还原
      final normalBase64 = cipherText
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      // step 3 拆分 iv 和 密文
      final parts = normalBase64.split(':');
      if(parts.length != 2) throw Exception("cipher text error: need iv or plain text");

      final iv = IV.fromBase64(parts[0]);
      // 补全 base64:
      //final base64Str = _completeBase64Padding(parts[1]);
      //print("${base64Str.length}");
      final cipherBytes = Encrypted.fromBase64(parts[1]);

      // step 4 指定为 AES 解密算法
      final aesAlgorithm = AES(
          key,
          mode: AESMode.cbc,
          padding: 'PKCS7'
      );
      final encrypter = Encrypter(aesAlgorithm);

      // step 5 解密
      return encrypter.decrypt(cipherBytes,iv: iv);
    }catch(e){
      print("AES decrypt error: $e");
      rethrow;
    }
  }
}

