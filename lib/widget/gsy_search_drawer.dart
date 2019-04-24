import 'package:flutter/material.dart';

import '../common/common.dart';

typedef void SearchSelectItemChanged<String>(String value);

/// 搜索drawer
class GSYSearchDrawer extends StatefulWidget {
  final SearchSelectItemChanged<String> typeCallback;
  final SearchSelectItemChanged<String> sortCallback;
  final SearchSelectItemChanged<String> languageCallback;

  GSYSearchDrawer(this.typeCallback, this.sortCallback, this.languageCallback);

  @override
  _GSYSearchDrawerState createState() => _GSYSearchDrawerState();
}

class _GSYSearchDrawerState extends State<GSYSearchDrawer> {
  _GSYSearchDrawerState();

  final double itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(top: CommonUtils.sStaticBarHeight),
      child: Container(
        color: Color(GSYColors.white),
        child: SingleChildScrollView(
          child: Column(
            children: _renderList(),
          ),
        ),
      ),
    );
  }

  _renderList() {
    List<Widget> list = List();
    list.add(Container(
      width: itemWidth,
    ));
    list.add(_renderTitle(CommonUtils.getLocale(context).search_type));
    for (int i = 0; i < searchFilterType.length; i++) {
      FilterModel model = searchFilterType[i];
      list.add(_renderItem(model, searchFilterType, i, widget.typeCallback));
      list.add(_renderDivider());
    }
    list.add(_renderTitle(CommonUtils.getLocale(context).search_type));

    for (int i = 0; i < sortType.length; i++) {
      FilterModel model = sortType[i];
      list.add(_renderItem(model, sortType, i, widget.sortCallback));
      list.add(_renderDivider());
    }
    list.add(_renderTitle(CommonUtils.getLocale(context).search_language));
    for (int i = 0; i < searchLanguageType.length; i++) {
      FilterModel model = searchLanguageType[i];
      list.add(_renderItem(model, searchLanguageType, i, widget.languageCallback));
      list.add(_renderDivider());
    }
    return list;
  }

  _renderTitle(String title) {
    return Container(
      color: Theme.of(context).primaryColor,
      width: itemWidth + 50,
      height: 50.0,
      child: Center(
        child: Text(
          title,
          style: GSYConstant.middleTextWhite,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  _renderDivider() {
    return Container(
      color: Color(GSYColors.subTextColor),
      width: itemWidth,
      height: 0.3,
    );
  }

  _renderItem(FilterModel model, List<FilterModel> list, int index, SearchSelectItemChanged<String> select) {
    return Stack(
      children: <Widget>[
        Container(
          height: 50.0,
          child: Container(
            width: itemWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: Checkbox(value: model.select, onChanged: (value) {})),
                Center(child: Text(model.name)),
              ],
            ),
          ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              for (FilterModel model in list) {
                model.select = false;
              }
              list[index].select = true;
            });
            select?.call(model.value);
          },
          child: Container(
            width: itemWidth,
          ),
        )
      ],
    );
  }
}

class FilterModel {
  String name;
  String value;
  bool select;

  FilterModel({this.name, this.value, this.select});
}

var sortType = [
  FilterModel(name: 'desc', value: 'desc', select: true),
  FilterModel(name: 'asc', value: 'asc', select: false),
];
var searchFilterType = [
  FilterModel(name: "best_match", value: 'best%20match', select: true),
  FilterModel(name: "stars", value: 'stars', select: false),
  FilterModel(name: "forks", value: 'forks', select: false),
  FilterModel(name: "updated", value: 'updated', select: false),
];
var searchLanguageType = [
  FilterModel(name: "trendAll", value: null, select: true),
  FilterModel(name: "Java", value: 'Java', select: false),
  FilterModel(name: "Dart", value: 'Dart', select: false),
  FilterModel(name: "Objective_C", value: 'Objective-C', select: false),
  FilterModel(name: "Swift", value: 'Swift', select: false),
  FilterModel(name: "JavaScript", value: 'JavaScript', select: false),
  FilterModel(name: "PHP", value: 'PHP', select: false),
  FilterModel(name: "C__", value: 'C++', select: false),
  FilterModel(name: "C", value: 'C', select: false),
  FilterModel(name: "HTML", value: 'HTML', select: false),
  FilterModel(name: "CSS", value: 'CSS', select: false),
];
