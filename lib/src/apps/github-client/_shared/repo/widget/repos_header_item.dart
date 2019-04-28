import 'package:flutter/material.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';
import '../../../../../../common/common.dart';
import '../../../../../../widget/widget.dart';

/// 仓库详情信息头控件
class ReposHeaderItem extends StatelessWidget {
  final SelectItemChanged selectItemChanged;

  final ReposHeaderViewModel reposHeaderViewModel;

  ReposHeaderItem(this.reposHeaderViewModel, this.selectItemChanged) : super();

  ///底部仓库状态信息，比如star数量等
  _getBottomItem(IconData icon, String text, onPressed) {
    return Expanded(
      child: Center(
          child: RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
              child: GSYIConText(
                icon,
                text,
                GSYConstant.smallSubLightText,
                Color(GSYColors.subLightTextColor),
                15.0,
                padding: 3.0,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              onPressed: onPressed)),
    );
  }

  _renderTopicItem(BuildContext context, String item) {
    return RawMaterialButton(
        onPressed: () {
          NavigatorUtils.gotoCommonList(context, item, "repository", "topics", userName: item, reposName: "");
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(0.0),
        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        child: Container(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.5, bottom: 2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            color: Colors.white30,
            border: Border.all(color: Colors.white30, width: 0.0),
          ),
          child: Text(
            item,
            style: GSYConstant.smallSubLightText,
          ),
        ));
  }

  ///话题组控件
  _renderTopicGroup(BuildContext context) {
    if (reposHeaderViewModel.topics == null || reposHeaderViewModel.topics.length == 0) {
      return Container();
    }
    List<Widget> list = List();
    for (String item in reposHeaderViewModel.topics) {
      list.add(_renderTopicItem(context, item));
    }
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(top: 5.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 5.0,
        children: list,
      ),
    );
  }

  ///仓库创建和提交状态信息
  _getInfoText(BuildContext context) {
    String createStr = reposHeaderViewModel.repositoryIsFork
        ? CommonUtils.getLocale(context).repos_fork_at + reposHeaderViewModel.repositoryParentName + '\n'
        : CommonUtils.getLocale(context).repos_create_at + reposHeaderViewModel.created_at + "\n";

    String updateStr = CommonUtils.getLocale(context).repos_last_commit + reposHeaderViewModel.push_at;

    return createStr + ((reposHeaderViewModel.push_at != null) ? updateStr : '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GSYCardItem(
          color: Theme.of(context).primaryColorDark,
          child: Container(
            ///背景头像
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(reposHeaderViewModel.ownerPic ?? GSYICons.DEFAULT_REMOTE_PIC),
              ),
            ),
            child: Container(
              ///透明黑色遮罩
              decoration: BoxDecoration(
                color: Color(GSYColors.primaryDarkValue & 0xA0FFFFFF),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, top: 0.0, right: 10.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ///用户名
                        RawMaterialButton(
                          constraints: BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            NavigatorUtils.goPerson(context, reposHeaderViewModel.ownerName);
                          },
                          child: Text(reposHeaderViewModel.ownerName, style: GSYConstant.normalTextActionWhiteBold),
                        ),
                        Text(" /", style: GSYConstant.normalTextMitWhiteBold),

                        ///仓库名
                        Text(" " + reposHeaderViewModel.repositoryName, style: GSYConstant.normalTextMitWhiteBold),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        ///仓库语言
                        Text(reposHeaderViewModel.repositoryType ?? "--", style: GSYConstant.smallSubLightText),
                        Container(width: 5.3, height: 1.0),

                        ///仓库大小
                        Text(reposHeaderViewModel.repositorySize ?? "--", style: GSYConstant.smallSubLightText),
                        Container(width: 5.3, height: 1.0),

                        ///仓库协议
                        Text(reposHeaderViewModel.license ?? "--", style: GSYConstant.smallSubLightText),
                      ],
                    ),

                    ///仓库描述
                    Container(
                        child: Text(reposHeaderViewModel.repositoryDes ?? "---", style: GSYConstant.smallSubLightText),
                        margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),

                    ///创建状态
                    Container(
                      margin: EdgeInsets.only(top: 6.0, bottom: 2.0, right: 5.0),
                      alignment: Alignment.topRight,
                      child: RawMaterialButton(
                        onPressed: () {
                          if (reposHeaderViewModel.repositoryIsFork) {
                            NavigatorUtils.goReposDetail(context, reposHeaderViewModel.repositoryParentUser,
                                reposHeaderViewModel.repositoryName);
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(0.0),
                        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                        child: Text(_getInfoText(context),
                            style: reposHeaderViewModel.repositoryIsFork
                                ? GSYConstant.smallActionLightText
                                : GSYConstant.smallSubLightText),
                      ),
                    ),
                    Divider(
                      color: Color(GSYColors.subTextColor),
                    ),
                    Padding(
                        padding: EdgeInsets.all(0.0),

                        ///创建数值状态
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ///star状态
                            _getBottomItem(
                              GSYICons.REPOS_ITEM_STAR,
                              reposHeaderViewModel.repositoryStar,
                              () {
                                NavigatorUtils.gotoCommonList(
                                    context, reposHeaderViewModel.repositoryName, "user", "repo_star",
                                    userName: reposHeaderViewModel.ownerName,
                                    reposName: reposHeaderViewModel.repositoryName);
                              },
                            ),

                            ///fork状态
                            Container(width: 0.3, height: 25.0, color: Color(GSYColors.subLightTextColor)),
                            _getBottomItem(
                              GSYICons.REPOS_ITEM_FORK,
                              reposHeaderViewModel.repositoryFork,
                              () {
                                NavigatorUtils.gotoCommonList(
                                    context, reposHeaderViewModel.repositoryName, "repository", "repo_fork",
                                    userName: reposHeaderViewModel.ownerName,
                                    reposName: reposHeaderViewModel.repositoryName);
                              },
                            ),

                            ///订阅状态
                            Container(width: 0.3, height: 25.0, color: Color(GSYColors.subLightTextColor)),
                            _getBottomItem(
                              GSYICons.REPOS_ITEM_WATCH,
                              reposHeaderViewModel.repositoryWatch,
                              () {
                                NavigatorUtils.gotoCommonList(
                                    context, reposHeaderViewModel.repositoryName, "user", "repo_watcher",
                                    userName: reposHeaderViewModel.ownerName,
                                    reposName: reposHeaderViewModel.repositoryName);
                              },
                            ),

                            ///issue状态
                            Container(width: 0.3, height: 25.0, color: Color(GSYColors.subLightTextColor)),
                            _getBottomItem(
                              GSYICons.REPOS_ITEM_ISSUE,
                              reposHeaderViewModel.repositoryIssue,
                              () {
                                if (reposHeaderViewModel.allIssueCount == null ||
                                    reposHeaderViewModel.allIssueCount <= 0) {
                                  return;
                                }
                                List<String> list = [
                                  CommonUtils.getLocale(context).repos_all_issue_count +
                                      reposHeaderViewModel.allIssueCount.toString(),
                                  CommonUtils.getLocale(context).repos_open_issue_count +
                                      reposHeaderViewModel.openIssuesCount.toString(),
                                  CommonUtils.getLocale(context).repos_close_issue_count +
                                      (reposHeaderViewModel.allIssueCount - reposHeaderViewModel.openIssuesCount)
                                          .toString(),
                                ];
                                CommonUtils.showCommitOptionDialog(context, list, (index) {}, height: 150.0);
                              },
                            ),
                          ],
                        )),
                    _renderTopicGroup(context),
                  ],
                ),
              ),
            ),
          ),
        ),

        ///底部头
        GSYSelectItemWidget([
          CommonUtils.getLocale(context).repos_tab_activity,
          CommonUtils.getLocale(context).repos_tab_commits,
        ], selectItemChanged)
      ],
    );
  }
}

