import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/event/index.dart';

import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';

import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/// 通知消息
class NotifyPage extends StatefulWidget {
  NotifyPage();

  @override
  _NotifyPageState createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage>
    with AutomaticKeepAliveClientMixin<NotifyPage>, GSYListState<NotifyPage> {
  final SlidableController slidableController = SlidableController();

  int selectIndex = 0;

  _NotifyPageState();

  _renderItem(index) {
    GitHubNotification notification = pullLoadWidgetControl.dataList[index];
    if (selectIndex != 0) {
      return _renderEventItem(notification);
    }
    return Slidable(
      controller: slidableController,
      delegate: SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: _renderEventItem(notification),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: CommonUtils.getLocale(context).notify_readed,
          color: Colors.redAccent,
          icon: Icons.delete,
          onTap: () {
            UserDao.setNotificationAsReadDao(notification.id.toString()).then((res) {
              showRefreshLoading();
            });
          },
        ),
      ],
    );
  }

  _renderEventItem(GitHubNotification notification) {
    EventViewModel eventViewModel = EventViewModel.fromNotify(context, notification);
    return EventItem(eventViewModel, onPressed: () {
      if (notification.unread) {
        UserDao.setNotificationAsReadDao(notification.id.toString());
      }
      if (notification.subject.type == 'Issue') {
        String url = notification.subject.url;
        List<String> tmp = url.split("/");
        String number = tmp[tmp.length - 1];
        String userName = notification.repository.owner.login;
        String reposName = notification.repository.name;
        NavigatorUtils.goIssueDetail(context, userName, reposName, number, needRightLocalIcon: true).then((res) {
          showRefreshLoading();
        });
      }
    }, needImage: false);
  }

  _resolveSelectIndex() {
    clearData();
    showRefreshLoading();
  }

  _getDataLogic() async {
    return await UserDao.getNotifyDao(selectIndex == 2, selectIndex == 1, page);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  bool get needHeader => false;

  @override
  bool get isRefreshFirst => true;

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  requestRefresh() async {
    return await _getDataLogic();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return Scaffold(
      backgroundColor: Color(GSYColors.mainBackgroundColor),
      appBar: AppBar(
        title: GSYTitleBar(
          CommonUtils.getLocale(context).notify_title,
          iconData: GSYICons.NOTIFY_ALL_READ,
          needRightLocalIcon: true,
          onPressed: () {
            CommonUtils.showLoadingDialog(context);
            UserDao.setAllNotificationAsReadDao().then((res) {
              Navigator.pop(context);
              _resolveSelectIndex();
            });
          },
        ),
        bottom: GSYSelectItemWidget(
          [
            CommonUtils.getLocale(context).notify_tab_unread,
            CommonUtils.getLocale(context).notify_tab_part,
            CommonUtils.getLocale(context).notify_tab_all,
          ],
          (selectIndex) {
            this.selectIndex = selectIndex;
            _resolveSelectIndex();
          },
          height: 30.0,
          margin: const EdgeInsets.all(0.0),
          elevation: 0.0,
        ),
        elevation: 4.0,
      ),
      body: GSYPullLoadWidget(
        pullLoadWidgetControl,
        (BuildContext context, int index) => _renderItem(index),
        handleRefresh,
        onLoadMore,
        refreshKey: refreshIndicatorKey,
      ),
    );
  }
}
