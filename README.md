# flutter-abstract_communication_channel
目标是实现一个较完全的flutter加解密通信工具！

## 项目配置相关：
为了确保项目运行时不会崩溃/代码导入后不会满屏爆红，还是配置一下比较好哦
（泣

### 项目配置基础配置：

- flutter ： 3.24.5
- gradle ： 8.9.0
- JDK ： 17.x.x
- Android SDK ：34

### 项目yaml文件配置：

yaml<br>dependencies:
<br>  flutter:
<br>    sdk: flutter
<br>  encrypt: 5.0.3
<br>  crypto: any
<br>  convert: any
<br>  dio: any
<br>
<br>  # 设备信息相关
<br>  # android_id: ^0.5.1           # Android ID获取
<br>  connectivity_plus: ^6.0.1      # 网络状态检测
<br>  device_info_plus: ^10.0.1      # 设备硬件/系统信息
<br>  flutter_keychain: ^2.5.0       # iOS Keychain安全存储
<br>  package_info_plus: ^6.0.0      # App版本信息
<br>
<br>  # 状态管理
<br>  flutter_bloc: ^8.1.3           # Bloc状态管理（读取语言配置）
<br>
<br>  # flutter_secure_storage: any
<br>  des_tool:
<br>    path: plugins/des_tool<br>

### Android 配置：
------我先搁置一下！-------
首先是因为涉及原生端的配置，并且如果是整个项目下载的话，其实也不会报错的（...吧？）
（其实是懒
------我后面一定补上啊啊啊啊------

## 具体功能：
### base64UrlSafe 与 Uint8List 转换（编码/解码）：
工具名称：Base64UrlSafe
------待补充-------
### AES 加解密算法实现：
工具名称：AESTool
------待补充-------
### DES 加解密算法实现：
首先说在前面，DES在当前的加解密算法中已经被淘汰了。
因为它的安全性已经完完全全被AES算法替代了。
但是有一些比较老的服务器，使用的仍然是DES加解密的法则；并且flutter上也没有好用的库，还是基于原生端的plugin效果更好，所以才做了这个工具。

工具名称：DESTool
实现了两种加解密方式：
- CBC
- ECB
------待补充-------
### SHMAC-SHA256 数字签名生成：
工具名称：HmacSha256SignatureTool
------待补充-------
### 应用层加解密通信工具：
工具名称：NetworkTool

当前只调通了DES-ECB通信，可以通过相关的请求参数获取服务器返回的加密数据，然后进行解密。
并且有些工具还没实现，没有封装。
目标是实现这个NetworkTool类中可以实现对于不同加解密法则进行自动识别和调用。
就当是学习和记录吧！

------待补充-------
ps ：后续需要补上不同加解密方法的流程图（防止在某些细节上的不同导致的无法调通，并且我要是不写，久点我自己都忘记我写了啥了）
  
