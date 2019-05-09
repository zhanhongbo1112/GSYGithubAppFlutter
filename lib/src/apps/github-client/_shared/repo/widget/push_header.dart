import 'package:flutter/material.dart';
import 'package:yqboots/src/apps/github-client/_models/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

/// 提交详情的头
class PushHeader extends StatelessWidget {
  final PushHeaderViewModel pushHeaderViewModel;

  PushHeader(this.pushHeaderViewModel);

  /// 头部变化数量图标
  _getIconItem(IconData icon, String text) {
    return GSYIConText(
      icon,
      text,
      GSYConstant.smallSubLightText,
      Color(GSYColors.subLightTextColor),
      15.0,
      padding: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GSYCardItem(
      color: Theme.of(context).primaryColor,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {},
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ///用户头像
                  GSYUserIconWidget(
                      padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 0.0),
                      width: 40.0,
                      height: 40.0,
                      image: pushHeaderViewModel.actionUserPic,
                      onPressed: () {
                        NavigatorUtils.goPerson(context, pushHeaderViewModel.actionUser);
                      }),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ///变化状态
                        Row(
                          children: <Widget>[
                            _getIconItem(GSYICons.PUSH_ITEM_EDIT, pushHeaderViewModel.editCount),
                            Container(width: 8.0),
                            _getIconItem(GSYICons.PUSH_ITEM_ADD, pushHeaderViewModel.addCount),
                            Container(width: 8.0),
                            _getIconItem(GSYICons.PUSH_ITEM_MIN, pushHeaderViewModel.deleteCount),
                            Container(width: 8.0),
                          ],
                        ),
                        Padding(padding: EdgeInsets.all(2.0)),

                        ///修改时间
                        Container(
                            child: Text(
                              pushHeaderViewModel.pushTime,
                              style: GSYConstant.smallTextWhite,
                              maxLines: 2,
                            ),
                            margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                            alignment: Alignment.topLeft),

                        ///修改的commit内容
                        Container(
                            child: Text(
                              pushHeaderViewModel.pushDes,
                              style: GSYConstant.smallTextWhite,
                              maxLines: 2,
                            ),
                            margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                            alignment: Alignment.topLeft),
                        Padding(
                          padding: EdgeInsets.only(left: 0.0, top: 2.0, right: 0.0, bottom: 0.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PushHeaderViewModel {
  String actionUser = "---";
  String actionUserPic = "---";
  String pushDes = "---";
  String pushTime = "---";
  String editCount = "---";
  String addCount = "---";
  String deleteCount = "---";
  String htmlUrl = GSYConstant.app_default_share_url;

  PushHeaderViewModel();

  PushHeaderViewModel.forMap(PushCommit pushMap) {
    String name = "---";
    String pic = "---";
    if (pushMap.committer != null) {
      name = pushMap.committer.login;
    } else if (pushMap.commit != null && pushMap.commit.author != null) {
      name = pushMap.commit.author.name;
    }
    if (pushMap.committer != null && pushMap.committer.avatar_url != null) {
      pic = pushMap.committer.avatar_url;
    }
    actionUser = name;
    actionUserPic = pic;
    pushDes = "Push at " + pushMap.commit.message;
    pushTime = CommonUtils.getNewsTimeStr(pushMap.commit.committer.date);
    editCount = pushMap.files.length.toString() + "";
    addCount = pushMap.stats.additions.toString() + "";
    deleteCount = pushMap.stats.deletions.toString() + "";
    htmlUrl = pushMap.htmlUrl;
  }
}
