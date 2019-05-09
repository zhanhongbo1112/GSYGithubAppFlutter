import 'package:flutter/material.dart';
import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/apps/github-client/index.dart';
import 'package:yqboots/src/widgets/widgets.dart';

import '../util/event_utils.dart';

import 'package:yqboots/src/apps/github-client/_models/Notification.dart';

/// 事件Item
class EventItem extends StatelessWidget {
  final EventViewModel eventViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  EventItem(this.eventViewModel, {this.onPressed, this.needImage = true}) : super();

  @override
  Widget build(BuildContext context) {
    Widget des = (eventViewModel.actionDes == null || eventViewModel.actionDes.length == 0)
        ? Container()
        : Container(
            child: Text(
              eventViewModel.actionDes,
              style: GSYConstant.smallSubText,
              maxLines: 3,
            ),
            margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
            alignment: Alignment.topLeft);

    Widget userImage = (needImage)
        ? GSYUserIconWidget(
            padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 0.0),
            width: 30.0,
            height: 30.0,
            image: eventViewModel.actionUserPic,
            onPressed: () {
              NavigatorUtils.goPerson(context, eventViewModel.actionUser);
            })
        : Container();
    return Container(
      child: GSYCardItem(
          child: FlatButton(
              onPressed: onPressed,
              child: Padding(
                padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 0.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        userImage,
                        Expanded(child: Text(eventViewModel.actionUser, style: GSYConstant.smallTextBold)),
                        Text(eventViewModel.actionTime, style: GSYConstant.smallSubText),
                      ],
                    ),
                    Container(
                        child: Text(eventViewModel.actionTarget, style: GSYConstant.smallTextBold),
                        margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),
                    des,
                  ],
                ),
              ))),
    );
  }
}

class EventViewModel {
  String actionUser;
  String actionUserPic;
  String actionDes;
  String actionTime;
  String actionTarget;

  EventViewModel.fromEventMap(Event event) {
    actionTime = CommonUtils.getNewsTimeStr(event.createdAt);
    actionUser = event.actor.login;
    actionUserPic = event.actor.avatar_url;
    var other = EventUtils.getActionAndDes(event);
    actionDes = other["des"];
    actionTarget = other["actionStr"];
  }

  EventViewModel.fromCommitMap(RepoCommit eventMap) {
    actionTime = CommonUtils.getNewsTimeStr(eventMap.commit.committer.date);
    actionUser = eventMap.commit.committer.name;
    actionDes = "sha:" + eventMap.sha;
    actionTarget = eventMap.commit.message;
  }

  EventViewModel.fromNotify(BuildContext context, GitHubNotification eventMap) {
    actionTime = CommonUtils.getNewsTimeStr(eventMap.updateAt);
    actionUser = eventMap.repository.fullName;
    String type = eventMap.subject.type;
    String status =
        eventMap.unread ? CommonUtils.getLocale(context).notify_unread : CommonUtils.getLocale(context).notify_readed;
    actionDes = eventMap.reason +
        "${CommonUtils.getLocale(context).notify_type}：$type，${CommonUtils.getLocale(context).notify_status}：$status";
    actionTarget = eventMap.subject.title;
  }
}
