import 'package:flutter/material.dart';
// import 'package:fluttermodule/main/mainContex.dart';
import 'package:fluttermodule/ui/home/home_page.dart';
import 'package:fluttermodule/ui/mine/mine_new.dart';
import 'package:fluttermodule/ui/shopingcart/shopping_cart.dart';
import 'package:fluttermodule/ui/sort/sort_page.dart';
import 'package:fluttermodule/ui/topic/topic_page.dart';
import 'package:fluttermodule/ui/mine/trips.dart';
import 'package:fluttermodule/ui/mine/mine.dart';
// import 'package:fluttermodule/ui/webview_page.dart';
// import 'package:fluttermodule/utils/user_config.dart';
// import 'package:fluttermodule/widget/wrapper.dart';

// import '../../main.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<BottomNavigationBarItem> itemList;
  final pageController = PageController();

  int _tabIndex = 0;

  var homeNew = HomePage();
  var topicPage = TopicPage();
  var sortNew = SortPage();
  var shoppingCart = ShoppingCart();
  var trips = MinePage();
  @override
  Widget build(BuildContext context) {
    // mainContext = context;
    //获取屏幕宽高
    _saveScreenInfo(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(1, 200, 200, 200),
      body: PageView(
        children: <Widget>[
          topicPage,

          sortNew,
          shoppingCart,
          homeNew,
          trips,
        ],
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: itemList,
        onTap: (int index) {
          setState(() {
            _tabIndex = index;
            pageController.jumpToPage(index);
          });
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.red,
        iconSize: 20,
        currentIndex: _tabIndex,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (itemNames.isEmpty) {
      itemNames.add(_Item('首页', 'assets/images/ic_tab_home_active.png',
          'assets/images/ic_tab_home_normal.png'));
      itemNames.add(_Item('分类', 'assets/images/ic_tab_subject_active.png',
          'assets/images/ic_tab_subject_normal.png'));
      itemNames.add(_Item('购物车', 'assets/images/ic_tab_group_active.png',
          'assets/images/ic_tab_group_normal.png'));
      itemNames.add(_Item('其他', 'assets/images/ic_tab_cart_active.png',
          'assets/images/ic_tab_cart_normal.png'));
      itemNames.add(_Item('我的', 'assets/images/ic_tab_profile_active.png',
          'assets/images/ic_tab_profile_normal.png'));
    }

    if (itemList == null) {
      itemList = itemNames
          .map((item) => BottomNavigationBarItem(
                icon: Image.asset(
                  item.normalIcon,
                  width: 22.0,
                  height: 22.0,
                ),
                title: Text(
                  item.name,
                  style: TextStyle(fontSize: 14.0),
                ),
                activeIcon: Image.asset(
                  item.activeIcon,
                  width: 22.0,
                  height: 22.0,
                ),
              ))
          .toList();
    }
  }

  final itemNames = [];

  _saveScreenInfo(BuildContext context) async {
//    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//    final width = MediaQuery.of(context).size.width;
//    final height = MediaQuery.of(context).size.height;
//    SharedPreferences prefs = await _prefs;
//    prefs.setDouble('screen_width', width);
//    prefs.setDouble('screen_height', height);
  }
}

class _Item {
  String name, activeIcon, normalIcon;

  _Item(this.name, this.activeIcon, this.normalIcon);
}
