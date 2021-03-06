import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/event/bloc/event_bloc.dart';
import 'package:yqboots/src/apps/github-client/event/index.dart';
import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

import '../index.dart';

/// 主页动态tab页
class EventHomePage extends StatefulWidget {
  @override
  _EventHomePageState createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage>
    with AutomaticKeepAliveClientMixin<EventHomePage>, GSYBlocListState<EventHomePage>, WidgetsBindingObserver {
  final EventBloc eventBloc = EventBloc();

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
    return await eventBloc.requestRefresh(StoreProvider.of<GSYState>(context).state.userInfo?.login);
  }

  @override
  requestLoadMore() async {
    return await eventBloc.requestLoadMore(StoreProvider.of<GSYState>(context).state.userInfo?.login);
  }

  @override
  bool get isRefreshFirst => false;

  @override
  BlocListBase get bloc => eventBloc;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ReposDao.getNewsVersion(context, false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (bloc.getDataLength() == 0) {
      showRefreshLoading();
    }

    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (bloc.getDataLength() != 0) {
        showRefreshLoading();
      }
    }
  }

  _renderEventItem(Event event) {
    EventViewModel eventViewModel = EventViewModel.fromEventMap(event);
    return EventItem(eventViewModel, onPressed: () => EventUtils.ActionUtils(context, event, ""));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return BlocProvider<EventBloc>(
          bloc: eventBloc,
          child: GSYPullNewLoadWidget(
            bloc.pullLoadWidgetControl,
            (BuildContext context, int index) => _renderEventItem(bloc.dataList[index]),
            requestRefresh,
            requestLoadMore,
            refreshKey: refreshIndicatorKey,
          ),
        );
      },
    );
  }
}
