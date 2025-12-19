package com.example.des_tool

import android.util.Log
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

class DesToolPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val CHANNEL = "com.example/des"
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("DES_Plugin", "插件绑定引擎，注册Channel")
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("DES_Plugin", "插件收到方法调用：${call.method}")
        when (call.method) {
            "desEncryptECB" -> handleEncryptECB(call, result) // 新增ECB加密方法
            "desDecryptECB" -> handleDecryptECB(call, result) // 新增ECB解密方法
            else -> result.notImplemented()
        }
    }

    // ECB模式加密（无IV）
    private fun handleEncryptECB(call: MethodCall, result: MethodChannel.Result) {
        val plainText = call.argument<String>("plainText") ?: ""
        val keyStr = call.argument<String>("key") ?: ""

        // 校验密钥：必须8个字符（UTF8编码后8字节）
//        if (keyStr.length != 8) {
//            result.error("INVALID_KEY", "密钥必须8个字符", null)
//            return
//        }

        try {
            val cipherText = desEncryptECB(plainText, keyStr)
            result.success(cipherText)
        } catch (e: Exception) {
            Log.e("DES_Plugin", "ECB加密失败：${e.message}", e)
            result.error("ENCRYPT_ERROR", e.message, null)
        }
    }

    // ECB模式解密（无IV）
    private fun handleDecryptECB(call: MethodCall, result: MethodChannel.Result) {
        val cipherText = call.argument<String>("cipherText") ?: ""
        val keyStr = call.argument<String>("key") ?: ""

//        if (keyStr.length != 8) {
//            result.error("INVALID_KEY", "密钥必须8个字符", null)
//            return
//        }

        try {
            val plainText = desDecryptECB(cipherText, keyStr)
            result.success(plainText)
        } catch (e: Exception) {
            Log.e("DES_Plugin", "ECB解密失败：${e.message}", e)
            result.error("DECRYPT_ERROR", e.message, null)
        }
    }

    // DES-ECB加密核心（无IV，PKCS5Padding，UTF8）
    private fun desEncryptECB(plainText: String, keyStr: String): String {
        // 密钥：UTF8编码为8字节
//        val keyBytes = keyStr.toByteArray(StandardCharsets.UTF_8)
        val keyBytes = Base64.decode(keyStr,Base64.DEFAULT);
        val keySpec = SecretKeySpec(keyBytes, "DES")

        // ECB模式 + PKCS5填充（和后端对齐）
        val cipher = Cipher.getInstance("DES/ECB/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, keySpec) // ECB无需IV

        // 明文转UTF8字节
        val plainBytes = plainText.toByteArray(StandardCharsets.UTF_8)
        val encryptedBytes = cipher.doFinal(plainBytes)

        // 标准Base64编码（NO_WRAP，保留填充符=）
        return Base64.encodeToString(encryptedBytes, Base64.NO_WRAP)
    }

    // DES-ECB解密核心（和加密对称）
    private fun desDecryptECB(cipherText: String, keyStr: String): String {
        val keyBytes = Base64.decode(keyStr,Base64.DEFAULT);
        val keySpec = SecretKeySpec(keyBytes, "DES")

        val cipher = Cipher.getInstance("DES/ECB/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, keySpec)

        // 解码密文：和加密时的Base64参数一致（仅NO_WRAP）
        val encryptedBytes = Base64.decode(cipherText, Base64.NO_WRAP)
        val decryptedBytes = cipher.doFinal(encryptedBytes)

        // 明文UTF8解码
        return String(decryptedBytes, StandardCharsets.UTF_8)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}