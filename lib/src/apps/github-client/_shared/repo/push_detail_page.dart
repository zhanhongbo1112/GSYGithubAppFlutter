import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/apps/github-client/index.dart';

import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-27
 */
class PushDetailPage extends StatefulWidget {
  final String userName;

  final String reposName;

  final String sha;

  final bool needHomeIcon;

  PushDetailPage(this.sha, this.userName, this.reposName, {this.needHomeIcon = false});

  @override
  _PushDetailPageState createState() => _PushDetailPageState(sha, userName, reposName, needHomeIcon);
}

class _PushDetailPageState extends State<PushDetailPage>
    with AutomaticKeepAliveClientMixin<PushDetailPage>, GSYListState<PushDetailPage> {
  final String userName;

  final String reposName;

  final String sha;

  bool needHomeIcon = false;

  PushHeaderViewModel pushHeaderViewModel = PushHeaderViewModel();

  final OptionControl titleOptionControl = OptionControl();

  _PushDetailPageState(this.sha, this.userName, this.reposName, this.needHomeIcon);

  @override
  Future<Null> handleRefresh() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page = 1;
    var res = await _getDataLogic();
    if (res != null && res.result) {
      PushCommit pushCommit = res.data;
      pullLoadWidgetControl.dataList.clear();
      if (isShow) {
        setState(() {
          pushHeaderViewModel = PushHeaderViewModel.forMap(pushCommit);
          pullLoadWidgetControl.dataList.addAll(pushCommit.files);
          pullLoadWidgetControl.needLoadMore = false;
          titleOptionControl.url = pushCommit.htmlUrl;
        });
      }
    }
    isLoading = false;
    return null;
  }

  _renderEventItem(index) {
    if (index == 0) {
      return PushHeader(pushHeaderViewModel);
    }
    PushCodeItemViewModel itemViewModel = PushCodeItemViewModel.fromMap(pullLoadWidgetControl.dataList[index - 1]);
    return PushCodeItem(itemViewModel, () {
      if (Platform.isIOS) {
        NavigatorUtils.gotoCodeDetailPage(
          context,
          title: itemViewModel.name,
          userName: userName,
          reposName: reposName,
          data: itemViewModel.patch,
          htmlUrl: itemViewModel.blob_url,
        );
      } else {
        String html = HtmlUtils.generateCode2HTml(HtmlUtils.parseDiffSource(itemViewModel.patch, false),
            backgroundColor: GSYColors.webDraculaBackgroundColorString, lang: '', userBR: false);
        CommonUtils.launchWebView(context, itemViewModel.name, html);
      }
    });
  }

  _getDataLogic() async {
    return await ReposDao.getReposCommitsInfoDao(userName, reposName, sha);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {}

  @override
  requestLoadMore() async {
    return null;
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    Widget widget = (needHomeIcon) ? null : GSYCommonOptionWidget(titleOptionControl);
    return Scaffold(
      appBar: AppBar(
        title: GSYTitleBar(
          reposName,
          rightWidget: widget,
          needRightLocalIcon: needHomeIcon,
          iconData: GSYICons.HOME,
          onPressed: () {
            NavigatorUtils.goReposDetail(context, userName, reposName);
          },
        ),
      ),
      body: GSYPullLoadWidget(
        pullLoadWidgetControl,
        (BuildContext context, int index) => _renderEventItem(index),
        handleRefresh,
        onLoadMore,
        refreshKey: refreshIndicatorKey,
      ),
    );
  }
}
