import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

import './bloc/trend_bloc.dart';
import '../index.dart';

/// 主页趋势tab页
class TrendHomePage extends StatefulWidget {
  @override
  _TrendHomePageState createState() => _TrendHomePageState();
}

class _TrendHomePageState extends State<TrendHomePage>
    with AutomaticKeepAliveClientMixin<TrendHomePage>, GSYBlocListState<TrendHomePage> {
  static TrendTypeModel selectTime = null;

  static TrendTypeModel selectType = null;

  final TrendBloc trendBloc = TrendBloc();

  _renderItem(e) {
    ReposViewModel reposViewModel = ReposViewModel.fromTrendMap(e);

    return ReposItem(reposViewModel, onPressed: () {
      NavigatorUtils.goReposDetail(context, reposViewModel.ownerName, reposViewModel.repositoryName);
    });
  }

  _renderHeader(Store<GSYState> store) {
    if (selectType == null && selectType == null) {
      return Container();
    }

    return GSYCardItem(
      color: store.state.themeData.primaryColor,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
            _renderHeaderPopItem(selectTime.name, TrendTypeModel.trendTime(context), (TrendTypeModel result) {
              if (bloc.pullLoadWidgetControl.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              setState(() => selectTime = result);
              showRefreshLoading();
            }),
            Container(height: 10.0, width: 0.5, color: Color(GSYColors.white)),
            _renderHeaderPopItem(selectType.name, TrendTypeModel.trendType(context), (TrendTypeModel result) {
              if (bloc.pullLoadWidgetControl.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              setState(() => selectType = result);
              showRefreshLoading();
            }),
          ],
        ),
      ),
    );
  }

  _renderHeaderPopItem(String data, List<TrendTypeModel> list, PopupMenuItemSelected<TrendTypeModel> onSelected) {
    return Expanded(
      child: PopupMenuButton<TrendTypeModel>(
        child: Center(child: Text(data, style: GSYConstant.middleTextWhite)),
        onSelected: onSelected,
        itemBuilder: (context) => _renderHeaderPopItemChild(list),
      ),
    );
  }

  _renderHeaderPopItemChild(List<TrendTypeModel> data) {
    return data.map((item) => PopupMenuItem<TrendTypeModel>(value: item, child: Text(item.name))).toList();
  }

  @override
  requestRefresh() async {
    return await trendBloc.requestRefresh(selectTime, selectType);
  }

  @override
  requestLoadMore() async {
    return null;
  }

  @override
  BlocListBase get bloc => trendBloc;

  @override
  bool get isRefreshFirst => false;

  @override
  void didChangeDependencies() {
    if (bloc.getDataLength() == 0) {
      setState(() {
        selectTime = TrendTypeModel.trendTime(context)[0];
        selectType = TrendTypeModel.trendType(context)[0];
      });
      showRefreshLoading();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin

    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return Scaffold(
          backgroundColor: Color(GSYColors.mainBackgroundColor),
          appBar: AppBar(
            flexibleSpace: _renderHeader(store),
            backgroundColor: Color(GSYColors.mainBackgroundColor),
            leading: Container(),
            elevation: 0.0,
          ),
          body: BlocProvider<TrendBloc>(
            bloc: trendBloc,
            child: GSYPullNewLoadWidget(
              bloc.pullLoadWidgetControl,
              (BuildContext context, int index) => _renderItem(bloc.dataList[index]),
              requestRefresh,
              requestLoadMore,
              refreshKey: refreshIndicatorKey,
            ),
          ),
        );
      },
    );
  }
}
