import 'package:flutter/material.dart';
import 'package:yqboots/src/apps/github-client/_models/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

/// 仓库Item
class ReposItem extends StatelessWidget {
  final ReposViewModel reposViewModel;

  final VoidCallback onPressed;

  ReposItem(this.reposViewModel, {this.onPressed}) : super();

  ///仓库item的底部状态，比如star数量等
  _getBottomItem(IconData icon, String text, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: GSYIConText(
          icon,
          text,
          GSYConstant.smallSubText,
          Color(GSYColors.subTextColor),
          15.0,
          padding: 5.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GSYCardItem(
          child: FlatButton(
              onPressed: onPressed,
              child: Padding(
                padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ///头像
                        GSYUserIconWidget(
                            padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 0.0),
                            width: 40.0,
                            height: 40.0,
                            image: reposViewModel.ownerPic,
                            onPressed: () {
                              NavigatorUtils.goPerson(context, reposViewModel.ownerName);
                            }),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ///仓库名
                              Text(reposViewModel.repositoryName, style: GSYConstant.normalTextBold),

                              ///用户名
                              GSYIConText(
                                GSYICons.REPOS_ITEM_USER,
                                reposViewModel.ownerName,
                                GSYConstant.smallSubLightText,
                                Color(GSYColors.subLightTextColor),
                                10.0,
                                padding: 3.0,
                              ),
                            ],
                          ),
                        ),

                        ///仓库语言
                        Text(reposViewModel.repositoryType, style: GSYConstant.smallSubText),
                      ],
                    ),
                    Container(

                        ///仓库描述
                        child: Text(
                          reposViewModel.repositoryDes,
                          style: GSYConstant.smallSubText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),
                    Padding(padding: EdgeInsets.all(10.0)),

                    ///仓库状态数值
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getBottomItem(GSYICons.REPOS_ITEM_STAR, reposViewModel.repositoryStar),
                        _getBottomItem(GSYICons.REPOS_ITEM_FORK, reposViewModel.repositoryFork),
                        _getBottomItem(GSYICons.REPOS_ITEM_ISSUE, reposViewModel.repositoryWatch, flex: 4),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }
}

class ReposViewModel {
  String ownerName;
  String ownerPic;
  String repositoryName;
  String repositoryStar;
  String repositoryFork;
  String repositoryWatch;
  String hideWatchIcon;
  String repositoryType = "";
  String repositoryDes;

  ReposViewModel();

  ReposViewModel.fromMap(Repository data) {
    ownerName = data.owner.login;
    ownerPic = data.owner.avatar_url;
    repositoryName = data.name;
    repositoryStar = data.watchersCount.toString();
    repositoryFork = data.forksCount.toString();
    repositoryWatch = data.openIssuesCount.toString();
    repositoryType = data.language ?? '---';
    repositoryDes = data.description ?? '---';
  }

  ReposViewModel.fromTrendMap(model) {
    ownerName = model.name;
    if (model.contributors.length > 0) {
      ownerPic = model.contributors[0];
    } else {
      ownerPic = "";
    }
    repositoryName = model.reposName;
    repositoryStar = model.starCount;
    repositoryFork = model.forkCount;
    repositoryWatch = model.meta;
    repositoryType = model.language;
    repositoryDes = model.description;
  }
}
