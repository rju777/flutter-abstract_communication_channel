import 'dart:async';
import 'dart:io';

// import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
// import 'package:flutter_practice/config/router.dart';
// import 'package:flutter_practice/presentation/app/app.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceUtil {
  static DeviceUtil? _instance;
  late final DeviceInfoPlugin _plugin;
  final Map<String, dynamic> _zeetokDeviceMap = {};
  PackageInfo? _packageInfo;
  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  DeviceUtil._() {
    _plugin = DeviceInfoPlugin();
  }

  factory DeviceUtil() {
    _instance ??= DeviceUtil._();
    return _instance!;
  }

  FutureOr<PackageInfo> get packageInfo async {
    if (_packageInfo != null) {
      return _packageInfo!;
    }
    _packageInfo = await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  FutureOr<AndroidDeviceInfo> get androidDeviceInfo async {
    if (_androidDeviceInfo != null) {
      return _androidDeviceInfo!;
    }
    _androidDeviceInfo = await _plugin.androidInfo;
    return _androidDeviceInfo!;
  }

  FutureOr<IosDeviceInfo> get iosDeviceInfo async {
    if (_iosDeviceInfo != null) {
      return _iosDeviceInfo!;
    }
    _iosDeviceInfo = await _plugin.iosInfo;
    return _iosDeviceInfo!;
  }

  Future<Map<String, dynamic>> getZeetokDeviceInfo() async {
    if (_zeetokDeviceMap.isEmpty) {
      PackageInfo info = await packageInfo;
      _zeetokDeviceMap['version_number'] = info.buildNumber.toString();
      _zeetokDeviceMap['did'] = await getDid();
      if (Platform.isAndroid) {
        final androidInfo = await androidDeviceInfo;
        _zeetokDeviceMap['type'] = '1';
        _zeetokDeviceMap['phone_model'] = androidInfo.model;
        _zeetokDeviceMap['system_version'] = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await iosDeviceInfo;
        _zeetokDeviceMap['type'] = '2';
        _zeetokDeviceMap['phone_model'] =
            iOSNameTransition(iosInfo.utsname.machine);
        _zeetokDeviceMap['system_version'] = iosInfo.systemVersion;
      } else {
        throw (UnsupportedError('platform not supported'));
      }
    }

    _zeetokDeviceMap['lang'] = 'en'; //lang
    _zeetokDeviceMap['country'] =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '';
    // todo - 这个要接原生实现
    _zeetokDeviceMap['sim_country'] = '';
    _zeetokDeviceMap['time_zone'] = DateTime.now().timeZoneName;
    _zeetokDeviceMap['net_type'] = await getNetType();
    // todo - 这个要接原生实现
    _zeetokDeviceMap['vpn_used'] = false;
    // todo - 这个要接原生实现
    _zeetokDeviceMap['source'] = -1;
    // todo - 这个要接原生实现
    _zeetokDeviceMap['campaign'] = false;
    // todo - 这个要查额外接口
    _zeetokDeviceMap['reviewer'] = false;
    return _zeetokDeviceMap;
  }

  Future<String> getDid() async {
    if (Platform.isAndroid) {
      final androidInfo = await androidDeviceInfo;
      return androidInfo.id ?? ''; // 等价于原来的Android ID
    } else if (Platform.isIOS) {
      var did = await FlutterKeychain.get(key: 'did');
      if (did == null) {
        final iosInfo = await iosDeviceInfo;
        did = iosInfo.identifierForVendor ?? '';
        await FlutterKeychain.put(key: 'did', value: did);
      }
      return did;
    } else {
      throw (UnsupportedError('platform not supported'));
    }
  }

  Future<String> getNetType() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.isEmpty) {
      return 'UNKNOWN';
    }
    if (connectivityResult.first == ConnectivityResult.mobile) {
      return '4G';
    } else if (connectivityResult.first == ConnectivityResult.wifi) {
      return 'WIFI';
    } else {
      return 'UNKNOWN';
    }
  }

  static String iOSNameTransition(String machine) {
    switch (machine) {
      case "iPod5,1":
        return "iPod Touch 5";
      case "iPod7,1":
        return "iPod Touch 6";
      case "iPhone3,1":
        return "iPhone 4";
      case "iPhone3,2":
        return "iPhone 4";
      case "iPhone3,3":
        return "iPhone 4";
      case "iPhone4,1":
        return "iPhone 4s";
      case "iPhone5,1":
        return "iPhone 5";
      case "iPhone5,2":
        return "iPhone 5";
      case "iPhone5,3":
        return "iPhone 5c";
      case "iPhone5,4":
        return "iPhone 5c";
      case "iPhone6,1":
        return "iPhone 5s";
      case "iPhone6,2":
        return "iPhone 5s";
      case "iPhone7,2":
        return "iPhone 6";
      case "iPhone7,1":
        return "iPhone 6 Plus";
      case "iPhone8,1":
        return "iPhone 6s";
      case "iPhone8,2":
        return "iPhone 6s Plus";
      case "iPhone8,4":
        return "iPhone SE";
      case "iPhone9,1":
        return "iPhone 7";
      case "iPhone9,3":
        return "iPhone 7";
      case "iPhone9,2":
        return "iPhone 7 Plus";
      case "iPhone9,4":
        return "iPhone 7 Plus";
      case "iPhone10,1":
        return "iPhone 8";
      case "iPhone10,4":
        return "iPhone 8";
      case "iPhone10,2":
        return "iPhone 8 Plus";
      case "iPhone10,5":
        return "iPhone 8 Plus";
      case "iPhone10,3":
        return "iPhone X";
      case "iPhone10,6":
        return "iPhone X";
      case "iPhone11,8":
        return "iPhone XR";
      case "iPhone11,2":
        return "iPhone XS";
      case "iPhone11,6":
        return "iPhone XS Max";
      case "iPhone11,4":
        return "iPhone XS Max";
      case "iPhone12,1":
        return "iPhone 11";
      case "iPhone12,3":
        return "iPhone 11 Pro";
      case "iPhone12,5":
        return "iPhone 11 Pro Max";
      case "iPhone13,1":
        return "iPhone 12 mini";
      case "iPhone13,2":
        return "iPhone 12";
      case "iPhone13,3":
        return "iPhone 12 Pro";
      case "iPhone13,4":
        return "iPhone 12 Pro Max";
      case "iPhone14,4":
        return "iPhone 13 mini";
      case "iPhone14,5":
        return "iPhone 13";
      case "iPhone14,2":
        return "iPhone 13 Pro";
      case "iPhone14,3":
        return "iPhone 13 Pro Max";
      case "iPhone14,6":
        return "iPhone SE (3rd generation)";
      case "iPhone14,7":
        return "iPhone 14";
      case "iPhone14,8":
        return "iPhone 14 Plus";
      case "iPhone15,2":
        return "iPhone 14 Pro";
      case "iPhone15,3":
        return "iPhone 14 Pro Max";
      case "iPhone15,4":
        return "iPhone 15";
      case "iPhone15,5":
        return "iPhone 15 Plus";
      case "iPhone16,1":
        return "iPhone 15 Pro";
      case "iPhone16,2":
        return "iPhone 15 Pro Max";

      case "iPad2,1":
        return "iPad 2";
      case "iPad2,2":
        return "iPad 2";
      case "iPad2,3":
        return "iPad 2";
      case "iPad2,4":
        return "iPad 2";

      case "iPad3,1":
        return "iPad 3";
      case "iPad3,2":
        return "iPad 3";
      case "iPad3,3":
        return "iPad 3";

      case "iPad3,4":
        return "iPad 4";
      case "iPad3,5":
        return "iPad 4";
      case "iPad3,6":
        return "iPad 4";

      case "iPad4,1":
        return "iPad Air";
      case "iPad4,2":
        return "iPad Air";
      case "iPad4,3":
        return "iPad Air";

      case "iPad5,3":
        return "iPad Air 2";
      case "iPad5,4":
        return "iPad Air 2";

      case "iPad2,5":
        return "iPad Mini";
      case "iPad2,6":
        return "iPad Mini";
      case "iPad2,7":
        return "iPad Mini";

      case "iPad4,4":
        return "iPad Mini 2";
      case "iPad4,5":
        return "iPad Mini 2";
      case "iPad4,6":
        return "iPad Mini 2";

      case "iPad4,7":
        return "iPad Mini 3";
      case "iPad4,8":
        return "iPad Mini 3";
      case "iPad4,9":
        return "iPad Mini 3";

      case "iPad5,1":
        return "iPad Mini 4";
      case "iPad5,2":
        return "iPad Mini 4";

      case "iPad6,7":
        return "iPad Pro";
      case "iPad6,8":
        return "iPad Pro";

      case "AppleTV5,3":
        return "Apple TV";
      case "i386":
        return "Simulator";
      case "x86_64":
        return "Simulator";
      default:
        return machine;
    }
  }

  // String get lang {
  //   final context = AppRouter.navigatorKey.currentContext;
  //   if (context == null) {
  //     return 'en';
  //   }
  //   final appCubit = context.read<AppCubit>();
  //   final locale = appCubit.state.locale;
  //   return locale.languageCode;
  // }
}
