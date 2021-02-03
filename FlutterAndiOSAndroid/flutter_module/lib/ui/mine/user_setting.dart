import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/widget/colors.dart';
import 'package:fluttermodule/widget/tab_app_bar.dart';

class UserSetting extends StatefulWidget {
  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  var tabs = [
    {'name': '手机', 'icon': 'assets/images/phone_icon.png', 'value': '未关联'},
    {'name': '邮箱', 'icon': 'assets/images/email_icon.png', 'value': '未关联'},
    {'name': '微信', 'icon': 'assets/images/wechat_icon.png', 'value': '未关联'},
    {'name': 'QQ', 'icon': 'assets/images/qq_icon.png', 'value': '未关联'},
    {'name': '微博', 'icon': 'assets/images/weibo_icon.png', 'value': '未关联'},
    {
      'name': 'Apple ID',
      'icon': 'assets/images/apple_icon.png',
      'value': '未关联'
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> items =_buildItems();
    items.add(_buildBottom());

    return Scaffold(
      appBar: TabAppBar(
        title: '账号管理',
        tabs: [],
        controller: null,
      ).build(context),
      body: Column(
        children: items,
      ),
    );
  }

  _buildItems(){
    return tabs
        .map<Widget>((item) => Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 15),
        padding: EdgeInsets.fromLTRB(0, 10, 15, 10),
        decoration: BoxDecoration(
            border: Border(
                bottom:
                BorderSide(color: splitLineColor, width: 0.5))),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(width: 1, color: textGrey),
              ),
              height: 26,
              width: 26,
              child: Image(
                image: AssetImage(item['icon']),
                color: textGrey,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              child: Text(
                item['name'],
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  item['value'],
                  style: TextStyle(
                      fontSize: 14,
                      color: item['value'] == '未关联'
                          ? textGrey
                          : textBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    ))
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getUserAlias();
  }

  void _getUserAlias() async {
    Map<String, dynamic> params = {"csrf_token": csrf_token};
    Map<String, dynamic> header = {"Cookie": cookie};

    var responseData = await getUserAlias(params, header: header);
    var data = responseData.data;
    setState(() {
      print(responseData.data);
      List alias = data["alias"];
      alias.forEach((element) {
        if (element['aliasType'] == 27) {
          tabs[0]['value'] = element['mobile'];
        } else if (element['aliasType'] == 29) {
          tabs[1]['value'] = element['alias'];
        }
      });
    });
  }

  _buildBottom() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child:
      Text('以上关联仅作为登录方式使用',style: TextStyle(color: textGrey,fontSize: 12),),);
  }
}
