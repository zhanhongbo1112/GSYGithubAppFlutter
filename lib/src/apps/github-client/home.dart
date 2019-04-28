import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

import '../../../common/common.dart';
import '../../../widget/widget.dart';

import './event/index.dart';
import './trend/index.dart';
import './my/index.dart';

/// 主页
class GitHubClientHomePage extends StatelessWidget {
  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );

      await intent.launch();
    }

    return Future.value(false);
  }

  _renderTab(icon, title) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Icon(icon, size: 16.0), Text(title)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _dialogExitApp(context),
      child: GSYTabBarWidget(
        drawer: HomeDrawer(),
        title: GSYTitleBar(
          GSYLocalizations.of(context).currentLocalized.app_name,
          iconData: GSYICons.MAIN_SEARCH,
          needRightLocalIcon: true,
          onPressed: () => NavigatorUtils.goSearchPage(context),
        ),
        backgroundColor: GSYColors.primarySwatch,
        indicatorColor: Color(GSYColors.white),
        type: GSYTabBarWidget.BOTTOM_TAB,
        tabItems: [
          _renderTab(GSYICons.MAIN_DT, CommonUtils.getLocale(context).home_dynamic),
          _renderTab(GSYICons.MAIN_QS, CommonUtils.getLocale(context).home_trend),
          _renderTab(GSYICons.MAIN_MY, CommonUtils.getLocale(context).home_my),
        ],
        tabViews: [EventPage(), TrendPage(), MyPage()],
      ),
    );
  }
}
