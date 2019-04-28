import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';

import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/// issue detail
class IssueDetailPage extends StatefulWidget {
  final String userName;

  final String reposName;

  final String issueNum;

  final bool needHomeIcon;

  IssueDetailPage(this.userName, this.reposName, this.issueNum, {this.needHomeIcon = false});

  @override
  _IssueDetailPageState createState() => _IssueDetailPageState(issueNum, userName, reposName, needHomeIcon);
}

class _IssueDetailPageState extends State<IssueDetailPage>
    with AutomaticKeepAliveClientMixin<IssueDetailPage>, GSYListState<IssueDetailPage> {
  final String userName;

  final String reposName;

  final String issueNum;

  int selectIndex = 0;

  bool headerStatus = false;

  bool needHomeIcon = false;

  IssueHeaderViewModel issueHeaderViewModel = IssueHeaderViewModel();

  TextEditingController issueInfoTitleControl = TextEditingController();

  TextEditingController issueInfoValueControl = TextEditingController();

  final TextEditingController issueInfoCommitValueControl = TextEditingController();

  final OptionControl titleOptionControl = OptionControl();

  _IssueDetailPageState(this.issueNum, this.userName, this.reposName, this.needHomeIcon);

  _renderEventItem(index) {
    if (index == 0) {
      return IssueHeaderItem(issueHeaderViewModel, onPressed: () {});
    }
    Issue issue = pullLoadWidgetControl.dataList[index - 1];
    return IssueItem(
      IssueItemViewModel.fromMap(issue, needTitle: false),
      hideBottom: true,
      limitComment: false,
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      color: Color(GSYColors.white),
                      border: Border.all(color: Color(GSYColors.subTextColor), width: 0.3)),
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GSYFlexButton(
                        color: Color(GSYColors.white),
                        text: CommonUtils.getLocale(context).issue_edit_issue_edit_commit,
                        onPress: () {
                          _editCommit(issue.id.toString(), issue.body);
                        },
                      ),
                      GSYFlexButton(
                        color: Color(GSYColors.white),
                        text: CommonUtils.getLocale(context).issue_edit_issue_delete_commit,
                        onPress: () {
                          _deleteCommit(issue.id.toString());
                        },
                      ),
                      GSYFlexButton(
                        color: Color(GSYColors.white),
                        text: CommonUtils.getLocale(context).issue_edit_issue_copy_commit,
                        onPress: () {
                          CommonUtils.copy(issue.body, context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  _getDataLogic() async {
    if (page <= 1) {
      _getHeaderInfo();
    }
    return await IssueDao.getIssueCommentDao(userName, reposName, issueNum, page: page, needDb: page <= 1);
  }

  _getHeaderInfo() {
    IssueDao.getIssueInfoDao(userName, reposName, issueNum).then((res) {
      if (res != null && res.result) {
        _resolveHeaderInfo(res);
        return res.next;
      }
      return Future.value(null);
    }).then((res) {
      if (res != null && res.result) {
        _resolveHeaderInfo(res);
      }
    });
  }

  _resolveHeaderInfo(res) {
    Issue issue = res.data;
    setState(() {
      issueHeaderViewModel = IssueHeaderViewModel.fromMap(issue);
      titleOptionControl.url = issue.htmlUrl;
      headerStatus = true;
    });
  }

  _editCommit(id, content) {
    Navigator.pop(context);
    String contentData = content;
    issueInfoValueControl = TextEditingController(text: contentData);
    //编译Issue Info
    CommonUtils.showEditDialog(
      context,
      CommonUtils.getLocale(context).issue_edit_issue,
      null,
      (contentValue) {
        contentData = contentValue;
      },
      () {
        if (contentData == null || contentData.trim().length == 0) {
          Fluttertoast.showToast(msg: CommonUtils.getLocale(context).issue_edit_issue_content_not_be_null);
          return;
        }
        CommonUtils.showLoadingDialog(context);
        //提交修改
        IssueDao.editCommentDao(userName, reposName, issueNum, id, {"body": contentData}).then((result) {
          showRefreshLoading();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      valueController: issueInfoValueControl,
      needTitle: false,
    );
  }

  _deleteCommit(id) {
    Navigator.pop(context);
    CommonUtils.showLoadingDialog(context);
    //提交修改
    IssueDao.deleteCommentDao(userName, reposName, issueNum, id).then((result) {
      Navigator.pop(context);
      showRefreshLoading();
    });
  }

  _editIssue() {
    String title = issueHeaderViewModel.issueComment;
    String content = issueHeaderViewModel.issueDesHtml;
    issueInfoTitleControl = TextEditingController(text: title);
    issueInfoValueControl = TextEditingController(text: content);
    //编译Issue Info
    CommonUtils.showEditDialog(
      context,
      CommonUtils.getLocale(context).issue_edit_issue,
      (titleValue) {
        title = titleValue;
      },
      (contentValue) {
        content = contentValue;
      },
      () {
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
        IssueDao.editIssueDao(userName, reposName, issueNum, {"title": title, "body": content}).then((result) {
          _getHeaderInfo();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      titleController: issueInfoTitleControl,
      valueController: issueInfoValueControl,
      needTitle: true,
    );
  }

  _replyIssue() {
    //回复 Info
    issueInfoTitleControl = TextEditingController(text: "");
    issueInfoValueControl = TextEditingController(text: "");
    String content = "";
    CommonUtils.showEditDialog(
      context,
      CommonUtils.getLocale(context).issue_reply_issue,
      null,
      (replyContent) {
        content = replyContent;
      },
      () {
        if (content == null || content.trim().length == 0) {
          Fluttertoast.showToast(msg: CommonUtils.getLocale(context).issue_edit_issue_content_not_be_null);
          return;
        }
        CommonUtils.showLoadingDialog(context);
        //提交评论
        IssueDao.addIssueCommentDao(userName, reposName, issueNum, content).then((result) {
          showRefreshLoading();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      needTitle: false,
      titleController: issueInfoTitleControl,
      valueController: issueInfoValueControl,
    );
  }

  _getBottomWidget() {
    List<Widget> bottomWidget = (!headerStatus)
        ? []
        : <Widget>[
            FlatButton(
              onPressed: () {
                _replyIssue();
              },
              child: Text(CommonUtils.getLocale(context).issue_reply, style: GSYConstant.smallText),
            ),
            Container(width: 0.3, height: 30.0, color: Color(GSYColors.subLightTextColor)),
            FlatButton(
              onPressed: () {
                _editIssue();
              },
              child: Text(CommonUtils.getLocale(context).issue_edit, style: GSYConstant.smallText),
            ),
            Container(width: 0.3, height: 30.0, color: Color(GSYColors.subLightTextColor)),
            FlatButton(
                onPressed: () {
                  CommonUtils.showLoadingDialog(context);
                  IssueDao.editIssueDao(userName, reposName, issueNum,
                      {"state": (issueHeaderViewModel.state == "closed") ? 'open' : 'closed'}).then((result) {
                    _getHeaderInfo();
                    Navigator.pop(context);
                  });
                },
                child: Text(
                    (issueHeaderViewModel.state == 'closed')
                        ? CommonUtils.getLocale(context).issue_open
                        : CommonUtils.getLocale(context).issue_close,
                    style: GSYConstant.smallText)),
            Container(width: 0.3, height: 30.0, color: Color(GSYColors.subLightTextColor)),
            FlatButton(
                onPressed: () {
                  CommonUtils.showLoadingDialog(context);
                  IssueDao.lockIssueDao(userName, reposName, issueNum, issueHeaderViewModel.locked).then((result) {
                    _getHeaderInfo();
                    Navigator.pop(context);
                  });
                },
                child: Text(
                    (issueHeaderViewModel.locked)
                        ? CommonUtils.getLocale(context).issue_unlock
                        : CommonUtils.getLocale(context).issue_lock,
                    style: GSYConstant.smallText)),
          ];
    return bottomWidget;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
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
    super.build(context); // See AutomaticKeepAliveClientMixin.
    Widget widget = (needHomeIcon) ? null : GSYCommonOptionWidget(titleOptionControl);
    return Scaffold(
      persistentFooterButtons: _getBottomWidget(),
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
