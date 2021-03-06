import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';

import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

import 'package:yqboots/src/apps/github-client/index.dart';

/// 个人详情
class PersonPage extends StatefulWidget {
  static final String sName = "person";

  final String userName;

  PersonPage(this.userName, {Key key}) : super(key: key);

  @override
  _PersonState createState() => _PersonState(userName);
}

class _PersonState extends BasePersonState<PersonPage> {
  final String userName;

  String beStaredCount = "---";

  bool focusStatus = false;

  String focus = "";

  User userInfo = User.empty();

  final List<UserOrg> orgList = List();

  final OptionControl titleOptionControl = OptionControl();

  _PersonState(this.userName);

  _resolveUserInfo(res) {
    if (isShow) {
      setState(() {
        userInfo = res.data;
        titleOptionControl.url = res.data.html_url;
      });
    }
  }

  @override
  Future<Null> handleRefresh() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page = 1;
    var userResult = await UserDao.getUserInfo(userName, needDb: true);
    if (userResult != null && userResult.result) {
      _resolveUserInfo(userResult);
      if (userResult.next != null) {
        userResult.next.then((resNext) {
          _resolveUserInfo(resNext);
        });
      }
    } else {
      return null;
    }
    var res = await _getDataLogic();
    resolveRefreshResult(res);
    resolveDataResult(res);
    if (res.next != null) {
      var resNext = await res.next;
      resolveRefreshResult(resNext);
      resolveDataResult(resNext);
    }
    isLoading = false;
    _getFocusStatus();
    ReposDao.getUserRepository100StatusDao(_getUserName()).then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            beStaredCount = res.data.toString();
          });
        }
      }
    });
    return null;
  }

  _getFocusStatus() async {
    var focusRes = await UserDao.checkFollowDao(userName);
    if (isShow) {
      setState(() {
        focus = (focusRes != null && focusRes.result)
            ? CommonUtils.getLocale(context).user_focus
            : CommonUtils.getLocale(context).user_un_focus;
        focusStatus = (focusRes != null && focusRes.result);
      });
    }
  }

  _getUserName() {
    if (userInfo == null) {
      return User.empty();
    }
    return userInfo.login;
  }

  _getDataLogic() async {
    if (userInfo.type == "Organization") {
      return await UserDao.getMemberDao(_getUserName(), page);
    }
    getUserOrg(_getUserName());
    return await EventDao.getEventDao(_getUserName(), page: page, needDb: page <= 1);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {}

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: GSYTitleBar(
          (userInfo != null && userInfo.login != null) ? userInfo.login : "",
          rightWidget: GSYCommonOptionWidget(titleOptionControl),
        )),
        floatingActionButton: FloatingActionButton(
            child: Text(focus),
            onPressed: () {
              if (focus == '') {
                return;
              }
              if (userInfo.type == "Organization") {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).user_focus_no_support);
                return;
              }
              CommonUtils.showLoadingDialog(context);
              UserDao.doFollowDao(userName, focusStatus).then((res) {
                Navigator.pop(context);
                _getFocusStatus();
              });
            }),
        body: GSYPullLoadWidget(
          pullLoadWidgetControl,
          (BuildContext context, int index) => renderItem(index, userInfo, beStaredCount, null, null, orgList),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshIndicatorKey,
        ));
  }
}
