import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluttermodule/http_manager/net_contants.dart';

class GlobalCookie {
  static const _channel = MethodChannel('plugins.want.flutter.io.GloableCookie');

  factory GlobalCookie() {
    return _instance ??= GlobalCookie._();
  }

  GlobalCookie._();

  static GlobalCookie _instance;

  /// Get globalCookieValue
  Future<String> globalCookieValue(String url) {
   return  _channel
       .invokeMethod<String>('globalCookieValue', {'url': url})
       .then<String>((String result) {
           return result;
        });
  }
  /// Get globalCookieValue
  Future<bool> clearCookie() {
   return  _channel
       .invokeMethod<bool>('clearCookie', {'url': NetContants.baseUrl})
       .then<bool>((bool result) {
           return result;
        });
  }


}
