import 'dart:convert';
import 'dart:typed_data';

import 'package:communication_channel/utils/Hmac-Sha256_signature/Hmac-Sha256_signature.dart';
import 'package:communication_channel/utils/base64UrlSafe_tool/base64UrlSafe_tool.dart';
import 'package:communication_channel/utils/encryption_decryption_tool/DES_tool.dart';
import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class NetworkTool {
  // Talkhive 测试环境的业务服务器的各种 Key
  static const _serverSecretApiKey = 'RPtoMN82OYFLwtBaH9d2y37m';
  static const _serverSignatureKey = 'bH1BfaNEp7AXVozVXaWe87lPn35RjNQy';
  static const _serverSecretKey = 'X3N9bDHrUXt';

  /// 发送网络请求：
  /// [baseUrl] 服务器最底层域名
  /// [path] 访问路径
  /// [query] 查询参数（可空）
  /// [payload] 请求消息体参数（可空）
  /// [timestamp] 时间戳
  /// [device] 设备信息
  static Future<bool> networkRequestion ({
      required String baseUrl,
      required String path,
      Map<String, dynamic>? query,
      Map<String, dynamic>? payload,
      required String method
  })async{
    try{
      // step1 整合请求参数
      // 具体请求 Url：
      final requestUrl = baseUrl + path;
      // Q ：需不需要自动填充 Url 头部？"https://" or "http://"?

      // step2 消息体进行 DES 加密 + base64UrlSafe 编码 & step3 信息整合
      // 整合需要生成数字签名的数据信息：

      // device 信息加密：
      final device = query!['device'] as String;
      debugPrint("device 加密开始————————————————————");
      final encryptedDevice =await DESTool.desEncryptECB(plainText: device) as String;
      debugPrint("device 加密成功！ $encryptedDevice");

      // 填充 Query ：
      Map<String,dynamic> newQuery = {
        'app_key':_serverSecretApiKey,
        'device':encryptedDevice,
        'timestamp':_createTimestamp()
      };

      // payload信息加密
      debugPrint("payload 加密开始————————————————————");
      String newPayload = "";
      if(payload != null){
        newPayload = MapToString(payload);
      }
      final encryptedPayload =await DESTool.desEncryptECB(plainText: newPayload) as String;
      debugPrint("payload 加密成功！ $encryptedPayload");
      // 空字符串也会进行加密
      // final str = await DESTool.desDecrypt(base64UrlSafe: encryptedPayload) as String;
      // debugPrint("🎮：$str");

      // 准备数字签名所要使用的数据：
      Map<String,dynamic> encryptedParams = {
        'method': method,
        'path':path,
        'query':MapToString(newQuery),
        'payload':newPayload
      };

      // 将 Map 类型转为 String 类型：
      debugPrint("数字签名所需参数连接开始————————————————————");
      final strParams = _linkSignatureData(encryptedParams);

      // step4 生成数字签名
      debugPrint("开始生成数字签名———————————————————————————");
      final signature = HmacSha256Signature.signToHex(strParams, _serverSignatureKey);
      Uint8List signatureBytes = Uint8List.fromList(hex.decode(signature));
      // 数字签名转为 base64UrlSafe 格式：
      final base64UrlSafeSignature = Base64UrlSafeTool.encode(signatureBytes);
      debugPrint("数字签名: $base64UrlSafeSignature");

      // step5 整合数字签名+加密后的消息体
      // 填充 Header ：
      Map<String,dynamic> header = {
        'Content-Type':"application/json",
        'X-Signature':base64UrlSafeSignature,
        'X-Crypto':'des'
      };

      // step6 向目标服务器发送网络请求
      // 初始化 Dio
      debugPrint("开始初始化 dio ————————————————————");
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: header, // header
          queryParameters: newQuery, // 请求参数
          validateStatus: (status) => true,
          responseType: ResponseType.bytes,
        )
      );

      // 发送 dio 网络请求：
      debugPrint("准备发送网络请求————————————————————");
      Response? response ;

      // 根据传入的方法调用：
      switch(method){
        case 'POST':
          response = await dio.post(
            path,
            data: newPayload,
            queryParameters: newQuery, // 请求参数
          );
          break;
        case 'GET':
          response = await dio.get(
            path,
            //data: newPayload,
            queryParameters: newQuery, // 请求参数
          );
          break;
      }
       
      // step7 请求参数 & 响应参数 打印（debug）
      // 打印完整的请求信息
      debugPrint("请求method：${dio.options.method}");
      debugPrint("请求URL：${dio.options.baseUrl}$path");
      debugPrint("请求query：${dio.options.queryParameters}");
      debugPrint("请求头：${dio.options.headers}");

      if (response == null) {
        throw StateError("请求未执行，response为空");
      }

      // 打印完整响应 - 查看服务器返回的错误提示
      print("响应状态码：${response.statusCode}");
      // 服务器的具体错误返回
      print("响应数据：${response.data}");

      // step8 base64 解码：
      Uint8List responsebytes = response.data as Uint8List;
      String responseStr = base64.encode(responsebytes);
      print("响应数据 base64 ：$responseStr");

      // step9 DES 解密：
      String decryptedData =await DESTool.desDecryptECB(base64UrlSafe: responseStr) as String;
      print("响应数据解密成功：$decryptedData");

      return true;
    }catch(e){
      debugPrint("通信失败: $e");
      return false;
    }
  }

  /// 将 Map<String,dynamic> 类型转为 String 类型的工具：
  static String MapToString (Map<String,dynamic> params){
    // step1 对 key 进行排序：
    List<String> sortedKeys = params.keys.toList()..sort();

    // step2 对所有 key 进行遍历：
    Iterable<String> keyValuePairs = sortedKeys.map((key){
      dynamic value = params[key] ?? "";
      return "$key=$value";
    });

    // step3 用 & 进行拼接：
    String resultStr = keyValuePairs.join('&');
    debugPrint("已成功链接🔗所有参数：$resultStr");
    return resultStr;
  }

  /// 与服务器相同的自定义链接数字签名方法：
  static String _linkSignatureData (Map<String,dynamic> signatureParams){
    // POST/PUT请求签名算法如下：
    // signature = Base64URLSafe(HMAC_SHA_256(appSignatureKey, Http Method + '\n' + RequestURI + '\n' + QueryString + '\n' + Payload));
    // GET/DELETE请求没有请求体，Payload需要用空字符串代替，签名算法如下：
    // signature = Base64URLSafe(HMAC_SHA_256(appSignatureKey, Http Method + '\n' + RequestURI + '\n' + QueryString + '\n'  + ""));

    String signatureStr = "${signatureParams['method']}\n${signatureParams['path']}\n${signatureParams['query']}\n${signatureParams['payload']}";

    debugPrint("数字签名参数已链接🔗完成：$signatureStr");
    return signatureStr;
  }

  /// 生成当前请求时间的时间戳：
  static String _createTimestamp(){
    // 毫秒级别时间戳：
    String timestampMs = DateTime.now().millisecondsSinceEpoch.toString();
    debugPrint("请求时间⏰时间戳：$timestampMs");
    return timestampMs;
  }
}