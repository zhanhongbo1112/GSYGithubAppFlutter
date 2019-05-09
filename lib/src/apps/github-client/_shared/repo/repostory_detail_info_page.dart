import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/apps/github-client/event/index.dart';
import 'package:yqboots/src/apps/github-client/index.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

/// 仓库详情动态信息页面
class ReposDetailInfoPage extends StatefulWidget {
  final String userName;

  final String reposName;

  final OptionControl titleOptionControl;

  ReposDetailInfoPage(this.userName, this.reposName, this.titleOptionControl, {Key key}) : super(key: key);

  @override
  ReposDetailInfoPageState createState() => ReposDetailInfoPageState(userName, reposName, titleOptionControl);
}

class ReposDetailInfoPageState extends State<ReposDetailInfoPage>
    with AutomaticKeepAliveClientMixin<ReposDetailInfoPage>, GSYListState<ReposDetailInfoPage> {
  final String userName;

  final String reposName;

  final OptionControl titleOptionControl;

  Repository repository = Repository.empty();

  int selectIndex = 0;

  ReposDetailInfoPageState(this.userName, this.reposName, this.titleOptionControl);

  ///渲染时间Item或者提交Item
  _renderEventItem(index) {
    if (index == 0) {
      return ReposHeaderItem(ReposHeaderViewModel.fromHttpMap(userName, reposName, repository), (index) {
        selectIndex = index;
        clearData();
        showRefreshLoading();
      });
    }

    if (selectIndex == 1) {
      ///提交
      return EventItem(
        EventViewModel.fromCommitMap(pullLoadWidgetControl.dataList[index - 1]),
        onPressed: () {
          RepoCommit model = pullLoadWidgetControl.dataList[index - 1];
          NavigatorUtils.goPushDetailPage(context, userName, reposName, model.sha, false);
        },
        needImage: false,
      );
    }
    return EventItem(
      EventViewModel.fromEventMap(pullLoadWidgetControl.dataList[index - 1]),
      onPressed: () {
        EventUtils.ActionUtils(context, pullLoadWidgetControl.dataList[index - 1], userName + "/" + reposName);
      },
    );
  }

  ///获取列表
  _getDataLogic() async {
    if (selectIndex == 1) {
      return await ReposDao.getReposCommitsDao(
        userName,
        reposName,
        page: page,
        branch: ReposDetailModel.of(context).currentBranch,
        needDb: page <= 1,
      );
    }
    return await ReposDao.getRepositoryEventDao(
      userName,
      reposName,
      page: page,
      branch: ReposDetailModel.of(context).currentBranch,
      needDb: page <= 1,
    );
  }

  ///获取详情
  _getReposDetail() {
    ReposDao.getRepositoryDetailDao(userName, reposName, ReposDetailModel.of(context).currentBranch).then((result) {
      if (result != null && result.result) {
        setState(() {
          repository = result.data;
          titleOptionControl.url = repository.htmlUrl;
        });
        return result.next;
      }
      return Future.value(null);
    }).then((result) {
      if (result != null && result.result) {
        setState(() {
          repository = result.data;
          titleOptionControl.url = repository.htmlUrl;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
    _getReposDetail();
    return await _getDataLogic();
  }

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
    super.build(context); //

    return ScopedModelDescendant<ReposDetailModel>(
      builder: (context, child, model) {
        return GSYPullLoadWidget(
          pullLoadWidgetControl,
          (BuildContext context, int index) => _renderEventItem(index),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshIndicatorKey,
        );
      },
    ); // See
  }
}
