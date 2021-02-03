import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/http_manager/api_service.dart';
import 'package:fluttermodule/ui/webview_page.dart';
import 'package:fluttermodule/utils/router.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/utils/util_mine.dart';
import 'package:fluttermodule/widget/back_loading.dart';
import 'package:fluttermodule/widget/colors.dart';
import 'package:fluttermodule/widget/slivers.dart';
import 'package:fluttermodule/widget/webview_login_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../channel/globalCookie.dart';
import '../../config/cookieConfig.dart';

class UserPage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  final globalCookie = GlobalCookie();
  bool _islogin = true;

  bool _firstLoading = true;
  List mineItems = [];
  var userInfo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _checkLogin();
  }

  ///检查是否登录
  _checkLogin() async {
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      "__timestamp": "${DateTime.now().millisecondsSinceEpoch}"
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await checkLogin(params, header: header);
    var isLogin = responseData.data;
    if (isLogin) {
      _getUserInfo();
    } else {
      setState(() {
        _islogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return _islogin
    //     ? Scaffold(
    //         backgroundColor: Colors.white,
    //         body: _firstLoading
    //             ? Loading()
    //             : (userInfo == null
    //                 ? Container()
    //                 : CustomScrollView(
    //                     slivers: <Widget>[
    //                       _buildTop(context),
    //                       _buildTitle(context),
    //                       _buildMineItems(context),
    //                       _buildMonthCard(context),
    //                       _line(10.0),
    //                       _buildActivity(context),
    //                       _buildAdapter(context),
    //                       _line(1),
    //                       _line(20.0),
    //                       _loginOut(context),
    //                       _line(50.0),
    //                     ],
    //                   )))
    //     : _loginPage(context);
    return ScreenUtilInit(
      designSize: Size(360, 690),
      allowFontScaling: false,
      child: Column(

        // flutter build appbundle --target-platform android-arm
        // theme: ThemeData(
        //   backgroundColor: Colors.transparent,
        //   primarySwatch: Colors.red,
        // ),
        // title: 'Flutter Demo',
        // onGenerateRoute: (RouteSettings settings) {
        //   return Routers.run(settings);
        // },

      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _getUserInfo() async {
    setState(() {
      _firstLoading = true;
    });

    Map<String, dynamic> params = {"csrf_token": csrf_token};
    Map<String, dynamic> header = {"Cookie": cookie};

    try {
      var responseData = await getUserInfo(params, header: header);
      setState(() {
        userInfo = responseData.data;
        setUserInfo();
      });
      var userInfoItems = await getUserInfoItems(params, header: header);
      setState(() {
        mineItems = userInfoItems.data;
        _firstLoading = false;
      });
    } catch (e) {
      setState(() {
        _firstLoading = false;
      });
    }
  }

  _buildTop(BuildContext context) {
    return singleSliverWidget(Container(
      padding: EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top, 15, 0),
      decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEFB965),
          Color(0xFFFFD883),
        ],
      ),),
      height: ScreenUtil().setHeight(140) + MediaQuery.of(context).padding.top,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              image: DecorationImage(
                image: NetworkImage(
                    "https://yanxuan.nosdn.127.net/8945ae63d940cc42406c3f67019c5cb6.png"),
                fit: BoxFit.cover,
              ),
            ), // 通过 container 实现圆角
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo["userSimpleVO"]["nickname"],
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  userInfo["userSimpleVO"]["memberLevel"] == 0
                      ? "普通用户"
                      : "vip用户",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  _buildTitle(BuildContext context) {
    return singleSliverWidget(Container(
      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "我的资产",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            width: double.infinity,
            height: 1,
            color: lineColor,
          )
        ],
      ),
    ));
  }

  _buildMineItems(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 5,
      children: mineItems.map<Widget>((item) {
        Widget widget = Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    item["fundType"] == 1 || item["fundType"] == 4
                        ? "¥${item["fundValue"]}"
                        : "${item["fundValue"]}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(item["fundName"]),
                )
              ],
            ),
          ),
        );
        return Routers.link(widget, Util.mineTopItems, context,
            {"id": item["fundType"], "value": item["fundValue"]});
      }).toList(),
    );
  }

  _buildMonthCard(BuildContext context) {
    var monthCardEntrance = userInfo["monthCardEntrance"];
    return singleSliverWidget(monthCardEntrance == null
        ? Container()
        : Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFF8E4DF)),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: redColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  monthCardEntrance["title"],
                  style: TextStyle(color: textRed, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: redColor,
                  height: 15,
                  width: 1,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    monthCardEntrance["content"],
                    style: TextStyle(
                      color: textRed,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: redColor,
                  size: 16,
                )
              ],
            ),
          ));
  }

  _line(double height) {
    return singleSliverWidget(Container(
      height: height,
      color: backGrey,
    ));
  }

  _buildAdapter(BuildContext context) {
    return SliverGrid.count(
      childAspectRatio: 1.3,
      crossAxisCount: 3,
      children: mineSettingItems.map<Widget>((item) {
        Widget widget = Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: backGrey, width: 1),
                  right: BorderSide(color: backGrey, width: 1))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item["image"],
                width: 30,
                height: 30,
              ),
              SizedBox(
                height: 5,
              ),
              Text(item["name"]),
            ],
          ),
        );
        return Routers.link(
            widget, Util.mineItems, context, {"id": item["id"]});
      }).toList(),
    );
  }

  _buildActivity(BuildContext context) {
    var welfareFissionInfo = userInfo["welfareFissionInfo"];
    return singleSliverWidget(welfareFissionInfo == null
        ? Container()
        : Container(
            margin: EdgeInsets.all(10),
            child: CachedNetworkImage(
                imageUrl: userInfo["welfareFissionInfo"]["picUrl"]),
          ));
  }

  _loginOut(BuildContext context) {
    return singleSliverWidget(
      GestureDetector(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              "退出登录",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        onTap: (){

        },
      ),
    );
  }

  _loginPage(BuildContext context) {
    // Routers.push(Util.webLogin, context,{},_callback);

    return WebLoginWidget(
      onValueChanged: (value) {
        if (value) {
          setState(() {
            _islogin = value;
          });
          _getUserInfo();
        }
      },
    );

    Widget webLogin = WebView(
      //JS执行模式 是否允许JS执行
      initialUrl: LOGIN_PAGE_URL,
      javascriptMode: JavascriptMode.unrestricted,
      onPageStarted: (url) async {},
      onPageFinished: (url) async {
        final updateCookie = await globalCookie.globalCookieValue(url);
        print('更新Cookie-------------->');
        print(updateCookie.toString());
        if (updateCookie.length > 0) {
          setState(() {
            CookieConfig.cookie = updateCookie;
            _islogin = CookieConfig.isLogin;
            if (_islogin) {
              _getUserInfo();
            }
          });
        }
      },
    );
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Colors.white,
      child: webLogin,
    );
  }

  void setUserInfo() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userInfo['userSimpleVO']['nickname']);
    await prefs.setString(
        'pointsCnt', userInfo['userSimpleVO']['pointsCnt'].toString());
  }

  var mineSettingItems = [
    {
      "name": "我的订单",
      "status": "0",
      "image": "assets/images/mine/dingdan.png",
      "id": 0
    },
    {
      "name": "账号管理",
      "status": "0",
      "image": "assets/images/mine/zhanghaoguanli.png",
      "id": 1
    },
    {
      "name": "周六一起拼",
      "status": "0",
      "image": "assets/images/mine/zhouliu.png",
      "id": 2
    },
    {
      "name": "售后服务",
      "status": "0",
      "image": "assets/images/mine/shouhoufuwu.png",
      "id": 3
    },
    {
      "name": "邀请返利",
      "status": "0",
      "image": "assets/images/mine/yaoqingfanli.png",
      "id": 4
    },
    {
      "name": "优先购",
      "status": "0",
      "image": "assets/images/mine/youxiangou.png",
      "id": 5
    },
    {
      "name": "积分中心",
      "status": "0",
      "image": "assets/images/mine/jifenzhongxin.png",
      "id": 6
    },
    {
      "name": "会员俱乐部",
      "status": "0",
      "image": "assets/images/mine/huiyuanzhongxin.png",
      "id": 7
    },
    {
      "name": "地址管理",
      "status": "0",
      "image": "assets/images/mine/dizhiguanli.png",
      "id": 8
    },
    {
      "name": "支付安全",
      "status": "0",
      "image": "assets/images/mine/zhifuanquan.png",
      "id": 9
    },
    {
      "name": "帮助与客服",
      "status": "0",
      "image": "assets/images/mine/kefu.png",
      "id": 10
    },
    {
      "name": "意见反馈",
      "status": "0",
      "image": "assets/images/mine/yijianfankui.png",
      "id": 11
    },
  ];
}

//https://m.you.163.com/xhr/order/getList.json?csrf_token=61f57b79a343933be0cb10aa37a51cc8&size=10&lastOrderId=0&status=5
