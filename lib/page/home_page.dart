import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../widget/widget.dart';
import '../page/page.dart';

/// 主页
class HomePage extends StatelessWidget {
  static final String sName = "home";

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }

    return Future.value(false);
  }

  _renderTab(icon, text) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Icon(icon, size: 16.0), Text(text)],
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(GSYICons.MAIN_DT, CommonUtils.getLocale(context).home_dynamic),
      _renderTab(GSYICons.MAIN_QS, CommonUtils.getLocale(context).home_trend),
      _renderTab(GSYICons.MAIN_MY, CommonUtils.getLocale(context).home_my),
    ];
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: GSYTabBarWidget(
        drawer: HomeDrawer(),
        type: GSYTabBarWidget.BOTTOM_TAB,
        tabItems: tabs,
        tabViews: [
          DynamicPage(),
          TrendPage(),
          MyPage(),
        ],
        backgroundColor: GSYColors.primarySwatch,
        indicatorColor: Color(GSYColors.white),
        title: GSYTitleBar(
          GSYLocalizations.of(context).currentLocalized.app_name,
          iconData: GSYICons.MAIN_SEARCH,
          needRightLocalIcon: true,
          onPressed: () {
            NavigatorUtils.goSearchPage(context);
          },
        ),
      ),
    );
  }
}
