import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';

import '../common/common.dart';
import '../widget/widget.dart';
import '../bloc/bloc.dart';

/// 主页趋势tab页
class TrendPage extends StatefulWidget {
  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage>
    with AutomaticKeepAliveClientMixin<TrendPage>, GSYBlocListState<TrendPage> {
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
        padding: EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
            _renderHeaderPopItem(selectTime.name, trendTime(context), (TrendTypeModel result) {
              if (bloc.pullLoadWidgetControl.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              setState(() {
                selectTime = result;
              });
              showRefreshLoading();
            }),
            Container(height: 10.0, width: 0.5, color: Color(GSYColors.white)),
            _renderHeaderPopItem(selectType.name, trendType(context), (TrendTypeModel result) {
              if (bloc.pullLoadWidgetControl.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              setState(() {
                selectType = result;
              });
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
        itemBuilder: (BuildContext context) {
          return _renderHeaderPopItemChild(list);
        },
      ),
    );
  }

  _renderHeaderPopItemChild(List<TrendTypeModel> data) {
    List<PopupMenuEntry<TrendTypeModel>> list = List();
    for (TrendTypeModel item in data) {
      list.add(PopupMenuItem<TrendTypeModel>(
        value: item,
        child: Text(item.name),
      ));
    }
    return list;
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
        selectTime = trendTime(context)[0];
        selectType = trendType(context)[0];
      });
      showRefreshLoading();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
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

class TrendTypeModel {
  final String name;
  final String value;

  TrendTypeModel(this.name, this.value);
}

trendTime(BuildContext context) {
  return [
    TrendTypeModel(CommonUtils.getLocale(context).trend_day, "daily"),
    TrendTypeModel(CommonUtils.getLocale(context).trend_week, "weekly"),
    TrendTypeModel(CommonUtils.getLocale(context).trend_month, "monthly"),
  ];
}

trendType(BuildContext context) {
  return [
    TrendTypeModel(CommonUtils.getLocale(context).trend_all, null),
    TrendTypeModel("Java", "Java"),
    TrendTypeModel("Kotlin", "Kotlin"),
    TrendTypeModel("Dart", "Dart"),
    TrendTypeModel("Objective-C", "Objective-C"),
    TrendTypeModel("Swift", "Swift"),
    TrendTypeModel("JavaScript", "JavaScript"),
    TrendTypeModel("PHP", "PHP"),
    TrendTypeModel("Go", "Go"),
    TrendTypeModel("C++", "C++"),
    TrendTypeModel("C", "C"),
    TrendTypeModel("HTML", "HTML"),
    TrendTypeModel("CSS", "CSS"),
    TrendTypeModel("Python", "Python"),
    TrendTypeModel("C#", "c%23"),
  ];
}
