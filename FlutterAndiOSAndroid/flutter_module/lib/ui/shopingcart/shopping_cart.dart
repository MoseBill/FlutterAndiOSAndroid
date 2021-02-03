import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/http_manager/api.dart';
import 'package:fluttermodule/utils/router.dart';
import 'package:fluttermodule/utils/toast.dart';
import 'package:fluttermodule/utils/user_config.dart';
import 'package:fluttermodule/utils/util_mine.dart';
import 'package:fluttermodule/widget/back_loading.dart';
import 'package:fluttermodule/widget/cart_check_box.dart';
import 'package:fluttermodule/widget/colors.dart';
import 'package:fluttermodule/widget/shopping_cart_count.dart';
import 'package:fluttermodule/widget/slivers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShoppingCart extends StatefulWidget {
  final Map argument;

  const ShoppingCart({Key key, this.argument}) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  /*
  *   属性
  * */
  var _data; // 完整数据
  List _cartGroupList = List(); // 有效的购物车组列表
  var _topItem; // 顶部商品数据
  List _itemList = List(); // 显示的商品数据
  List _invalidCartGroupList = List(); // 无效的购物车组列表
  double _price = 0; // 价格
  double _promotionPrice = 0; // 促销价
  double _actualPrice = 0; // 实际价格

  bool isChecked = false; // 是否全部勾选选中
  bool _isCheckedAll = false; // 是否全部勾选选中

  bool loading = false; // 是否正在加载
  int _selectedNum = 0; // 选中商品数量

  bool isEdit = false; // 是否正在编辑

  int allCount = 0;
  List checkList = [];

  /*
  *   初始化
  * */
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  /*
  *   数据逻辑
  * */

  // 获取购物车数据
  void _getData() async {
    Map<String, dynamic> params = {"csrf_token": csrf_token}; // 参数
    Map<String, dynamic> header = {"Cookie": cookie}; // 请求头

    var responseData = await shoppingCart(params, header: header);
    print(responseData.toString());
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  // 更新状态机 刷新界面
  void setData(var _data) {
    if (_data == null) {
      _getData();
    }
    setState(() {
      try {
        loading = false;
        _cartGroupList = _data['cartGroupList'];
        _invalidCartGroupList = _data['invalidCartGroupList'];
        _price = double.parse(_data['actualPrice'].toString());
        _promotionPrice = double.parse(_data['promotionPrice'].toString());
        _actualPrice = double.parse(_data['actualPrice'].toString());

        if (_cartGroupList.length > 0) {
          _topItem = _cartGroupList[0];
          if (_cartGroupList.length > 1) {
            _itemList = _cartGroupList;
            _itemList.removeAt(0);

            _selectedNum = 0;
            for (int i = 0; i < _itemList.length; i++) {
              List itemItems = _itemList[i]['cartItemList'];
              for (int i = 0; i < itemItems.length; i++) {
                if (itemItems[i]['checked']) {
                  print('/////////////');
                  _selectedNum += itemItems[i]['cnt'];
                }
              }
            }

            for (int i = 0; i < _itemList.length; i++) {
              List itemItems = _itemList[i]['cartItemList'];
              for (int i = 0; i < itemItems.length; i++) {
                _isCheckedAll = true;
                if (!itemItems[i]['checked']) {
                  _isCheckedAll = false;
                  return;
                }
              }
            }
          }
        }
      } catch (e) {
        loading = false;
      }
    });
  }

  // 购物车 全选/不选 网络请求
  _check() async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'isChecked': isChecked
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheck(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  // 购物车  某个勾选框 选/不选 请求
  _checkOne(int source, int type, int skuId, bool isChecked, var extId) async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'source': source,
      'type': type,
      'skuId': skuId,
      'isChecked': isChecked,
      'extId': extId,
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheckOne(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  // 购物车  商品 选购数量变化 请求
  _checkOneNum(int source, int type, int skuId, int cnt, var extId) async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'source': source,
      'type': type,
      'skuId': skuId,
      'cnt': cnt,
      'extId': extId,
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheckNum(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  _specValue(var item) {
    List specList = item['specList'];
    String specName = '';
    for (var value in specList) {
      specName += value['specValue'];
      specName += "; ";
    }
    var replaceRange =
        specName.replaceRange(specName.length - 2, specName.length - 1, "");
    return replaceRange;
  }

  // 获取价格
  _getPrice() {
    return _price;
  }

  // 编辑状态 删除
  void _deleteCheckItem(bool check, itemData, item) {
    if (check) {
      var map = {
        "type": item['type'],
        "promId": itemData['promId'],
        "addBuy": false,
        "skuId": item['skuId'],
        "extId": item['extId']
      };
      setState(() {
        checkList.add(map);
      });
    } else {
      if (checkList.length > 0) {
        for (int i = 0; i < checkList.length; i++) {
          if (checkList[i]['skuId'] == item['skuId']) {
            setState(() {
              checkList.removeAt(i);
            });
          }
        }
      }
    }
    print(checkList);
  }

  // 清空购物车
  void _deleteCart() async {
    Map<String, dynamic> item = {
      "skuList": checkList,
    };
    Map<String, dynamic> params = {
      'selectedSku': json.encode(item),
      "csrf_token": csrf_token,
    };

    Map<String, dynamic> header = {
      "Cookie": cookie,
      "csrf_token": csrf_token,
    };

    print(params);
    var responseData = await deleteCart(params, header: header);

    if (responseData.code == "200") {
      print('===============');
      _data = responseData.data;
      setData(_data);
    }
  }

  /*
  *       UI 部分
  * */

  @override
  Widget build(BuildContext context) {
    var argument = widget.argument;

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        centerTitle: true,
        title: _navBar(),
        leading: argument == null
            ? Container()
            : GestureDetector(
                child: Icon(
                  Icons.arrow_back,
                  color: redColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
      ),
      body: Stack(
        children: [
          _data == null ? Loading() : _buildData(context),
          Positioned(
            child: _buildBuy(),
            bottom: 0,
            left: 0,
            right: 0,
          ),
          loading ? Loading() : Container(),
        ],
      ),
    );
  }

  _buildData(BuildContext context) {
    return Positioned(
      child: (_data == null ||
              _cartGroupList.isEmpty ||
              _cartGroupList.length == 0)
          ? NoMoreData()
          : MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: CustomScrollView(
                slivers: [
                  singleSliverWidget(_buildTitle()),
                  singleSliverWidget(_dataList()),
                  singleSliverWidget(_invalidList()),
                  singleSliverWidget(Container(
                    height: 50,
                  ))
                ],
              )),
      bottom: 50,
      top: 0,
      //MediaQuery.of(context).padding.top + 46,
      left: 0,
      right: 0,
    );
  }

  //  导航头
  Widget _navBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(bottom: BorderSide(color: backColor,width: 1))
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '购物车',
                style: t18black,
              ),
            ),
          ),
          isEdit
              ? Container()
              : Container(
              padding: EdgeInsets.symmetric(horizontal: 6,vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: backRed
                  ),
                  child: Text(
                    '领券',
                    style: t14white,
                  ),
                ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                checkList.clear();
                isEdit = !isEdit;
              });
            },
            child: Text(
              isEdit ? '完成' : '编辑',
              style: t14black,
            ),
          )
        ],
      ),
    );
  }

  // 导航下面，商品上面  标题部分
  Widget _buildTitle() {
    return _topItem == null
        ? Container()
        : Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  color: textLightYellow,
                  padding: EdgeInsets.only(left: 15),
                  height: ScreenUtil().setHeight(40),
                  child: Text(
                    '${_data['postageVO']['postageTip']}',
                    style: t14red,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 6),
                        padding: EdgeInsets.fromLTRB(5, 1, 5, 2),
                        decoration: BoxDecoration(
                            color: redLightColor,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          '全场换购',
                          style: t12white,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_topItem['promTip']}',
                          style: t14black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      GestureDetector(
                        child: Row(
                          children: [
                            Text(
                              '${_topItem['promotionBtn'] == 3 ? '再逛逛' : '去凑单'}',
                              style: t14red,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: textRed,
                              size: 14,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    margin: EdgeInsets.fromLTRB(50, 0, 15, 0),
                    color: Color(0xFFFFF7F5),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                Text(_actualPrice > 100 ? '去换购商品' : '查看换购商品',style: t12black,)),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: textGrey,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 6,
                )
              ],
            ),
          );
  }

  // 有效商品列表
  Widget _dataList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var itemData = _itemList[index];
        List itemList = itemData['cartItemList'];
        List<Widget> itemItems = itemList.map<Widget>((item) {
          return _buildItem(itemData, item, index);
        }).toList();
        itemItems.add(line);
        return Column(
          children: itemItems,
        );
      },
      itemCount: _itemList.length,
    );
  }

  // 有效商品列表Item
  Widget _buildItem(var itemData, var item, int index) {
    List cartItemTips = item['cartItemTips'];
    return Container(
      margin: EdgeInsets.only(bottom: 0.5),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCheckBox(itemData, item, index),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: backGrey,
                      borderRadius: BorderRadius.circular(4)),
                  height: 90,
                  width: 90,
                  child: CachedNetworkImage(imageUrl: item['pic']),
                ),
                onTap: () {
                  _goDetail(item);
                },
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isEdit
                            ? Container()
                            : Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  '${item['itemName']}',
                                  style: t14black,
                                ),
                              ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: lineColor, width: 1)),
                          child: Text(
                            '${_specValue(item)}',
                            style: t12grey,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                child: Text(
                                  '¥${item['actualPrice'] == 0 ? item['actualPrice'] : item['retailPrice']}',
                                  style: t14blackblod,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    item['retailPrice'] > item['actualPrice']
                                        ? '¥${item['retailPrice']}'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textGrey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 3),
                                child: CartCount(
                                  number: item['cnt'],
                                  min: 1,
                                  max: item['sellVolume'],
                                  onChange: (index) {
                                    _checkOneNum(item['source'], item['type'],
                                        item['skuId'], index, item['extId']);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _goDetail(item);
                  },
                ),
              )
            ],
          ),
          (cartItemTips == null || cartItemTips.length == 0)
              ? Container()
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(32, 10, 0, 0),
                  decoration: BoxDecoration(color: backGrey,borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cartItemTips.map((item) {
                      return Container(
                        child: Text(
                          '• ${item}',
                          style: t12lgrey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  // 无效商品列表
  Widget _invalidList() {
    return (_invalidCartGroupList == null || _invalidCartGroupList.length == 0)
        ? Container()
        : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: lineColor, width: 0.3))),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      '失效商品',
                      style: t16black,
                    )),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: lineColor, width: 0.5)),
                      child: Text(
                        '清除失效商品',
                        style: t14black,
                      ),
                    )
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: new NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildInvalidItem(_invalidCartGroupList[index]);
                },
                itemCount: _invalidCartGroupList.length,
              ),
            ],
          );
  }

  // 无效商品列表Item
  Widget _buildInvalidItem(var itemD) {
    List items = itemD['cartItemList'];
    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 0.5),
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: backGrey,
                        borderRadius: BorderRadius.circular(4)),
                    height: 90,
                    width: 90,
                    child: CachedNetworkImage(imageUrl: item['pic']),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              '${item['itemName']}',
                              style: t16grey,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                            child: Text(
                              '${_specValue(item)}',
                              style: t14grey,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '¥${item['retailPrice']}',
                                  style: t14grey,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 底部 商品勾选状态、价格信息、下单 部分
  Widget _buildBuy() {
    if (isEdit) {
      return Container(
        color: Colors.white,
        height: ScreenUtil().setHeight(50),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  '已选(${checkList.length})',
                  style: t14grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (checkList.length > 0) {
                  _deleteCart();
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 10),
                alignment: Alignment.center,
                color: checkList.length > 0 ? redColor : Color(0xFFB4B4B4),
                padding: EdgeInsets.symmetric(horizontal: 40),
                height: double.infinity,
                child: Text(
                  '删除所选',
                  style: t14white,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 15),
              child: InkWell(
                onTap: () {
                  setState(() {
                    // _isCheckedAll = !_isCheckedAll;
                    isChecked = !isChecked;
                    _check();
                  });
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: _isCheckedAll
                        ? Icon(
                            Icons.check_circle,
                            size: 22,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.brightness_1_outlined,
                            size: 22,
                            color: lineColor,
                          ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(bottom: 3),
                child: Text(
                  '已选($_selectedNum)',
                  style: t14grey,
                ),
              ),
              onTap: () {
                setState(() {
                  // _isCheckedAll = !_isCheckedAll;
                  isChecked = !isChecked;
                  _check();
                });
              },
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        '合计：¥${_getPrice()}',
                        style: t16red,
                      ),
                    ),
                    _promotionPrice == 0
                        ? Container()
                        : Container(
                            child: Text(
                              '已优惠：¥$_promotionPrice',
                              style: t14grey,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                alignment: Alignment.center,
                color: _getPrice() > 0 ? redColor : Color(0xFFB4B4B4),
                padding: EdgeInsets.symmetric(horizontal: 40),
                height: double.infinity,
                child: Text(
                  '下单',
                  style: t14white,
                ),
              ),
              onTap: () {
                Toast.show('暂未开发', context);
                // Routers.push(Util.webView, context,{'id':'https://m.you.163.com/order/confirm?sfrom=3995230&_stat_referer=itemDetail_buy'});
              },
            )
          ],
        ),
      );
    }
  }

  ///左侧选择框，编辑框
  _buildCheckBox(itemData, item, index) {
    if (isEdit) {
      return Container(
        margin: EdgeInsets.only(right: 6),
        child: CartCheckBox(
          onCheckChanged: (check) {
            _deleteCheckItem(check, itemData, item);
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(right: 6),
        child: InkWell(
          onTap: () {
            if (itemData['canCheck'] || item['checked']) {
              _checkOne(item['source'], item['type'], item['skuId'],
                  !item['checked'], item['extId']);
            }
          },
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(2),
              child: item['checked']
                  ? Icon(
                      Icons.check_circle,
                      size: 22,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.brightness_1_outlined,
                      size: 22,
                      color:
                          itemData['canCheck'] ? lineColor : Color(0xFFF7F6FA),
                    ),
            ),
          ),
        ),
      );
    }
  }

  // 分割线
  Widget line = Container(
    height: 10,
    color: Color(0xFFEAEAEA),
  );

  void _goDetail(var itemData) {
    Routers.push(
        Util.goodDetailTag, context, {'id': itemData['itemId'].toString()});
  }
}

class NoMoreData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/cart_none.png',
            width: 96,
            height: 96,
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          Text("去添加点什么吧！")
        ],
      ),
    );
  }
}