class ReposHeaderViewModel {
  String ownerName = '---';
  String ownerPic;
  String repositoryName = "---";
  String repositorySize = "---";
  String repositoryStar = "---";
  String repositoryFork = "---";
  String repositoryWatch = "---";
  String repositoryIssue = "---";
  String repositoryIssueClose = "";
  String repositoryIssueAll = "";
  String repositoryType = "---";
  String repositoryDes = "---";
  String repositoryLastActivity = "";
  String repositoryParentName = "";
  String repositoryParentUser = "";
  String created_at = "";
  String push_at = "";
  String license = "";
  List<String> topics;
  int allIssueCount = 0;
  int openIssuesCount = 0;
  bool repositoryStared = false;
  bool repositoryForked = false;
  bool repositoryWatched = false;
  bool repositoryIsFork = false;

  ReposHeaderViewModel();

  ReposHeaderViewModel.fromHttpMap(ownerName, reposName, Repository map) {
    this.ownerName = ownerName;
    if (map == null || map.owner == null) {
      return;
    }
    this.ownerPic = map.owner.avatar_url;
    this.repositoryName = reposName;
    this.allIssueCount = map.allIssueCount;
    this.topics = map.topics;
    this.openIssuesCount = map.openIssuesCount;
    this.repositoryStar = map.watchersCount != null ? map.watchersCount.toString() : "";
    this.repositoryFork = map.forksCount != null ? map.forksCount.toString() : "";
    this.repositoryWatch = map.subscribersCount != null ? map.subscribersCount.toString() : "";
    this.repositoryIssue = map.openIssuesCount != null ? map.openIssuesCount.toString() : "";
    //this.repositoryIssueClose = map.closedIssuesCount != null ? map.closed_issues_count.toString() : "";
    //this.repositoryIssueAll = map.all_issues_count != null ? map.all_issues_count.toString() : "";
    this.repositorySize = ((map.size / 1024.0)).toString().substring(0, 3) + "M";
    this.repositoryType = map.language;
    this.repositoryDes = map.description;
    this.repositoryIsFork = map.fork;
    this.license = map.license != null ? map.license.name : "";
    this.repositoryParentName = map.parent != null ? map.parent.fullName : null;
    this.repositoryParentUser = map.parent != null ? map.parent.owner.login : null;
    this.created_at = CommonUtils.getNewsTimeStr(map.createdAt);
    this.push_at = CommonUtils.getNewsTimeStr(map.pushedAt);
  }
}
