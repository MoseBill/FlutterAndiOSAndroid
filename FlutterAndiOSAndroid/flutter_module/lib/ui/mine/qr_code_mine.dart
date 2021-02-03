import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/widget/back_loading.dart';
import 'package:fluttermodule/widget/colors.dart';
import 'package:fluttermodule/widget/tab_app_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeMine extends StatefulWidget {
  @override
  _QRCodeMineState createState() => _QRCodeMineState();
}

class _QRCodeMineState extends State<QRCodeMine> {
  var qrCodeDate;
  var userData;

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: TabAppBar(
        title: '邀请返利',
      ).build(context),
      body: isLoading
          ? Loading()
          : Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  margin: EdgeInsets.fromLTRB(20, 90, 20, 0),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          userData['nickname'],
                          style: TextStyle(
                              fontSize: 16,
                              color: textBlack,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '用户ID:${userData['userId']}',
                              style: TextStyle(color: textGrey),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.fromLTRB(8, 3, 8, 4),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: redColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                '复制',
                                style: TextStyle(color: redColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: QrImage(data: qrCodeDate['qrCode']),
                      ),
                      Container(
                        child: Text(
                          '线下店结账时出示二维码\n享受更多权益',
                          style: TextStyle(height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                  height: 80,
                  child: ClipOval(
                    child: CachedNetworkImage(imageUrl: user_icon_url),
                  ),
                )
              ],
            ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();

    _getQrCode();
  }

  _getData() async {
    Map<String, dynamic> header = {
      "Cookie": cookie,
      "csrf_token": csrf_token,
    };
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
    };
    Future.wait([
      qrCode(params, header: header).then((value) {
        return value;
      }),
      getUserSpmcInfo(params, header: header).then((value) {
        return value;
      })
    ]).then((result) {
      setState(() {
        isLoading = false;
        qrCodeDate = result[0].data;
        userData = result[1].data;
      });
    });
  }

  Timer timer;

  _getQrCode() async {
    Timer.periodic(Duration(milliseconds: 5000), (timer) {
      this.timer = timer;

      Map<String, dynamic> header = {
        "Cookie": cookie,
        "csrf_token": csrf_token,
      };
      Map<String, dynamic> params = {
        "csrf_token": csrf_token,
      };

       qrCode(params, header: header).then((responseData) {
        setState(() {
          qrCodeDate = responseData.data;
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }
}
