import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/net/DioManager.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/widget/slivers.dart';
import 'package:fluttermodule/widget/tab_app_bar.dart';

class PaymentPage extends StatefulWidget {
  final Map arguments;

  const PaymentPage({Key key, this.arguments}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = true;
  var _data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  void _getData() async {
    Map<String, dynamic> header = {"cookie": cookie};
    List list = [];
    list.add(widget.arguments);

    // Map<String, dynamic> argus =   widget.arguments;
    //
    // print(json.encode(argus));
    //
    Map<String, dynamic> cartGroupList = {
      'cartGroupList' :list
    };

    Map<String, dynamic> params = {
      'count':0,
      'purchaseType':1,
      'scene':1,
      'orderId':0,
      'layawayId':0,
      "orderCart": cartGroupList,
      "incognito": false,
    };
    var responseData = await orderInit(params, header: header);
    setState(() {
      _isLoading = false;
      _data = responseData.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabAppBar(
        title: '确认订单',
      ).build(context),
      body: CustomScrollView(
        slivers: [singleSliverWidget(_buildTopTips())],
      ),
    );
  }

  _buildTopTips() {}
}
