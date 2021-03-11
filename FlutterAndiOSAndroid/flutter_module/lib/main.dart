import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermodule/generated/i18n.dart';
import 'package:fluttermodule/http_manager/api_service.dart';
import 'package:fluttermodule/ui/main/main_page.dart';
import 'package:fluttermodule/utils/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'channel/globalCookie.dart';
import 'config/cookieConfig.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';


void main() {
  runApp(MyApp());
  // 导航的颜色为白色  设置状态栏文字黑色
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final globalCookie = GlobalCookie();

  String plat = "Android";
  String recive = "";
  static const methodChannel = const MethodChannel('flutter_and_native_101');

  static Future<dynamic> invokNative(String method, {Map arguments}) async {
    if (arguments == null) {
      return await methodChannel.invokeMethod(method);
    } else {
      return await methodChannel.invokeMethod(method,arguments);
    }
  }
  Future<dynamic> nativeMessageListener() async {
    methodChannel.setMethodCallHandler((resultCall)  {
      MethodCall call = resultCall;
      String method = call.method;
      Map argments = call.arguments;
      int code = argments["code"];
      String message = argments["message"];
      setState(() {
        recive += " code $code message $message and method $method";
        print(recive);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getCookie();
    
    nativeMessageListener();
  }

  _getCookie() async {
    CookieConfig.cookie = await globalCookie.globalCookieValue(LOGIN_PAGE_URL);
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        // flutter build appbundle --target-platform android-arm
        theme: ThemeData(
          backgroundColor: Colors.transparent,
          primarySwatch: Colors.red,
        ),
        title: 'Flutter Demo',
        onGenerateRoute: (RouteSettings settings) {
          return Routers.run(settings);
        },
        // showPerformanceOverlay: true, // 开启
        //国际化-----------------------------------------------
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        //国际化-----------------------------------------------

        home: MainPage(),

    );
  }
}
