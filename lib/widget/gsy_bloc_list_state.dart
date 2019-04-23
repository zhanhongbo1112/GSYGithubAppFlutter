import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gsy_github_app_flutter/bloc/base/base_bloc.dart';

/**
 * 上下拉刷新列表的通用State
 * Created by guoshuyu
 * Date: 2018-07-20
 */
mixin GSYBlocListState<T extends StatefulWidget> on State<T>, AutomaticKeepAliveClientMixin<T> {

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  ///显示刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
      return true;
    });
  }

  ///下拉刷新数据
  @protected
  Future requestRefresh();

  ///上拉更多请求数据
  @protected
  Future requestLoadMore();

  ///是否需要第一次进入自动刷新
  @protected
  bool get isRefreshFirst;

  ///是否需要头部
  @protected
  bool get needHeader => false;

  ///是否需要保持
  @override
  bool get wantKeepAlive => true;

  @protected
  BlocListBase get bloc;

  @override
  void initState() {
    super.initState();
    bloc.changeNeedHeaderStatus(needHeader);
    if (bloc.getDataLength() == 0 && isRefreshFirst) {
      showRefreshLoading();
    }
  }
}
