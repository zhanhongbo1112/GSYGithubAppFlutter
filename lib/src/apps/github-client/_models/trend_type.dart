import 'package:flutter/material.dart';
import 'package:yqboots/common/common.dart';

/// 趋势类型
class TrendTypeModel {
  final String name;
  final String value;

  TrendTypeModel(this.name, this.value);

  static trendTime(BuildContext context) {
    return [
      TrendTypeModel(CommonUtils.getLocale(context).trend_day, "daily"),
      TrendTypeModel(CommonUtils.getLocale(context).trend_week, "weekly"),
      TrendTypeModel(CommonUtils.getLocale(context).trend_month, "monthly"),
    ];
  }

  static trendType(BuildContext context) {
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
}
