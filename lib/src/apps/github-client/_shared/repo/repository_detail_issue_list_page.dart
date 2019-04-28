import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_daos/index.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_shared/index.dart';

import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/**
 * 仓库详情issue列表
 * Created by guoshuyu
 * Date: 2018-07-19
 */
class RepositoryDetailIssuePage extends StatefulWidget {
  final String userName;

  final String reposName;

  RepositoryDetailIssuePage(this.userName, this.reposName);

  @override
  _RepositoryDetailIssuePageState createState() => _RepositoryDetailIssuePageState(userName, reposName);
}

class _RepositoryDetailIssuePageState extends State<RepositoryDetailIssuePage>
    with AutomaticKeepAliveClientMixin<RepositoryDetailIssuePage>, GSYListState<RepositoryDetailIssuePage> {
  final String userName;

  final String reposName;

  String searchText;
  String issueState;
  int selectIndex;

  _RepositoryDetailIssuePageState(this.userName, this.reposName);

  _renderEventItem(index) {
    IssueItemViewModel issueItemViewModel = IssueItemViewModel.fromMap(pullLoadWidgetControl.dataList[index]);
    return IssueItem(
      issueItemViewModel,
      onPressed: () {
        NavigatorUtils.goIssueDetail(context, userName, reposName, issueItemViewModel.number);
      },
    );
  }

  _resolveSelectIndex() {
    clearData();
    switch (selectIndex) {
      case 0:
        issueState = null;
        break;
      case 1:
        issueState = 'open';
        break;
      case 2:
        issueState = "closed";
        break;
    }
    showRefreshLoading();
  }

  _getDataLogic(String searchString) async {
    if (searchString == null || searchString.trim().length == 0) {
      return await IssueDao.getRepositoryIssueDao(userName, reposName, issueState, page: page, needDb: page <= 1);
    }
    return await IssueDao.searchRepositoryIssue(searchString, userName, reposName, this.issueState, page: this.page);
  }

  _createIssue() {
    String title = "";
    String content = "";
    CommonUtils.showEditDialog(context, CommonUtils.getLocale(context).issue_edit_issue, (titleValue) {
      title = titleValue;
    }, (contentValue) {
      content = contentValue;
    }, () {
      if (title == null || title.trim().length == 0) {
        Fluttertoast.showToast(msg: CommonUtils.getLocale(context).issue_edit_issue_title_not_be_null);
        return;
      }
      if (content == null || content.trim().length == 0) {
        Fluttertoast.showToast(msg: CommonUtils.getLocale(context).issue_edit_issue_content_not_be_null);
        return;
      }
      CommonUtils.showLoadingDialog(context);
      //提交修改
      IssueDao.createIssueDao(userName, reposName, {"title": title, "body": content}).then((result) {
        showRefreshLoading();
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }, needTitle: true, titleController: TextEditingController(), valueController: TextEditingController());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  bool get needHeader => false;

  @override
  bool get isRefreshFirst => true;

  @override
  requestLoadMore() async {
    return await _getDataLogic(this.searchText);
  }

  @override
  requestRefresh() async {
    return await _getDataLogic(this.searchText);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(offset: Offset(0, 1), color: Theme.of(context).primaryColorDark, blurRadius: 1.0)],
              color: Color(GSYColors.primaryValue),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Icon(
            GSYICons.ISSUE_ITEM_ADD,
            size: 50.0,
            color: Color(GSYColors.textWhite),
          )),
      backgroundColor: Color(GSYColors.mainBackgroundColor),
      appBar: AppBar(
        leading: Container(),
        flexibleSpace: GSYSearchInputWidget((value) {
          this.searchText = value;
        }, (value) {
          _resolveSelectIndex();
        }, () {
          _resolveSelectIndex();
        }),
        elevation: 0.0,
        backgroundColor: Color(GSYColors.mainBackgroundColor),
        bottom: GSYSelectItemWidget([
          CommonUtils.getLocale(context).repos_tab_issue_all,
          CommonUtils.getLocale(context).repos_tab_issue_open,
          CommonUtils.getLocale(context).repos_tab_issue_closed,
        ], (selectIndex) {
          this.selectIndex = selectIndex;
          _resolveSelectIndex();
        }),
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
