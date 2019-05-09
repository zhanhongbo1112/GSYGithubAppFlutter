import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';

/// 主页我的tab页
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BasePersonState<MyHomePage> {
  String beStaredCount = '---';

  Color notifyColor = const Color(GSYColors.subTextColor);

  Store<GSYState> _getStore() {
    if (context == null) {
      return null;
    }

    return StoreProvider.of(context);
  }

  _getUserName() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }

    return _getStore()?.state?.userInfo?.login;
  }

  getUserType() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }

    return _getStore()?.state?.userInfo?.type;
  }

  _refreshNotify() {
    UserDao.getNotifyDao(false, false, 0).then((res) {
      Color newColor;
      if (res != null && res.result && res.data.length > 0) {
        newColor = const Color(GSYColors.actionBlue);
      } else {
        newColor = const Color(GSYColors.subLightTextColor);
      }

      if (isShow) {
        setState(() => notifyColor = newColor);
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    pullLoadWidgetControl.needHeader = true;
    super.initState();
  }

  _getDataLogic() async {
    if (_getUserName() == null) {
      return [];
    }

    if (getUserType() == "Organization") {
      return await UserDao.getMemberDao(_getUserName(), page);
    }

    return await EventDao.getEventDao(_getUserName(), page: page, needDb: page <= 1);
  }

  @override
  requestRefresh() async {
    if (_getUserName() != null) {
      _getStore().dispatch(FetchUserAction());
      getUserOrg(_getUserName());
      ReposDao.getUserRepository100StatusDao(_getUserName()).then((res) {
        if (res != null && res.result && isShow) {
          setState(() => beStaredCount = res.data.toString());
        }
      });

      _refreshNotify();
    }

    return await _getDataLogic();
  }

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => false;

  @override
  bool get needHeader => true;

  @override
  void didChangeDependencies() {
    if (pullLoadWidgetControl.dataList.length == 0) {
      showRefreshLoading();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return GSYPullLoadWidget(
          pullLoadWidgetControl,
          (context, index) => renderItem(
                index,
                store.state.userInfo,
                beStaredCount,
                notifyColor,
                () => _refreshNotify(),
                orgList,
              ),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshIndicatorKey,
        );
      },
    );
  }
}
