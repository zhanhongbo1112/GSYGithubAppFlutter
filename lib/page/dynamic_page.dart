import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../common/common.dart';
import '../widget/widget.dart';
import '../bloc/bloc.dart';

/// 主页动态tab页
class DynamicPage extends StatefulWidget {
  @override
  _DynamicPageState createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage>
    with AutomaticKeepAliveClientMixin<DynamicPage>, GSYBlocListState<DynamicPage>, WidgetsBindingObserver {
  final DynamicBloc dynamicBloc = DynamicBloc();

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
    return await dynamicBloc.requestRefresh(_getStore().state.userInfo?.login);
  }

  @override
  requestLoadMore() async {
    return await dynamicBloc.requestLoadMore(_getStore().state.userInfo?.login);
  }

  @override
  bool get isRefreshFirst => false;

  @override
  BlocListBase get bloc => dynamicBloc;

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

  _renderEventItem(Event e) {
    EventViewModel eventViewModel = EventViewModel.fromEventMap(e);
    return EventItem(
      eventViewModel,
      onPressed: () {
        EventUtils.ActionUtils(context, e, "");
      },
    );
  }

  Store<GSYState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return BlocProvider<DynamicBloc>(
          bloc: dynamicBloc,
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
