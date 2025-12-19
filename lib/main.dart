import 'dart:convert';
import 'dart:typed_data';

import 'package:communication_channel/utils/Hmac-Sha256_signature/Hmac-Sha256_signature.dart';
import 'package:communication_channel/utils/device_util/device_util.dart';
import 'package:communication_channel/utils/encryption_decryption_tool//AES_tool.dart';
import 'package:communication_channel/utils/base64UrlSafe_tool/base64UrlSafe_tool.dart';
import 'package:communication_channel/utils/encryption_decryption_tool/DES_tool.dart';
import 'package:communication_channel/utils/network/network_tool.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget{
  TestPage({super.key});

  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage>{
  final _textController = TextEditingController();

  String bodyStr = "body";
  String encrypted = "";
  String decrypted = "";
  String signature = "";
  String falsifySignature = "";

  // HMAC 密钥
  static const _serverSignatureKey = 'bH1BfaNEp7AXVozVXaWe87lPn35RjNQy';

  final _deviceUtil = DeviceUtil();

  Future<void> _DES_encrypt() async{
    final encryption =await DESTool.desEncrypt(plainText: _textController.text);
    bodyStr = encryption as String;
    update();
  }
  Future<void> _DES_decrypt() async{
    final decryption =await DESTool.desDecrypt(base64UrlSafe: bodyStr);

    bodyStr = decryption as String;
    update();
  }

  Future<void> _testRequest() async{
    try{
      final deviceInfo = await _deviceUtil.getZeetokDeviceInfo() as Map<String,dynamic>;
      final device = jsonEncode(deviceInfo);
      print("device 获取成功：$device");
      final result =await NetworkTool.networkRequestion(
          baseUrl: "http://user-stage.talkhive.live",
          path: "/api/v1/app/config",
          query: {
            'device': device
          },
          method: 'GET'
      );
      print("test request result: $result");
    }catch(e){
      debugPrint("test request error: $e");
    }
  }

  void update(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text("通信工具测试🔧"),),
      floatingActionButton: FloatingActionButton(onPressed: _testRequest),
      body: Column(
        children: [
          // base64UrlSafe test：
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 30,right: 30,top: 20,bottom: 20),
              child: Text(bodyStr),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _textController,
            ),
          ),
          // DES test:
          Container(
            child: Row(
              children: [
                Expanded(child: TextButton(
                    onPressed: (){
                      _DES_encrypt();
                    },
                    child:const Text("DES 加密")),),
                const SizedBox(width: 50,),
                Expanded(child: TextButton(
                    onPressed: (){
                      _DES_decrypt();
                    },
                    child: Text("DES 解密")
                ),)
              ],
            ),
          ),
          // AES test:
          Container(
            child: Row(
              children: [
                Expanded(child: TextButton(
                    onPressed: (){
                      encrypted = AESTool.aesEncrypt(_textController.text);
                      bodyStr = encrypted;
                      update();
                    },
                    child:const Text("AES 加密")),),
                const SizedBox(width: 50,),
                Expanded(child: TextButton(
                    onPressed: (){
                      decrypted = AESTool.aesDecrypt(encrypted);
                      bodyStr = decrypted;
                      update();
                    },
                    child: Text("AES 解密")
                ),)
              ],
            ),
          ),
          //Hmac-Sha256 test:
          TextButton(
              onPressed: (){
                signature = HmacSha256Signature.sign(bodyStr, _serverSignatureKey);
                update();
              },
              child:const Text("生成数字签名")
          ),
          Container(
            padding: const EdgeInsets.only(left: 30,right: 30,top: 20,bottom: 20),
            //height: 100,
            child:  Text("${HmacSha256Signature.signToHex(bodyStr, _serverSignatureKey)}"),
          ),
          TextButton(
              onPressed: (){
                final signatureCheck = HmacSha256Signature.verify(bodyStr, signature, _serverSignatureKey);
                if(signatureCheck == true) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ 数字签名验证成功!")));
                  debugPrint("数字签名验证: $signatureCheck");
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ 数字签名验证失败!")));
                    debugPrint("数字签名验证失败");
                  }
                },
              child: Text("验证原数据")
          ),
          Center(child: Container(
            padding: const EdgeInsets.only(left: 30,right: 30,top: 20,bottom: 20),
            child: Text("篡改后的数据：\n${bodyStr+'falsify'}"),
          ),),
          TextButton(
              onPressed: (){
                final signatureCheck = HmacSha256Signature.verify(bodyStr + 'falsify', signature, _serverSignatureKey);
                if(signatureCheck == true) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ 数字签名验证成功!")));
                  debugPrint("数字签名验证: $signatureCheck");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ 数字签名验证失败!")));
                  debugPrint("数字签名验证失败");
                }
              },
              child: Text("验证篡改后的数据")
          )
        ],
      )
    );
  }
}