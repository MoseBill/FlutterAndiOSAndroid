import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/utils/router.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/utils/util_mine.dart';
import 'package:fluttermodule/widget/colors.dart';
import 'package:fluttermodule/widget/loading.dart';
import 'package:fluttermodule/widget/sliver_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class TopicPage extends StatefulWidget {
  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = new ScrollController();
  ScrollController _scrollBarController = new ScrollController();

  ///第一次加载
  bool isFirstloading = true;
  final int pageSize = 3;
  int page = 1;

  List dataList = [];
  List navList = [];
  bool hasMore = true;
  List roundWords = [];
  int rondomIndex = 0;
  var timer;

  var _alignmentY = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
    _getTopicData();
    _getMore();

    timer = Timer.periodic(Duration(milliseconds: 4000), (timer) {
      setState(() {
        if (roundWords.length > 0) {
          rondomIndex++;
          if (rondomIndex >= roundWords.length) {
            rondomIndex = 0;
          }
        }
      });
    });
  }

  void _getTopicData() async {
    var responseData = await knowNavwap({});
    setState(() {
      isFirstloading = false;
      var data = responseData.data;
      navList = data['navList'];

      // List findMore = data['findMore'];
      // if (findMore == null || findMore.isEmpty) {
      //   banner.add(data['recommendOne']['picUrl']);
      //   topDataList.add(data['recommendOne']['picUrl']);
      // } else {
      //   findMore.forEach((item) {
      //     banner.add(item['itemPicUrl']);
      //     roundWords.add(item['subtitle']);
      //   });
      //   topDataList.addAll(findMore);
      // }
    });

    //
    // Response response = await Dio().get(
    //   'http://m.you.163.com/topic/index.json',
    // );
    // Map<String, dynamic> dataTopic = Map<String, dynamic>.from(response.data);
    // setState(() {
    //   isFirstloading = false;
    //
    //   List findMore = dataTopic['data']['findMore'];
    //   if (findMore == null || findMore.isEmpty) {
    //     banner.add(dataTopic['data']['recommendOne']['picUrl']);
    //     topDataList.add(dataTopic['data']['recommendOne']['picUrl']);
    //   } else {
    //     findMore.forEach((item) {
    //       banner.add(item['itemPicUrl']);
    //       roundWords.add(item['subtitle']);
    //     });
    //     topDataList.addAll(findMore);
    //   }
    // });
  }

  _getMore() async {
    Map<String, dynamic> header = {
      "Cookie": cookie,
      "csrf_token": csrf_token,
    };
    Map<String, dynamic> params = {
      'page': page,
      'size': pageSize,
      'exceptIds': ''
    };

    var responseData = await findRecAuto(params, header: header);
    setState(() {
      page++;
      var data = responseData.data;
      hasMore = data['hasMore'];
      List result = data['result'];
      result.forEach((item) {

        dataList.addAll(item['topics']);
      });
      print("数据打印"+dataList.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGrey,
      body: buildBody(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _scrollBarController.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  buildBody() {
    if (isFirstloading) {
      return Loading();
    } else {
      return _buildBodyData();
    }
  }

  _buildSearch(BuildContext context) {
    Widget widget = Container(
        child: Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Color(0x0D000000),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              roundWords.length > 0 ? roundWords[rondomIndex] : '',
              style: TextStyle(color: textGrey, fontSize: 14),
            ),
          ),
        ),
        Container(
          child: Text(
            '搜索',
            style: t16grey,
          ),
        )
      ],
    ));
    return Routers.link(widget, Util.search, context, {'id': ''});
  }

  _buildItem(var item) {
    var buyNow = item['buyNow'];
    Widget widget = Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: CachedNetworkImage(
              height: 150,
              imageUrl: item['picUrl'],
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Text(
              item['title'],
              textAlign: TextAlign.left,
              style: t14black,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: item['avatar'] == null
                      ? Container()
                      : Container(
                          width: 25,
                          height: 25,
                          child: CachedNetworkImage(
                            imageUrl: item['avatar'],
                            errorWidget: (context, url, error) {
                              return ClipOval(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                Expanded(
                  child: Container(
                    child: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        item['nickname'] == null ? '' : item['nickname'],
                        style: t12grey,
                      ),
                    ),
                  ),
                ),
                Container(
                    child: item['readCount'] == null
                        ? Container()
                        : Icon(
                            Icons.remove_red_eye,
                            color: textGrey,
                            size: 14,
                          )),
                Container(
                  child: Text(
                    item['readCount'] == null
                        ? ''
                        : (item['readCount'] > 1000
                            ? '${int.parse((item['readCount'] / 1000).toStringAsFixed(0))}K'
                            : '${item['readCount']}'),
                    style: t12grey,
                  ),
                ),
              ],
            ),
          ),
          buyNow == null
              ? Container()
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 1,
                  color: lineColor,
                ),
          buyNow == null
              ? Container()
              : GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '${item['buyNow']['itemName']}',
                          style: t12black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          '去购买',
                          style: t12red,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: textRed,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Routers.push(Util.goodDetailTag, context,
                        {'id': '${item['buyNow']['itemId']}'});
                  },
                )
        ],
      ),
    );
    String schemeUrl = item['schemeUrl'];
    if (!schemeUrl.startsWith('http')) {
      schemeUrl = 'https://m.you.163.com$schemeUrl';
    }
    return Routers.link(widget, Util.webView, context, {'id': schemeUrl});
  }

  _stagegeredGridview() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        itemCount: dataList.length,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        staggeredTileBuilder: (index) => new StaggeredTile.fit(1),
        itemBuilder: (context, index) {
          return _buildItem(dataList[index]);
        },
      ),
    );
  }

  _buildBodyData() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          title: _buildSearch(context),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildNav(),
          ),
        ),
        _stagegeredGridview(),
        SliverFooter(
          hasMore: hasMore,
        )
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    print('滚动组件最大滚动距离:${metrics.maxScrollExtent}');
    print('当前滚动位置:${metrics.pixels}');
    setState(() {
      _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    });
    return true;
  }

  _buildNav() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBB9554),
            Colors.white,
          ],
        ),
      ),
      padding:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 60, 0, 5),
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GridView.count(
              crossAxisCount: 2,
              scrollDirection: Axis.horizontal,
              children: navList.map((item) {
                return GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          height: 50,
                          width: 50,
                          child: CachedNetworkImage(
                            imageUrl: item['picUrl'],
                          ),
                        )),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Text('${item['mainTitle']}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: textBlack),
                              maxLines: 1),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Text(
                            '${item['viceTitle']}',
                            style: TextStyle(
                                fontSize: 11,
                                color: textGrey),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Routers.push(
                        Util.webView, context, {'id': '${item['columnUrl']}'});
                  },
                );
              }).toList(),
            ),
            Container(
              height: 4,
              decoration: BoxDecoration(
                  color: lineColor, borderRadius: BorderRadius.circular(2)),
              width: 150,
              alignment: Alignment(_alignmentY, 1),
              child: Container(
                decoration: BoxDecoration(
                    color: redColor, borderRadius: BorderRadius.circular(2)),
                height: 4,
                width: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
